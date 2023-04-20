extends Control

onready var animation = $AnimationPlayer
onready var start_button = $Buttons/Start_Button

var multiplayer_scene = load("res://scenes/network/multiplayer_title.tscn")

signal start_game

func _ready():	
# warning-ignore:return_value_discarded
	connect("start_game",GlobalCamera,"_start_game")


func _on_Multiplayer_pressed():
	var scene_instance = multiplayer_scene.instance()
	scene_instance.title = self
	add_child(scene_instance)


func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	
func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")

func _on_Start_Button_pressed():
	start_game()


func start_game():
	start_button.disabled = true
	emit_signal("start_game")
	animation.play("Fade_Title")
	HUD.tooltip_bot("tip","Press Esc to Skip...")
	yield(animation,"animation_finished")
	HUD.update_network_info()
	queue_free()
