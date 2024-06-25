extends CharacterBody2D
signal bullet_killed(player, gold, exp)

var SPEED = 600
var player
var damage
var offence
var type

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if player == 2:
		SPEED *= -1
		$Sprite2D.texture = preload("res://art/projectiles/arrow.png")
		$Sprite2D.flip_h = true

func _physics_process(delta):
	if not is_on_floor():
		if type == "unit2":
			velocity.y += gravity/24 * delta
		else:
			velocity.y += gravity/4 * delta	
		
	else:
		queue_free()
	velocity.x = SPEED

	move_and_slide()

func _on_area_2d_area_entered(area):
	if area.is_in_group("units") and area.name != "Area2D_attack_range" and area.get_parent().player != player and (area.name == "melee_body" or area.name == "ranged_body" or area.name == "tank_body"):
		area.get_parent().hp -= (damage*((100-max(area.get_parent().deffence - offence, 0)))/100)
		
		if area.get_parent().hp <= 0:
			area.get_parent().is_dead = true
			if type == "unit2" and player == 1:
				emit_signal("bullet_killed", player, area.get_parent().gold_reward_for_killing, area.get_parent().exp_reward_for_killing)
			elif type == "turret":
				emit_signal("bullet_killed", player, area.get_parent().gold_reward_for_killing, area.get_parent().exp_reward_for_killing)				
			area.queue_free()
		area.get_parent().update_health_bar()
		queue_free()
	elif area.is_in_group("bases"):
		if type == "unit2":
			if area.get_parent().player != player:
				area.get_parent().health -= damage
				var health_percentage = area.get_parent().health/float(area.get_parent().max_hp)
				area.get_parent().hp_bar.size.y = health_percentage * area.get_parent().hp_bar_size
				area.get_parent().hp_label.text = str(area.get_parent().health)
				if area.get_parent().health <= 0:
					area.get_parent().queue_free()
					gameOver()
				queue_free()
	elif area.is_in_group("ground"):
		queue_free()

func gameOver():
	get_tree().change_scene_to_file("res://game_over.tscn")
