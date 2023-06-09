extends Control

### Scenes ###
onready var playlist_scene = load("res://scenes/main/Playlist.tscn")

### Nodes ###
var playlist_node
var music_player_node

onready var boost_node

onready var music = $Music
onready var game_music = $GameMusic
onready var sfx = $SFX
onready var movement = $Movement
onready var ui = $ui

var main_volume = 1
var sfx_volume = .5
var music_volume = .5
var game_music_volume = .5
var ui_volume = .5

### Misc ###
var fade_out_time = 1
var temp_pitch_alteration := 0



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
	elif type == "game_music":
		game_music_volume = amount
		if amount == 0: game_music_volume.volume_db = -80
		else: game_music_volume.volume_db = db
		
		
	elif type == "sfx":
		sfx_volume = amount
		if amount == 0:
			sfx.volume_db = -80
			movement.volume_db = -80
		else:
			sfx.volume_db = db
			movement.volume_db = db
			
func fade_music(type,style):
	var tween = get_tree().create_tween()
	if style == "inout":
		tween.tween_property(type,"volume_db",-80,fade_out_time)
		tween.tween_property(type,"volume_db",linear2db(music_volume),.5)
	elif style == "out":
		tween.tween_property(type,"volume_db",-80,fade_out_time)
	elif style == "in":
		tween.tween_property(type,"volume_db",linear2db(music_volume),.5)
	elif style == "immediate_in":
		tween.tween_property(type,"volume_db",linear2db(music_volume),.1)
		

func new_player(type,file):
	var audio_node = AudioStreamPlayer.new()
	add_child(audio_node)
	if type == "attack":
		audio_node.stream = file
	elif type == "dialog":
		audio_node.stream = file
		audio_node.pitch_scale += rand_range(-.1,.1) + Global.current_npc.NPC_talk_pitch
	else:
		audio_node.stream = playlist_node.get(type)[file]
		if file == "boost": boost_node = audio_node
		
	audio_node.play()
	yield(audio_node,"finished")
	
	if not type == "attack" and not type == "dialog":
		if file == "boost": boosting = false
	
	audio_node.queue_free()

	
func play(file):
	var type = playlist_node.check_type(file)
	
	if type == "game_music":
		if music.playing: 
			music_player_node.music_playing = false
			pause("music")
		
	
	if file == "boost":
		boosting = true
		new_player(type,file)
		return
	
#	print(file, type)
	
	if type == "music":
#		if game_music.playing: game_music.stop()
		fade_music(game_music,"out")
		
		resume("music")
	elif type == "game_music":
		fade_music(game_music,"immediate_in")
		
	
	if get(type).playing and type != "music" and type != "game_music":
		new_player(type,file)
	elif get(type).playing and type == "music":
		if game_music.playing: game_music.playing = false
		music_player_node.music_playing = false
		fade_music(music,"out")
		yield(get_tree().create_timer(fade_out_time),"timeout")
		fade_music(music,"immediate_in")
		get(type).stream = playlist_node.get(type)[file]
		music_player_node.music_playing = true
		music_player_node.update_labels()
		get(type).play()
	elif type == "game_music":
		if music.playing: music.playing = false
		print(music.playing)
		get(type).stream = playlist_node.get(type)[file]
		get(type).play()
	else:
		get(type).stream = playlist_node.get(type)[file]
		get(type).play()
		
func stop(type):
	if type == "game_music":
		game_music.stop()
		
func play_attack(file):
	new_player("attack",file)
	
func play_dialog(file,pitch_alt):
	temp_pitch_alteration = pitch_alt
	new_player("dialog",file)
		
func pause(type):
	if type == "music":
		music.stream_paused = true
	elif type == "game_music":
		game_music.stream_paused = true
	
func resume(type):
	if type == "music":
		music.stream_paused = false	
		music_player_node.music_playing = true
		
	elif type == "game_music":
		game_music.stream_paused = false
		

func _on_Music_finished():
	music_player_node.play_next()
	
func change_bus(type):
	if type == "Master":
		music.pitch_scale = 1
	elif type == "hollow":
		music.pitch_scale = .97
	elif type == "underground":
		pass
		
	music.set_bus(type)
	
