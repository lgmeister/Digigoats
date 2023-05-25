extends Control

onready var animation = $AnimationPlayer
onready var start_button = $Buttons/Start_Button


signal start_game

func _ready():
	HUD.show_HUD_elements(false)
# warning-ignore:return_value_discarded
	connect("start_game",GlobalCamera,"_start_game")
	
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	
	AUDIO.play("title")
	
	## Fix this later ##
#	AUDIO.game_music.volume_db = linear2db(AUDIO.music_volume)
	
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
	HUD.tooltip_bot("tip","Press Esc to Skip...")
	HUD.show_HUD_elements(true)
	Global.MAIN.remove_scene("multiplayer_panel",0)
	Global.MAIN.remove_scene("title",1)
	
	### Load music player ###
	HUD.load_music()
	
func _on_Multi_Button_pressed():
	var scene = Global.MAIN.load_scene("multiplayer_panel")
	Global.MAIN.add_scene(scene,true).title = self


func _on_Settings_Button_pressed():
	var scene = Global.MAIN.load_scene("settings")
	Global.MAIN.add_scene(scene,true)


func _on_Wallet_Button_pressed():
	var scene = Global.MAIN.load_scene("bridge")
	Global.MAIN.add_scene(scene,true)
