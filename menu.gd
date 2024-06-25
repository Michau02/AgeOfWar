extends Node2D
signal playSounds()

var main_scene = preload("res://main.tscn")

func _ready():
	if Global.sound == 1:
		$sound_btn.text = "Sound: on"
		$AudioStreamPlayer.play()
	else:
		$sound_btn.text = "Sound: off"

func _on_sound_btn_pressed():
	Global.sound = !Global.sound
	if !Global.sound:
		$sound_btn.text = "Sound: off"
		Global.sound = 0
		$AudioStreamPlayer.stop()
	else:		
		$sound_btn.text = "Sound: on"
		Global.sound = 1
		$AudioStreamPlayer.play()

func _on_play_btn_pressed():
	get_tree().change_scene_to_packed(main_scene)
