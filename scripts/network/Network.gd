extends Node

#71.59.130.238

const DEFAULT_PORT = 28960
const MAX_CLIENTS = 6

var server = null
var client = null

var ip_address = ""

### Scenes ###
var goat_scene = load("res://scenes/battles/Character_Fight.tscn")

##### Player Data #####
var username = "Unknown"
var usercolor = Color.red
var players = {} ### who is on the server?

### MISC ###
var rng = RandomNumberGenerator.new()


func _ready() -> void:	
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_to_server")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connection_failed")

	
func create_server() -> void:
	upnp_setup()
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT,MAX_CLIENTS)
	get_tree().set_network_peer(server)
	
	load_goats(Global.goats_to_load,1)
	
	players[get_tree().get_network_unique_id()] = get_player_data()
	print("Connected with this info: ", players)
	set_network_master(get_tree().get_network_unique_id())
	HUD.load_chat()

func get_player_data():
	var player_data = {"username":username,"goats":Global.loaded_goats}
	return player_data
	
func upnp_setup():
	var upnp = UPNP.new()
	var discover_result = upnp.discover()
	
	if discover_result == UPNP.UPNP_RESULT_SUCCESS:
		var gateway = upnp.get_gateway()
		gateway.add_port_mapping(DEFAULT_PORT)
		
		ip_address = upnp.query_external_address()
		print("Started Server on " + ip_address)
		Global.game_ip_address = ip_address
	else:
		print("issue with starting server")
		
	
func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address,DEFAULT_PORT)
	get_tree().set_network_peer(client)
	print("Joining Server " + ip_address)
	Global.game_ip_address = ip_address
	HUD.load_chat()
	HUD.update_network_info()
	
func _connected_to_server() -> void: #clientside loads onto server
	HUD.chat_announcement("Connected")

	players[get_tree().get_network_unique_id()] = get_player_data()
	
	Global.goats_to_load = ["00600"] ### Temp
	set_network_master(get_tree().get_network_unique_id())
	load_goats(Global.goats_to_load,get_tree().get_network_unique_id())
	get_tree().call_group("player","_start_Network_Timer")
	
	rpc("_send_player_info",get_tree().get_network_unique_id(), get_player_data())
	
	HUD.chat_announcement(str("Am I master? ", is_network_master(), "\nmy id is: ",get_tree().get_network_unique_id()))
	
	
func _server_disconnected() -> void:
	print("disconnected")
	
	
func _connection_failed() -> void:
	print("Failed connection")
	

remote func _send_player_info(id,info):
	HUD.chat_announcement("%s has joined the server" %info["username"])

	if get_tree().is_network_server():
		for peer_id in players:
			rpc("_send_player_info", peer_id, players[peer_id])
			
	load_goats(info["goats"],id) ### Loads the new player goats in

	players[id] = info


func load_goats(all_goats,id):
	for goat in all_goats:
		rng.randomize()
		var goat_loc = rng.randi_range(200,600)
		var scene_instance = goat_scene.instance()
		scene_instance.global_position = Vector2(goat_loc,300)
		scene_instance.goat_id = goat
		scene_instance.name = str(id)
		scene_instance.set_network_master(id)
		add_child(scene_instance)
