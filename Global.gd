extends Node

var MAIN
var DEV_MODE = true


const camera_zoom_level = .1

### Network ###
var multiplayer_active = false
var game_ip_address
var game_name


### In Game Bools ###
var input_allowed = true
var in_battle = false
var goat_in_training = false
var title_finished = false ### Has the title screen been used yet?
var shop_open = false
var game_started = false ## Are we actually in the game?

### In Game Misc ###
var battle_scene = false ### Has the battle scene been instanced? IS THIS NEEDED?

var currancy_1 = 999
var goats_to_load = []
var NPCs_to_load = ["blacksmith","redhead","rat","brindle","cinder","trainer"]
var loaded_goats = {}

### Fights ###
var wave_loss = 1 ### Which wave did you lose on?
var minion_deaths = 0
var armor = 0 


### Individual Goat ###
var active_goat
var training_goat

### NPCs ###
var current_dialog
var current_npc

### Scenes ###
var world

#### SETTINGS ####
var music_volume
var sfx_volume

### Goat Attributes ###
var goat_raw = {} ### All data
var goat_body = {}

#########################

func _ready():
	load_goat_data()

func load_goat_data():
	var gen0 = preload("res://resources/goat_data/gen_zero/rarity_zero.csv")
	var gen1 = preload("res://resources/goat_data/gen_one/rarity.csv")

	for data in gen0.records:
		goat_body[str(int(data["ID"]))] = data["Body"]
		goat_raw[str(int(data["ID"]))] = data
	for data in gen1.records:
		goat_body[str(int(data["ID"]))] = data["Body"]

	
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
	

func new_goat_resource():
	for goatID in goats_to_load:
		var goat_path = "res://goats/repo/%s" % str(goatID) + ".tres"  ### Eventually switch to user://
		var new_goat = GOAT.new() 

		yield(SilentWolf.Players.get_player_data(goatID), "sw_player_data_received")
		
		if SilentWolf.Players.player_data.empty(): ## New Goat
			pass
			### Query blockchain for info
		else:
			print(SilentWolf.Players.player_data)
			
			if SilentWolf.Players.player_data["Weapon"] != null:
				new_goat.goat_weapon = load(SilentWolf.Players.player_data["Weapon"])
			if SilentWolf.Players.player_data["Armor"] != null:
				new_goat.goat_armor = load(SilentWolf.Players.player_data["Armor"])
			if SilentWolf.Players.player_data["Headgear"] != null:
				new_goat.goat_armor = load(SilentWolf.Players.player_data["Headgear"])
			if SilentWolf.Players.player_data["Misc"] != null:
				new_goat.goat_armor = load(SilentWolf.Players.player_data["Misc"])
				
		new_goat.image = load("res://goats/images/%s.png" %str(goatID))
		new_goat.goat_color = goat_color(goat_body[str(int(goatID))])

		# warning-ignore:return_value_discarded
		ResourceSaver.save(goat_path,new_goat)

	world.load_goats()
	
func goat_color(type):
	if type == "Red": return Color.red
	elif type == "Orange": return Color.orange
	elif type == "Yellow": return Color.yellow
	elif type == "Green": return Color.green
	elif type == "Blue": return Color.blue
	elif type == "Brown": return Color.chocolate
	elif type == "Pink": return Color.deeppink
	elif type == "Teal": return Color.teal
	elif type == "Purple": return Color.purple
	elif type == "Gray": return Color.gray
	elif type == "Silver": return Color.silver
	elif type == "Gold": return Color.goldenrod
	elif type == "Black and White": return Color.whitesmoke
	elif type == "Christmas": return Color.greenyellow
	elif type == "Digital": return Color.aqua
	elif type == "Fat and Hairy": return Color.saddlebrown
	elif type == "Frozen": return Color.cyan
	elif type == "Anime Blue": return Color.lightblue
	elif type == "Barney": return Color.darkmagenta
	elif type == "Blue Surfer": return Color.darkcyan
	elif type == "Burgundy": return Color.maroon
	elif type == "Burning Red": return Color.crimson
	elif type == "Camo Blue": return Color.cornflower
	elif type == "Dark": return Color.dimgray
	elif type == "Dark Blue": return Color.darkblue
	elif type == "Fire": return Color.firebrick
	elif type == "Gold Shimmer": return Color.gold
	elif type == "Investigative Blue": return Color.lightcyan
	elif type == "Sea Form": return Color.darkturquoise
	elif type == "Wizard Purple": return Color.blueviolet
	elif type == "Zombie Green": return Color.darkolivegreen
	
	else: return Color.black
	
