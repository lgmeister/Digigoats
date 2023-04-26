extends Control

onready var animation = $AnimationPlayer
onready var start_button = $Buttons/Start_Button


### Scenes ###
var multi_scene = load("res://scenes/UIUX/Multiplayer.tscn")


signal start_game

func _ready():
# warning-ignore:return_value_discarded
	connect("start_game",GlobalCamera,"_start_game")
	
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")


func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	
func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")

func _on_Start_Button_pressed():
	start_game()


func _on_Create_Server_pressed():
	Network.create_server()


func start_game():
	start_button.disabled = true
	emit_signal("start_game")
	animation.play("Fade_Title")
	HUD.tooltip_bot("tip","Press Esc to Skip...")
	yield(animation,"animation_finished")
	queue_free()
	
func _on_Multi_Button_pressed():
	var scene = multi_scene.instance()
	scene.title = self
	add_child(scene)
