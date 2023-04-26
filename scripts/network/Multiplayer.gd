extends Control

### Scenes ###
var title
var server_label_scene = load("res://scenes/network/game_server_label.tscn")


### Nodes ###
onready var join_grid = $Frame/TabContainer/JOIN/JoinGrid
onready var loading = $LoadingScreen
onready var loading_label = $LoadingScreen/Label
onready var server_ip_address = $Frame/TabContainer/JOIN/join_ip_address
onready var username = $Frame/username
onready var animation = $AnimationPlayer
onready var color_pick = $Frame/username/UserColor

### Misc ###
var rng = RandomNumberGenerator.new()


func _ready():	
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")

	load_colors()
	load_servers()

func load_colors():
	var color_window = color_pick.get_picker()
	color_window.presets_visible = false
	
	rng.randomize()
	var rand1 = rng.randf_range(0,1)
	var rand2 = rng.randf_range(0,1)
	var rand3 = rng.randf_range(0,1)
	color_pick.color = Color(rand1,rand2,rand3)
	username.add_color_override("font_color", Color(rand1,rand2,rand3))
	
func load_servers():
	### Eventually loop through all servers active
	
	var scene = server_label_scene.instance()
	scene.join_scene = self
	join_grid.add_child(scene)

func update_IP(address):
	server_ip_address.text = address


func _on_Join_Server_pressed():
	if username.text == null or username.text.replace(" ","") == "":
		animation.play("user_flash")
		return
	Network.username = username.text
	Network.usercolor = "#" + color_pick.color.to_html()
#	if server_ip_address.text != "":
	
	loading_label.text = "Joining Server..."
	loading.show()
	yield(get_tree().create_timer(.2),"timeout")
	
	Network.ip_address = server_ip_address.text.replace(" ","")
	Network.join_server()
	title.start_game()
	Global.multiplayer_active = true

#	get_tree().call_group("player","_start_Network_Timer")
	
func _player_connected(_id):
	print("player connected to server")
	
func _player_disconnected(id):
	print(str(id) + " disconnected")

func _connected_to_server():
	print("connected to server")

func _on_color_pick_color_changed(color):
	username.add_color_override("font_color",color)


func _on_X_Button_pressed():
	Global.MAIN.remove_scene("multiplayer_panel",0)


func _on_HostServer_pressed():
	if username.text == null or username.text.replace(" ","") == "":
		animation.play("user_flash")
		return
	
	Network.username = username.text
	Network.usercolor = "#" + color_pick.color.to_html()
	loading_label.text = "Creating Server..."
	loading.show()
	yield(get_tree().create_timer(.2),"timeout")
	
	Network.create_server()
	title.start_game()
	get_tree().call_group("player","_start_Network_Timer")
	Global.multiplayer_active = true
