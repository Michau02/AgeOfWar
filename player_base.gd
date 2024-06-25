extends Node2D

var health
var max_hp
var player

@onready var hp_bar = $Health/hp
@onready var hp_label = $Health/Label
var marker_position
var hp_bar_size
var sprite

func _ready():
	add_to_group("bases")
	health = Global.base_health[0]
	max_hp = health
	hp_bar_size = hp_bar.size.y
	sprite = $Sprite2D
	$Health/Label.text = str(health)
	if player == 2:
		$Health/Label.position.x = -$Health/Label.position.x - $Health/Label.size.x/2
		$Health/hpbar.position.x = -$Health/hpbar.position.x + $Health/hpbar.size.x/2
		$Health/hp.position.x = -$Health/hp.position.x + $Health/hp.size.x/2
		$Marker2D.position.x *= -1
		
	marker_position = $Marker2D.position

func update_stats():
	health = (float(health)/float(max_hp))*Global.base_health[1]
	max_hp = Global.base_health[1]
	hp_bar.size.y = (health/float(max_hp)) * hp_bar_size
	$Health/Label.text = str(health)
