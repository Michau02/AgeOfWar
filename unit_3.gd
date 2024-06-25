extends CharacterBody2D
signal unit_killed(player, gold, exp)

var player : int
var age = 1

var hp = 300
var damage = 10
var offence = 5
var deffence = 15
var SPEED = 80
var attackSpeed = 0.6
var crit_chance = 30
var gold_reward_for_killing = 57
var exp_reward_for_killing = 150

var max_hp = hp
var maxSpeed = SPEED
var damage_multiplier

var type = "tank"

var fighting = false
var is_dead = false
var is_colliding = false

var currentTarget = null
var target_queue = []
@onready var health_bar = $Sprite2D/ColorRect
@onready var gold = $Sprite2D/ColorRect
@onready var initial_health_bar_size_x = health_bar.size.x

var animation_sprite

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("units")
	$Label.text = "+ " + str(gold_reward_for_killing)
	$Label.hide()
	$Attack_timer.wait_time = 1.0 / attackSpeed
	if age != 1:
		updateStats()
	animation_sprite = $Sprite2D
	if player == 2:
		SPEED *= -1
		maxSpeed *= -1
		$Area2D_tank/Attack_CollisionShape2D.position.x *= -1
		$tank_body/CollisionShape2D.position.x *= -1
		$Back_area/CollisionShape2D.position.x *= -1
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
	velocity.x = SPEED

	if is_colliding:
		velocity.x = 0
	else:
		if not fighting:
			velocity.x = SPEED
		else:
			velocity.x = 0

	if velocity.x == 0 and fighting:
		animation_sprite.play("attack")
	elif velocity.x == 0 and not fighting:
		animation_sprite.play("idle")
	else:
		animation_sprite.play("walk")

	move_and_slide()

func update_health_bar():
	health_bar.size.x = initial_health_bar_size_x * (hp / float(max_hp))

func _on_attack_timer_timeout():
	if currentTarget != null:
		if currentTarget.is_in_group("units"):
			var unit = currentTarget.get_parent()
			
			damage_multiplier = 1
			if randi_range(1, 100) <= crit_chance:
				damage_multiplier = 1.5 
			unit.hp -= (damage*damage_multiplier)*((100-max(unit.deffence - offence, 0)))/100
			
			unit.update_health_bar()
			if unit.hp > 0:
				$Attack_timer.start()
			elif unit.hp <= 0:
				emit_signal("unit_killed", player, unit.gold_reward_for_killing, unit.exp_reward_for_killing)
				unit.is_dead = true
				SPEED = maxSpeed
				$Attack_timer.stop()
				target_queue.erase(currentTarget)
				if target_queue.size() > 0:
					set_new_target(target_queue.back())
				else:
					fighting = false
					animation_sprite.set_speed_scale(1)
		elif currentTarget.is_in_group("bases"):
			var base = currentTarget.get_parent()
			base.health -= damage
			var health_percentage = base.health / float(base.max_hp)
			base.hp_bar.size.y -= base.hp_bar.size.y * (damage / float(base.health))
			base.hp_label.text = str(base.health)
			if base.health > 0:
				$Attack_timer.start()
			else:
				SPEED = maxSpeed
				$Attack_timer.stop()
				target_queue.erase(currentTarget)
				if target_queue.size() > 0:
					set_new_target(target_queue.back())
				else:
					fighting = false
					animation_sprite.set_speed_scale(1)
	else:
		SPEED = maxSpeed
		fighting = false
		if target_queue.size() > 0:
			set_new_target(target_queue.back())

func _on_area_2d_tank_area_entered(area):
	if (area.is_in_group("units") or area.is_in_group("bases")) and area.get_parent().player != player:
		if area.is_in_group("units") and (area.name == "melee_body" or area.name == "tank_body" or area.name == "ranged_body") and area.get_parent().is_dead == false:
			target_queue.push_back(area)
			set_new_target(area)
		elif area.is_in_group("bases"):
			target_queue.push_back(area)
			set_new_target(area)

func set_new_target(target):
	currentTarget = target
	SPEED = 0
	$Attack_timer.start()
	fighting = true
	animation_sprite.set_speed_scale(attackSpeed)

func _on_back_area_area_entered(area):
	if (area.is_in_group("units") and (area.name == "ranged_body" or area.name == "melee_body" or area.name == "tank_body") \
	and area.get_parent().player == player) and area.get_parent() != self:
		area.get_parent().is_colliding = true

func _on_back_area_area_exited(area):
	if (area.is_in_group("units") and area.get_parent().player == player):
		area.get_parent().is_colliding = false

func updateStats():
	scale *= Vector2(1.2, 1.2)
	hp = 700
	damage = 20
	offence = 10
	deffence = 35
	SPEED = 120
	attackSpeed = 0.8
	crit_chance = 60
	gold_reward_for_killing = 160
	exp_reward_for_killing = 350
	maxSpeed = SPEED
	max_hp = hp
	
	animation_sprite = $Sprite2D
	animation_sprite.set_speed_scale(attackSpeed)
	$Label.text = "+ " + str(gold_reward_for_killing)

func _on_sprite_2d_animation_finished():
	if animation_sprite.animation == "death":
		queue_free()
