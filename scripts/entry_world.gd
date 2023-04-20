extends Node2D

onready var screen_middle = get_viewport_rect().size/2

var goat_scene = load("res://scenes/battles/Character_Fight.tscn")
var title_scene = load("res://scenes/title.tscn")
var cursor = load("res://visual/GUI/cursors/Arrow_Rounded_Blue.png")

onready var tile_color = $TileCanvasModulate
onready var background = $ParallaxBackground/ParallaxLayer0/background
onready var NPCS = $NPCS
onready var animation = $AnimationPlayer

### Underground ###
onready var portal_progress = $Underworld/portal_area/portal_progress
onready var portal = $Underworld/portal_area
onready var portal_particles = $Underworld/portal_area/portal_particles
onready var tween = $Underworld/UnderworldTween
onready var fight_portal = $Underworld/fight_portal/AnimatedSprite
onready var portal_blocker = $Underworld/fight_portal_stop/CollisionShape2D
var portal_open = false

### Training ###
onready var fog_3 = $Training/fog3
onready var fog_4 = $Training/fog4

### Bridge ###
onready var bridge_front = $Underworld/bridge_front/sprite
onready var bridge_back = $Underworld/bridge_back/sprite
onready var bridge_collision = $Underworld/bridge_back/Ground/Collision

var background_speed = Vector2(.15,0)

var rng = RandomNumberGenerator.new()

func _ready():
	Input.set_custom_mouse_cursor(cursor)
	title()
	Http_Request.request("time")
#	load_goats()
	load_NPCS()
	
	if Global.goat_in_training:
		Global.goat_in_training = false
		
		for goat in get_tree().get_nodes_in_group("goat"):
			if Global.active_goat == goat:
				goat.position = Vector2(-1005,-440)
				GlobalCamera.following_goat = goat
				goat.input_allowed = true
				Global.input_allowed = true
				return
	
	if Global.in_battle:
		Global.in_battle = false
		Global.input_allowed = true
		GlobalCamera.following_goat = null

func _process(_delta):
	
	### Moving background sky
	background.position -= background_speed
	if background.position.x <= -1920:
		background.position = Vector2(0,0)
	
func title():
	if Global.title_finished:
		HUD.animation.play_backwards("black_screen")
		return
	var scene_instance = title_scene.instance()
	HUD.add_child(scene_instance)
	Global.title_finished = true
	
	
func load_goats():
	for goat in Global.goats_to_load:
		rng.randomize()
		var goat_loc = rng.randi_range(200,600)
		spawn_goat(goat, Vector2(goat_loc,300))
		print("Goat spawned")
		
		
func load_NPCS():
	var npc_scene = preload("res://scenes/characters/npc.tscn")
	for npc in Global.NPCs_to_load:
		var scene_instance = npc_scene.instance()
		scene_instance.NPC_id = npc
		add_child(scene_instance)
	
	
func spawn_goat(file_name,loc):
	var scene_instance = goat_scene.instance()
	scene_instance.global_position = loc
	scene_instance.goat_id = file_name
	scene_instance.in_fight = false
	add_child(scene_instance)
	

func _on_fight_area_stop_area_entered(area):
	if "goat" in str(area.get_owner()):
		area.get_owner().gravity = 1000
		area.get_owner().input_allowed = false
		var tween2 = get_tree().create_tween()
		tween2.tween_property(tile_color,"color",Color("2d2d2d"),2)


func _on_reset_gravity_area_entered(area):
	if "goat" in str(area.get_owner()):
		area.get_owner().goat_light.show()
		area.get_owner().gravity = 2000
		area.get_owner().input_allowed = true
		

func _on_water_area_area_entered(area):
	if "goat" in str(area.get_owner()):
		area.get_owner().velocity.y = 100
		area.get_owner().gravity = 50
		area.get_owner().input_allowed = true
		area.get_owner().out_of_fuel()

func _on_out_water_area_area_entered(area):
	if "goat" in str(area.get_owner()):
		area.get_owner().gravity = 2000
		area.get_owner().input_allowed = true


func _on_portal_area_body_entered(body):
	if "TileMap" in str(body):
		return
		
	portal_progress.value = 0
	portal_progress.show()
	
	tween.interpolate_property(portal_progress,"value",portal_progress.value,portal_progress.max_value,1.5)
	tween.start()
	tween.interpolate_property(portal,"modulate",Color(1,1,1,1),Color(1,0,0,1),1.5)
	tween.start()

	portal_particles.speed_scale = 1.5
	
	HUD.animation.play("black_screen")
	yield(HUD.animation,"animation_finished")
# warning-ignore:return_value_discarded
	GlobalCamera.position = Vector2(0,0)
	tile_color.color = Color("c4c4c4")
	HUD.animation.play_backwards("black_screen")
	

func _on_portal_area_body_exited(_body):
	tween.stop_all()
	HUD.animation.stop()
	HUD.black_screen.modulate = Color(0,0,0,0)
	
	portal.modulate = Color(1,1,1,1)
	portal_particles.speed_scale = 1
	portal_progress.hide()
	
func open_fight_portal():
	fight_portal.play("default")
	yield(fight_portal,"animation_finished")
	fight_portal.play("open")
	portal_open = true

func _on_fight_portal_body_entered(body):
	if "goat" in str(body) and portal_open:
		portal_open = false
		Global.active_goat = body
		get_tree().change_scene("res://scenes/battles/single_battle.tscn")
	

func _on_training_area_body_entered(body):
	if "goat" in str(body):
		animation.play("fog")

func _on_training_area_body_exited(body):
	if "goat" in str(body):
		animation.play("fog_out")
