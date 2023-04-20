extends Node2D

export var follow_mouse = false

func _process(delta):
	if follow_mouse:
		position = get_global_mouse_position()
