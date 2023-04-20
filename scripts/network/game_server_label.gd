extends Control

var clicked = false

onready var server_panel = $ServerPanel


func _ready():
	add_to_group("game_servers")


func _unclick_button():
	if clicked == true:
		clicked = false
		server_panel.modulate = Color.white

func _on_Button_pressed():
	get_tree().call_group("game_servers","_unclick_button")
	yield(get_tree().create_timer(.01),"timeout")
	

	server_panel.modulate = Color.yellow
	clicked = true
		
	
	

	
