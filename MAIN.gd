extends Node

onready var entry_scene = load("res://scenes/entry_world.tscn")
onready var title_scene = load("res://scenes/title.tscn")
onready var multi_panel_scene = load("res://scenes/UIUX/Multiplayer.tscn")

onready var all_scenes = {
	"entry":entry_scene,
	"title":title_scene,
	"multiplayer_panel":multi_panel_scene
}

var loaded_scenes = {}


func _ready():
	Global.MAIN = self
	create_loaded_scene_dictionary()
	load_scene("entry",false)

func create_loaded_scene_dictionary():
	for entry in all_scenes:
		loaded_scenes[entry] = null


func load_scene(chosen_scene,add_to_hud):
	var scene = all_scenes[chosen_scene].instance()
	loaded_scenes[chosen_scene] = scene
	
	if add_to_hud:
		HUD.add_child(scene)
	else:
		add_child(scene)
	return scene


func remove_scene(chosen_scene,duration):
	if loaded_scenes[chosen_scene] == null: return
	
	var scene = loaded_scenes[chosen_scene]
	var tween = get_tree().create_tween()
	tween.tween_property(scene,"modulate",Color.transparent,duration)
	yield(tween,"finished")
	
	scene.queue_free()
	loaded_scenes[chosen_scene] = null


func hide_scene(chosen_scene,duration,hide):
	if loaded_scenes[chosen_scene] == null: return
	
	var scene = loaded_scenes[chosen_scene]
	var tween = get_tree().create_tween()
	if hide:
		tween.tween_property(scene,"modulate",Color.transparent,duration)
		yield(tween,"finished")
		scene.hide()
	else:
		tween.tween_property(scene,"modulate",Color.white,duration)
		yield(tween,"finished")
		scene.show()
		

