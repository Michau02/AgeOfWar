extends Camera2D

var SPEED_SCROLL = 12

func _ready():
	$HUD.position -= Vector2(576, 324)
	var player1 = get_node("../Player1").connect("add_gold", updateGold)
	var player2 = get_node("../Player2").connect("add_gold", updateGold)

func _process(delta):
	if (get_viewport().get_mouse_position().x >= (get_viewport().size.x - get_viewport().size.x/40) and position.x <= 1513) or (Input.is_action_pressed("move_right") and position.x <= 1513):
		position.x += SPEED_SCROLL
	elif (get_viewport().get_mouse_position().x <= get_viewport().size.x/40 and position.x >= 576) or (Input.is_action_pressed("move_left") and position.x >= 576):
		position.x -= SPEED_SCROLL
	
func _on_player_1_update_gold_p_1():
	var gold = $HUD/left_side/Gold_Exp_control/Gold_label.text.substr(2)
	$HUD/left_side/Gold_Exp_control/Gold_label.text = "x " + str(int(gold) + 1)

func _on_player_2_update_gold_p_2():
	var gold = $HUD/right_side/Gold_Exp_control/Gold_label.text
	$HUD/right_side/Gold_Exp_control/Gold_label.text = "x " + str(int(gold) + 1)

func updateGold(player, gold_reward, exp_reward):
	if player == 1:
		var gold = $HUD/left_side/Gold_Exp_control/Gold_label.text.substr(2)
		$HUD/left_side/Gold_Exp_control/Gold_label.text = "x " + str(int(gold) + gold_reward)
		
		var exp = $HUD/left_side/Gold_Exp_control/Exp_label.text.substr(2)
		$HUD/left_side/Gold_Exp_control/Exp_label.text = "x " + str(int(exp) + exp_reward)
	else:
		var gold = $HUD/right_side/Gold_Exp_control/Gold_label.text
		$HUD/right_side/Gold_Exp_control/Gold_label.text = "x " + str(int(gold) + gold_reward)
		
		var exp = $HUD/right_side/Gold_Exp_control/Exp_label.text.substr(2)
		$HUD/right_side/Gold_Exp_control/Exp_label.text = "x " + str(int(exp) + exp_reward)
