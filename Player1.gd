extends Node
signal updateGoldP1
signal add_gold(player, reward_gold, reward_exp)

@onready var HUD_progressBarAnimation = get_node("/root/Main/Camera2D/HUD/left_side/ProgressBar/ColorRect/AnimationPlayer")
@onready var HUD_progressBar = get_node("/root/Main/Camera2D/HUD/left_side/ProgressBar/ColorRect")
@onready var HUD_Queue_Label= get_node("/root/Main/Camera2D/HUD/left_side/Queue/Label")
@onready var HUD_Queue_NextEntity_icon= get_node("/root/Main/Camera2D/HUD/left_side/Queue/NextEntity_icon")
@onready var HUD_Gold = get_node("/root/Main/Camera2D/HUD/left_side/Gold_Exp_control/Gold_label")
@onready var turret_marker = get_node("res//player_base.tscn")

var gold : int
var exp
var age
var nextAgeExpNeeded = [4000, 12000]
var queue = []

var unit1_cost = Global.unit1_cost[0]
var unit2_cost = Global.unit2_cost[0]
var unit3_cost = Global.unit3_cost[0]
var turret_cost = Global.turret_cost
var turret_sell = Global.turret_sell

var turret
var base_scene

func _ready():
	gold = 200
	exp = 0
	age = 1
	if !queue.is_empty():
		queue.clear()

	base_scene = preload("res://player_base.tscn").instantiate()
	base_scene.position = Vector2i(190, 440)
	base_scene.player = 1
	add_child(base_scene)
	base_scene.show()
	
func _process(delta):
	if Input.is_action_just_pressed("unit1_P1"):
		spawn_unit(1)
	elif Input.is_action_just_pressed("unit2_P1"):
		spawn_unit(2)
	elif Input.is_action_just_pressed("unit3_P1"):
		spawn_unit(3)
	elif Input.is_action_just_pressed("buildTurret_P1"):
		build_turret()
	elif Input.is_action_just_pressed("sellTurret_P1"):
		sell_turret()
	elif Input.is_action_just_pressed("NextAge_P1"):
		next_age()
	if queue.size() == 0:
		HUD_progressBar.size.x = 0

func spawn_unit(type):
	if queue.size() < 5:
		if type == 1:
			if gold >= unit1_cost:
				gold -= unit1_cost
				if HUD_Queue_NextEntity_icon.texture.get_path() == "res://art/hud/blank_space.png":
					HUD_Queue_NextEntity_icon.texture = preload("res://art/unit_icons/Unit1_icon.png")
				queue.push_back(type)
				if $Unit3_timer.is_stopped() and $Unit1_timer.is_stopped():
					if HUD_progressBarAnimation.is_playing():
						HUD_progressBarAnimation.stop()
					HUD_progressBarAnimation.play("short_animation")
					$Unit1_timer.start()	
		elif type == 2:
			if gold >= unit2_cost:
				gold -= unit2_cost
				if HUD_Queue_NextEntity_icon.texture.get_path() == "res://art/hud/blank_space.png":
					HUD_Queue_NextEntity_icon.texture = preload("res://art/unit_icons/Unit2_icon.png")
				queue.push_back(type)
				if $Unit3_timer.is_stopped() and $Unit1_timer.is_stopped():
					if HUD_progressBarAnimation.is_playing():
						HUD_progressBarAnimation.stop()
					HUD_progressBarAnimation.play("short_animation")
					$Unit1_timer.start()	
		else: 
			if gold >= unit3_cost:
				gold -= unit3_cost
				if HUD_Queue_NextEntity_icon.texture.get_path() == "res://art/hud/blank_space.png":
					HUD_Queue_NextEntity_icon.texture = preload("res://art/unit_icons/Unit3_icon.png")
				queue.push_back(type)
				if $Unit3_timer.is_stopped() and $Unit1_timer.is_stopped():
					if HUD_progressBarAnimation.is_playing():
						HUD_progressBarAnimation.stop()
					HUD_progressBarAnimation.play("long_animation")
					$Unit3_timer.start()	
		HUD_Gold.text = "x " + str(gold)
		if queue.size() == 5:
			HUD_Queue_Label.text = "x " + str(queue.size()) + " (max)"
		else:
			HUD_Queue_Label.text = "x " + str(queue.size())
				
func build_turret():
	if turret == null and gold >= turret_cost[age-1]:
		gold -= turret_cost[age-1]
		emit_signal("add_gold", 1, -turret_cost[age-1], 0)
		turret = preload("res://turret.tscn").instantiate()
		turret.position = base_scene.marker_position + base_scene.position
		turret.player = 1
		turret.age = age
		turret.connect("unit_killed", _on_unit_killed)
		add_child(turret)
		turret.show()
	elif turret != null and gold >= turret_cost[1] - turret_cost[0]:
		emit_signal("add_gold", 1, -(turret_cost[1] - turret_cost[0]), 0)
		turret.updateStats()

func sell_turret():
	if turret != null:
		gold += turret_sell[age-1]
		emit_signal("add_gold", 1, turret_sell[age-1], 0)
		turret.queue_free()
		

func next_age():
	if !nextAgeExpNeeded.is_empty() and exp >= nextAgeExpNeeded.pop_front() and age < 2:
		age += 1
		unit1_cost = Global.unit1_cost[1]
		unit2_cost = Global.unit2_cost[1]
		unit3_cost = Global.unit3_cost[1]
		turret_cost = Global.turret_cost[1]
		turret_sell = Global.turret_sell[1]
		base_scene.sprite.texture = preload("res://art/castle_age2.png")
		base_scene.update_stats()
		
func _on_gold_timer_timeout():
	gold += 1
	updateGoldP1.emit()

func _on_unit_1_timer_timeout():
	if queue.is_empty():
		return

	var t = queue.pop_front()		
	
	var new_unit
	if t == 1:
		new_unit = preload("res://unit_1.tscn").instantiate()
	elif t == 2:
		new_unit = preload("res://unit_2.tscn").instantiate()
		
	new_unit.player = 1
	new_unit.position = Vector2(220, 525)
	new_unit.age = age
	new_unit.connect("unit_killed", _on_unit_killed)
	add_child(new_unit)
	new_unit.show()
	
	HUD_Queue_Label.text = "x " + str(queue.size())

	set_icon()

func _on_unit_3_timer_timeout():
	if queue.is_empty():
		return
	var t = queue.pop_front()
	var new_unit
	if t == 3:
		new_unit = preload("res://unit_3.tscn").instantiate()
	
	new_unit.player = 1
	new_unit.position = Vector2(220, 560)
	new_unit.age = age
	add_child(new_unit)
	new_unit.connect("unit_killed", _on_unit_killed)
	new_unit.show()
	
	HUD_Queue_Label.text = "x " + str(queue.size())
	
	set_icon()
	
func _on_unit_killed(player, gold_reward, exp_reward):
	if player == 1:
		gold += gold_reward
		exp += exp_reward
		emit_signal("add_gold", 1, gold_reward, exp_reward)

func set_icon():
	if !queue.is_empty():
		if HUD_progressBarAnimation.is_playing():
			HUD_progressBarAnimation.stop()
		
		if queue[0] == 3:
			HUD_Queue_NextEntity_icon.texture = preload("res://art/unit_icons/Unit3_icon.png")
			HUD_progressBarAnimation.play("long_animation")
			$Unit3_timer.start()
		else: 
			if queue[0] == 1:
				HUD_Queue_NextEntity_icon.texture = preload("res://art/unit_icons/Unit1_icon.png")
			else:
				HUD_Queue_NextEntity_icon.texture = preload("res://art/unit_icons/Unit2_icon.png")
			HUD_progressBarAnimation.play("short_animation")
			$Unit1_timer.start()
	else:
		HUD_Queue_NextEntity_icon.texture = preload("res://art/hud/blank_space.png")
