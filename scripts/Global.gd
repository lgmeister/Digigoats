extends Node

var MAIN
var DEV_MODE = true

const camera_zoom_level = .1



### Network ###
var multiplayer_active = false
var game_ip_address
var game_name


### In Game ###
var input_allowed = true
var in_battle = false
var battle_scene = false ### Has the battle scene been instanced?
var title_finished = false ### Has the title screen been used yet?
var goat_in_training = false

var currancy_1 = 999

var shop_open = false

var goats_to_load = ["00300","00800"]
var NPCs_to_load = ["blacksmith","redhead","rat","brindle","cinder","trainer"]
var loaded_goats = {}

### Fights ###
var minion_deaths = 0
var armor = 0 


### Individual Goat ###
var active_goat
var training_goat



### NPCs ###
var current_dialog
var current_npc


#### SETTINGS ####
var music_volume
var sfx_volume


func load_settings():
	var file = File.new()
	if file.file_exists("user://settings.save"):
		file.open("user://settings.save", File.READ)
		var settings = file.get_var()
		music_volume = settings["music"]
		sfx_volume = settings["SFX"]
		file.close()
	else:
		music_volume = -15
		sfx_volume = -15
		save_settings()
		
func save_settings():
	var file = File.new()
	file.open("user://settings.save", File.WRITE)
	var settings = {"music":music_volume, "SFX":sfx_volume}
	file.store_var(settings)
	file.close()


#########################
