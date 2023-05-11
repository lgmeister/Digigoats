extends Control


### Nodes ###
onready var panel = $Panel
onready var song_title = $Panel/SongTitle
onready var song_image = $Panel/SongImage
onready var play_button = $Panel/PlayButton
onready var song_progress = $Panel/SongProgress
onready var animation = $AnimationPlayer

### Bools ###
var expanded = false
var mouse_inside = false

### Music ###
var music_playlist


# Called when the node enters the scene tree for the first time.
func _ready():
	AUDIO.music_playlist = music_playlist
	print(music_playlist)


func _process(_delta):
	if get_local_mouse_position().y < 0\
	or get_local_mouse_position().x > self.rect_size.x:
		if expanded:
			animation.play("retract")
			expanded = false
	elif get_local_mouse_position().y > 0:
		if not expanded:
			animation.play_backwards("retract")
			expanded = true


	
