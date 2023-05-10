extends Control

### Scenes ###
onready var playlist_scene = load("res://scenes/main/Playlist.tscn")

### Nodes ###
var playlist
onready var music = $Music
onready var sfx = $SFX
onready var movement = $Movement


var main_volume = 5
var sfx_volume = 5
var music_volume = 5




func _ready():
	print("Audio Player Active")
	load_playlist()

func load_playlist():
	var scene = playlist_scene.instance()
	playlist = scene
	add_child(scene)


func new_player(type,file):
	print("Creating temp player")
	var audio_node = AudioStreamPlayer.new()
	add_child(audio_node)
	audio_node.stream = playlist.get(type)[file]
	audio_node.play()
	yield(audio_node,"finished")
	print("removing temp player")
	audio_node.queue_free()

	
func play(file):
	var type = playlist.check_type(file)
	if type == "music":
		if music.playing:
			new_player(type,file)
		else:
			music.stream = playlist.file
			music.play()
	elif type == "sfx":
		if sfx.playing:
			new_player(type,file)
		else:
			sfx.stream = playlist.file
			music.play()
	elif type == "movement":
		if movement.playing:
			new_player(type,file)
		else:
			movement.stream = playlist.get(type)[file]
			movement.play()
	
