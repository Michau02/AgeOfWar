extends CharacterBody2D
signal unit_killed(player, gold, exp)

var player
var age = 1

var hp = 40
var damage = 25
var offence = 5
var deffence = 0
var SPEED = 200
var attackSpeed = 1
var crit_chance = 0
var gold_reward_for_killing = 13
var exp_reward_for_killing = 45

var max_hp = hp
var maxSpeed = SPEED
var type = "ranged"

var queue = []

var fighting = false
var is_dead = false
var is_colliding = false
var currentTarget = null
var is_shooting = false
@onready var health_bar = $Sprite2D/ColorRect
@onready var gold = $Sprite2D/ColorRect
@onready var initial_health_bar_size_x = health_bar.size.x

@onready var animation_player = $AnimationPlayer
var animation_sprite

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("units")
	$Label.text = "+ " + str(gold_reward_for_killing)
	$Label.hide()
	$Attack_timer.wait_time = 1.0/attackSpeed
	if age != 1:
		updateStats()
	animation_sprite = $Sprite2D
	if player == 2:
		SPEED *= -1
		maxSpeed *= -1
		$Area2D_attack_range/Attack_CollisionShape.position.x *= -1
		$ranged_body/CollisionShape2D.position.x *= -1
		$Back_area/CollisionShape2D.position.x *= -1
		$Marker2D.position.x *= -1
		$Sprite2D.flip_h = true
	set_collision_layer_value(4, true)
	
		
func _physics_process(delta):
	if is_dead:
		$Label.show()
		$Label.position.y -= 2
		animation_sprite.play("death")
		return
	if hp <= 0:
		is_dead = true
		
	if ((player == 2 and position.x < 1760) or (player == 1 and position.x > 350)):
		set_collision_layer_value(4, false)

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset the vertical velocity if on the floor
	if is_colliding:
		velocity.x = 0
	else:
		if not is_shooting:
			velocity.x = SPEED
		else:
			velocity.x = 0
	
	if velocity.x == 0 and is_shooting:
		animation_sprite.play("attack")
		
	elif velocity.x == 0 and not is_shooting:
		animation_sprite.play("idle")
	else:
		animation_sprite.play("walk")
	
	move_and_slide()

func _on_area_2d_area_entered(area):
	if (area.is_in_group("units") or area.is_in_group("bases")) and area.get_parent().player != player:
		if area.name != "Area2D_attack_range" and area.name != "Back_area" and area.name != "Area2D_melee" and area.name != "Area2D_tank":
			SPEED = 0
			currentTarget = area
			queue.push_back(currentTarget)
			if not is_shooting:
				shoot()
				
func shoot():
	is_shooting = true
	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.player = player
	bullet.position = $Marker2D.global_position
	bullet.damage = damage
	bullet.offence = offence
	bullet.type = "unit2"
	bullet.connect("bullet_killed", _on_bullet_killed)
	get_tree().root.add_child(bullet)
	bullet.show()
	$Attack_timer.start()        
	
func _on_attack_timer_timeout():
	if not is_dead:
		shoot()
		is_shooting = true

func update_health_bar():
	health_bar.size.x = initial_health_bar_size_x * (hp / float(max_hp))

func _on_back_area_area_entered(area):
	if (area.is_in_group("units") and (area.name == "ranged_body" or area.name == "melee_body" or area.name == "tank_body")\
	 and area.get_parent().player == player) and area.get_parent() != self:
		area.get_parent().is_colliding = true

func _on_back_area_area_exited(area):
	if (area.is_in_group("units") and area.get_parent().player == player):
		area.get_parent().is_colliding = false

func _on_area_2d_attack_range_area_exited(area):
	if(area.name == "ranged_body" or area.name == "melee_body" or area.name == "tank_body") and area.get_parent().player != player:
		$Attack_timer.stop()
		is_shooting = false
		if not queue.is_empty():
			queue.pop_back()
			if queue.is_empty():
				SPEED = maxSpeed
			else:
				currentTarget = queue.front()
				$Attack_timer.start()
				is_shooting = true

func updateStats():
	scale *= Vector2(1.2, 1.2)
	hp = 60
	damage = 40
	offence = 15
	deffence = 5
	SPEED = 200
	attackSpeed = 1.2
	crit_chance = 20
	gold_reward_for_killing = 29
	exp_reward_for_killing = 140
	maxSpeed = SPEED
	max_hp = hp
	
	animation_sprite = $Sprite2D
	animation_sprite.set_speed_scale(attackSpeed)
	$Label.text = "+ " + str(gold_reward_for_killing)

func _on_bullet_killed(player, gold_reward, exp_reward):
	emit_signal("unit_killed", player, gold_reward, exp_reward)

func _on_sprite_2d_animation_finished():
	if animation_sprite.animation == "death":
		queue_free()
