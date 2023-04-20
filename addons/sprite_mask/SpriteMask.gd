tool
extends Node2D

export(Texture) var mask_texture = preload("res://addons/sprite_mask/DefaultMask.png") setget mask_texture_set

export(Vector2) var size = Vector2(1024, 600) setget size_set
export(Vector2) var mask_position = Vector2(0,0) setget mask_pos_set
export(float) var mask_scale = 1.0 setget mask_scale_sat

export(bool) var follow_mouse = false setget follow_mouse_set
export(bool) var show_trail = false setget show_trail_set

export(int, LAYERS_2D_RENDER) var layers_to_show = 1 setget layers_to_show_set


var sm_scene;


#func _get_property_list():
#	var properties = []
#	properties.append({
#		name = "Sprite Mask",
#		type = TYPE_NIL,
#		hint_string = "sm_",
#		usage = PROPERTY_USAGE_GROUP| PROPERTY_USAGE_SCRIPT_VARIABLE
#	})
#	return properties

func _init():
	if get_child_count() == 0:
		var sm = load("res://addons/sprite_mask/SpriteMask.tscn").instance()
		add_child(sm)
		sm_scene = sm

func mask_texture_set(val):
	mask_texture = val
	sm_scene.update_mask_texture(val)

func size_set(val):
	size = val
	sm_scene.update_size(val)

func mask_pos_set(val):
	mask_position = val
	sm_scene.update_mask_pos(val)

func follow_mouse_set(val):
	follow_mouse = val
	sm_scene.update_follow_mouse(val)

func mask_scale_sat(val):
	mask_scale = val
	sm_scene.update_mask_scale(val)

func show_trail_set(val):
	show_trail = val
	sm_scene.update_show_trail(val)

func layers_to_show_set(val):
	layers_to_show = val
	sm_scene.update_mask_layers(val)
