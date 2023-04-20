tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	add_custom_type("SpriteMask", "Node2D", preload("res://addons/sprite_mask/SpriteMask.gd"), preload("res://addons/sprite_mask/sm_icon.png"))

func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("SpriteMask")
