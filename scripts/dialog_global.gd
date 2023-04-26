extends Node

var main

var npc_name

var bridge = true ### true means its there
var trainer_met = false
var weapon_met = false

func get_npc_name():
	npc_name = Global.current_npc.NPC_name

func open_portal():
	main.open_fight_portal()
	main.portal_blocker.disabled = true

func open_shop():
	var shop_scene = preload("res://scenes/Shop.tscn")
	var scene_instance = shop_scene.instance()
	scene_instance.which_goat_node = Global.active_goat
	scene_instance.which_npc_node = Global.current_npc
	HUD.add_child(scene_instance)
	
func open_training():
	var training_scene = preload("res://scenes/training/Training_Menu.tscn")
	var scene_instance = training_scene.instance()
	scene_instance.which_npc_node = Global.current_npc
	HUD.add_child(scene_instance)
	
func bridge_function(type):
	main = get_tree().get_root().get_node("entry_world")
	if type == "hide":
		main.animation.play("bridge")
		yield(main.animation,"animation_finished")
		main.bridge_collision.disabled = true
	else:
		main.animation.play_backwards("bridge")
		yield(main.animation,"animation_finished")
		main.bridge_collision.disabled = false
