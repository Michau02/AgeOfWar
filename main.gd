extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _ready():
	if Global.sound == 1:
		$AudioStreamPlayer.play()
