extends Node2D

var menu_scene = preload("res://menu.tscn")

func _ready():
	if Global.sound == 1:
		$AudioStreamPlayer.play()

func _on_go_to_menu_btn_pressed():
	get_tree().change_scene_to_packed(menu_scene)
