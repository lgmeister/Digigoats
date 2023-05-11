extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MainVolume_value_changed(value):
	AUDIO.change_volume("main",value)


func _on_MusicVolume_value_changed(value):
	AUDIO.change_volume("music",value)


func _on_EffectsVolume_value_changed(value):
	AUDIO.change_volume("sfx",value)


func _on_X_Button_pressed():
	Global.MAIN.remove_scene("settings",0)
