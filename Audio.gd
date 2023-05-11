extends Control

### Scenes ###
onready var playlist_scene = load("res://scenes/main/Playlist.tscn")

### Nodes ###
var playlist
onready var boost_node

onready var music = $Music
onready var sfx = $SFX
onready var movement = $Movement

var main_volume = 5
var sfx_volume = 5
var music_volume = 5

### Bools ###
var boosting = false


func _ready():
	print("Audio Player Active")
	load_playlist()
	
	
	### Put into Settings ###
	AudioServer.set_bus_mute(0,false)
	AudioServer.set_bus_volume_db(0,0)
	sfx.volume_db = -6
	movement.volume_db = -6
	music.volume_db = -6
	
	

func load_playlist():
	var scene = playlist_scene.instance()
	playlist = scene
	add_child(scene)
	
func change_volume(type,amount):
	var db = linear2db(amount)
	
	if type == "main":
		main_volume = amount
		if amount == 0:
			AudioServer.set_bus_mute(0,true)
		else:
			AudioServer.set_bus_mute(0,false)
			AudioServer.set_bus_volume_db(0,db)
	elif type == "music":
		if amount == 0: music.volume_db = -80
		else: music.volume_db = db
	elif type == "sfx":
		if amount == 0:
			sfx.volume_db = -80
			movement.volume_db = -80
		else:
			sfx.volume_db = db
			movement.volume_db = db
			

func new_player(type,file):
	var audio_node = AudioStreamPlayer.new()
	add_child(audio_node)
	audio_node.stream = playlist.get(type)[file]
	if file == "boost": boost_node = audio_node
	audio_node.play()
	yield(audio_node,"finished")
	
	if file == "boost": boosting = false
	
	audio_node.queue_free()

	
func play(file):
	var type = playlist.check_type(file)
	
	if file == "boost":
		boosting = true
		new_player(type,file)
		return
	
	if get(type).playing:
		new_player(type,file)
	else:
		get(type).stream = playlist.get(type)[file]
		get(type).play()
		
		

