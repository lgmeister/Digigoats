extends Node2D

#### Load Scenes ###
var goat_scene = load("res://scenes/battles/Character_Fight.tscn")

### Nodes ###
var goat_node

### Misc ###
onready var spawn_point = $spawn_point

func _ready():
	load_goat()


func load_goat():
	var scene_instance = goat_scene.instance()
	scene_instance.in_fight = true
	scene_instance.position = Vector2(200,300)
	scene_instance.fight_scene = self
	goat_node = scene_instance
	spawn_point.add_child(scene_instance)
	
