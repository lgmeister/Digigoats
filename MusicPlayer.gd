extends Control


### Nodes ###
onready var panel = $Panel
onready var song_title = $Panel/SongTitle
onready var song_image = $Panel/SongImage
onready var play_button = $Panel/PlayButton
onready var song_progress = $Panel/SongProgress
onready var animation = $AnimationPlayer
onready var song_length = $Panel/SongLength
onready var song_time = $Panel/SongTime


### Bools ###
var expanded = false
var mouse_inside = false
var music_playing = false
var paused = false
var mouse_in_seek = false ### Is the mouse in the seek bar


### Music ###
var music_playlist

var song_index = -1
var paused_time = 0


func _ready():
	AUDIO.music_player_node = self
	
	music_playlist = AUDIO.music_playlist 
	music_playlist.shuffle()
	reset_labels()
	play_next()
	


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
			
	if music_playing:
		var position = AUDIO.music.get_playback_position()
		song_progress.value = position
		var minutes = floor(song_progress.value/60)
		var seconds = (song_progress.value/60 - minutes) * 60
	
		song_time.text = str("%01d:%02d") %[minutes,floor(seconds)]
	
	
func _input(event):
	if event.is_action_pressed("left_click") and mouse_in_seek:
		var seek_percent = song_progress.get_local_mouse_position().x/song_progress.rect_size.x
		print(AUDIO.music.is_playing())
		AUDIO.music.seek(AUDIO.music.get_stream().get_length() * seek_percent)
		print(seek_percent)
		

func play_next():
	song_index += 1
	if song_index + 1 > music_playlist.size(): song_index = 0
	reset_labels()
	AUDIO.play(music_playlist[song_index])


	
func play_previous():
	song_index -= 1
	if song_index < 0: song_index = 0
	reset_labels()
	AUDIO.play(music_playlist[song_index])
	

func reset_labels():
	song_time.text = "0:00"
	song_length.text = "0:00"
	song_title.text = music_playlist[song_index]
	song_progress.value = 0
	
	
func update_labels():
	song_progress.value = 0
	var length = AUDIO.music.stream.get_length()
	song_progress.max_value = length
	
	var minutes = floor(length/60)
	var seconds = (length/60 - minutes) * 60
	
	song_length.text = str("%01d:%02d") %[minutes,floor(seconds)]


func _on_NextSongButton_pressed():
	play_next()

func _on_PreSongButton_pressed():
	play_previous()


func _on_PlayButton_pressed():
	if paused:
		AUDIO.resume("music")
		paused = false
	else:
		AUDIO.pause("music")
		paused = true


func _on_SongProgress_mouse_entered():
	mouse_in_seek = true
	


func _on_SongProgress_mouse_exited():
	mouse_in_seek = false
