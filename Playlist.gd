extends Node


### MUSIC ###
var music = {
	
}


### SFX ###

var sfx = {
	
}

### Movement ###
var movement = {
	"jump":"res://resources/audio/movement/jump.wav"
	
	}

func _ready():
	load_all_sounds()


func load_all_sounds():
	print(movement)
	for audio in movement:
		movement[audio] = load(movement[audio])
		
	print(movement)


func check_type(file):
	var type
	
	if file in music: type = "music"
	elif file in sfx: type = "sfx"
	elif file in movement: type = "movement"
	
	return type
