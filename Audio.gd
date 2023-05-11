extends Control

### Scenes ###
onready var playlist_scene = load("res://scenes/main/Playlist.tscn")

### Nodes ###
var playlist_node
var music_player_node

onready var boost_node

onready var music = $Music
onready var sfx = $SFX
onready var movement = $Movement

var main_volume = 1
var sfx_volume = .5
var music_volume = .5

### Misc ###
var fade_out_time = 1



### Bools ###
var boosting = false

### Misc ###
var music_playlist = []


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
	playlist_node = scene
	add_child(scene)
	music_playlist = playlist_node.make_playlist()

	
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
		music_volume = amount
		if amount == 0: music.volume_db = -80
		else: music.volume_db = db
	elif type == "sfx":
		sfx_volume = amount
		if amount == 0:
			sfx.volume_db = -80
			movement.volume_db = -80
		else:
			sfx.volume_db = db
			movement.volume_db = db
			
func fade_music(type):
	var tween = get_tree().create_tween()
	if type == "inout":
		tween.tween_property(music,"volume_db",-40,fade_out_time)
		tween.tween_property(music,"volume_db",linear2db(music_volume),.5)
	elif type == "out":
		tween.tween_property(music,"volume_db",-40,fade_out_time)
	elif type == "in":
		tween.tween_property(music,"volume_db",linear2db(music_volume),.5)
	elif type == "immediate_in":
		tween.tween_property(music,"volume_db",linear2db(music_volume),.1)
		

func new_player(type,file):
	var audio_node = AudioStreamPlayer.new()
	add_child(audio_node)
	audio_node.stream = playlist_node.get(type)[file]
	if file == "boost": boost_node = audio_node
	audio_node.play()
	yield(audio_node,"finished")
	
	if file == "boost": boosting = false
	
	audio_node.queue_free()

	
func play(file):
	var type = playlist_node.check_type(file)
	
	if file == "boost":
		boosting = true
		new_player(type,file)
		return
		
	if file == "music":
		fade_music("in")
	
	if get(type).playing and type != "music":
		new_player(type,file)
	elif get(type).playing and type == "music":
		music_player_node.music_playing = false
		fade_music("out")
		yield(get_tree().create_timer(fade_out_time),"timeout")
		fade_music("immediate_in")
		get(type).stream = playlist_node.get(type)[file]
		music_player_node.music_playing = true
		get(type).play()
	else:
		get(type).stream = playlist_node.get(type)[file]
		get(type).play()
		
func pause(type):
	if type == "music":
		music.stream_paused = true
	
func resume(type):
	if type == "music":
		music.stream_paused = false	
		

func _on_Music_finished():
	music_player_node.play_next()
