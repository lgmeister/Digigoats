extends Node

onready var entry_scene = load("res://scenes/entry_world.tscn")
onready var title_scene = load("res://scenes/title.tscn")

func _ready():
	Global.MAIN = self
	load_scene("entry",false)


func load_scene(chosen_scene,add_to_hud):
	var scene
	if chosen_scene == "entry":
		scene = entry_scene.instance()
	elif chosen_scene == "title":
		scene = title_scene.instance()
	
	if add_to_hud:
		HUD.add_child(scene)
	else:
		add_child(scene)
