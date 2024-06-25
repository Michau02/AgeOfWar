extends StaticBody2D
signal unit_killed(player, gold, exp)

var player
var age

var damage = 10
var offence = 99999
var attack_speed = 2

var is_shooting = false
var queue = []
var currentTarget

var animation_sprite

func _ready():
	$Attack_timer.wait_time = 1.0/attack_speed
	animation_sprite = $Sprite2D
	if player == 2:
		$Turret_attack_range_area2D/Turret_attack_range_CollShape.position.x *= -1
		$Marker2D.position.x *= -1
		$Sprite2D.flip_h = true
	if age != 1:
		updateStats()

func updateStats():
	damage = 15
	attack_speed = 3
	animation_sprite.set_speed_scale(1.5)
	$Attack_timer.wait_time = 1.0/attack_speed

func _on_turret_attack_range_area_2d_area_entered(area):
	if area.is_in_group("units") and area.get_parent().player != player and area.get_parent() != self:
		if area.name == "melee_body" or area.name == "ranged_body" or area.name == "tank_body":
			currentTarget = area
			queue.push_back(currentTarget)
			if !is_shooting:
				shoot()
				animation_sprite.play("shoot")
				
				
func shoot():
	is_shooting = true
	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.player = player
	bullet.position = $Marker2D.global_position
	bullet.damage = damage
	bullet.offence = offence
	bullet.type = "turret"
	bullet.connect("bullet_killed", _on_bullet_killed)
	get_tree().root.add_child(bullet)
	bullet.show()
	$Attack_timer.start()	
	
func _on_attack_timer_timeout():
	shoot()
	is_shooting = true

func _on_bullet_killed(player, gold_reward, exp_reward):
	emit_signal("unit_killed", player, gold_reward, exp_reward)

func _on_turret_attack_range_area_2d_area_exited(area):
	if(area.name == "ranged_body" or area.name == "melee_body" or area.name == "tank_body") and area.get_parent().player != player:
		$Attack_timer.stop()
		is_shooting = false
		animation_sprite.stop()
		if !queue.is_empty():
			queue.pop_back()
			if !queue.is_empty():
				currentTarget = queue.front()
				animation_sprite.play("shoot")
				$Attack_timer.start()
				is_shooting = true
