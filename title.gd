extends Control

onready var animation = $AnimationPlayer
onready var start_button = $Buttons/Start_Button
onready var multi_button = $Buttons/Multi_Button
onready var wallet_button = $Buttons/Wallet_Button
onready var buttons = $Buttons
onready var update = $Update


var headers = ["X-Master-Key:$2b$10$PpCK9hebSlugKnT4JXEps.4g6t79anBTAEbPB66L0GnsiSzKuGww.","Content-Type:application/json"]

signal start_game

func _ready():
	buttons.hide()
	HUD.show_HUD_elements(false)
	
	if not check_update(): return
	
	
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
	scene.title_scene = self
	Global.MAIN.add_scene(scene,true)
	
func load_ingame_goats(): ### After goats are loaded from wallet
	Global.new_goat_resource()
	
	start_button.show()
	multi_button.show()
	wallet_button.hide()
	
func check_update():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed",self,"_version_check_completed")
	http_request.request("https://api.jsonbin.io/v3/b/648398b6b89b1e2299ac82e4/latest",headers)
	
	
func _version_check_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var version = (json.result["record"]["version"])
	if version == Global.version:
		buttons.show()
		return true
	else:
		update.show()
		return false


func _on_updateButton_pressed():
	OS.shell_open("https://ergoat.com/digigoat")

