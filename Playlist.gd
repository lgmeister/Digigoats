extends Node


### MUSIC ###
var music = {
	"title":"res://resources/audio/music/AcidJazz.mp3"
}


### SFX ###

var sfx = {
	"announcement":"res://resources/audio/sfx/announcement.wav", 
	"box_explode":"res://resources/audio/sfx/box_explode.wav", 
	"denied":"res://resources/audio/sfx/denied.wav", 
	"reveal":"res://resources/audio/sfx/reveal.wav", 
	"select":"res://resources/audio/sfx/select.wav", 
	"warp_out":"res://resources/audio/sfx/warp_out.wav", 
	"weird":"res://resources/audio/sfx/weird.wav",
	"werid_2":"res://resources/audio/sfx/weird_2.wav",
	"pop":"res://resources/audio/sfx/pop.wav",
	"pickup":"res://resources/audio/sfx/pickup.wav",
	"buy": "res://resources/audio/sfx/buy.wav",
	"thud":"res://resources/audio/sfx/thud.wav"
}

### Movement ###
var movement = {
	"jump":"res://resources/audio/movement/jump.wav",
	"spin":"res://resources/audio/movement/spin.wav",
	"boost_start":"res://resources/audio/movement/boost_start.wav",
	"walk":"res://resources/audio/movement/walk.wav"
	}

### Loops ###
var loops = {
	"boost":"res://resources/audio/movement/boost.wav"
}

func _ready():
	load_all_sounds()


func load_all_sounds():
	for audio in movement:
		movement[audio] = load(movement[audio])
	for audio in loops:
		loops[audio] = load(loops[audio])
	for audio in sfx:
		sfx[audio] = load(sfx[audio])
	for audio in music:
		music[audio] = load(music[audio])
		
		
func check_type(file):
	var type
	
	if file in music: type = "music"
	elif file in sfx: type = "sfx"
	elif file in movement: type = "movement"
	elif file in loops: type = "loops"
	
	return type
