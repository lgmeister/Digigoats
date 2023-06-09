extends Node2D

onready var screen_middle = get_viewport_rect().size/2

var goat_scene = load("res://scenes/battles/Character_Fight.tscn")
var title_scene = load("res://scenes/title.tscn")

onready var tile_color = $TileCanvasModulate
onready var background = $ParallaxBackground/ParallaxLayer0/background
onready var NPCS = $NPCS
onready var animation = $AnimationPlayer

### Underground ###
onready var portal = $Underworld/portal_area
onready var portal_particles = $Underworld/portal_area/portal_particles
var warp_portal_active = false
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

func _ready():
	HUD.set_cursor("normal")
	DialogGlobal.world = self
	Global.world = self
	
	title()	

#	if not Global.multiplayer_active: ## Only load goats if in single player, otherwise network does it
#		load_goats()

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
	if background.position.x <= -1920: ### Fix this
		background.position = Vector2(0,0)


func _input(event):
	if event.is_action_pressed("action"):
		if warp_portal_active: 
			warp_portal_active = false
			
			var tween = get_tree().create_tween()
			tween.tween_property(tile_color,"color",Color.white,.5)
			Global.active_goat.global_position = Vector2(rand_range(200,600),300)
			Global.active_goat.goat_light.hide()
			Global.active_goat.in_underground_area = false
			AUDIO.change_bus("Master")
		elif portal_open: ## battle portal
			Global.active_goat.action_sprite_func("hide")
			AUDIO.change_bus("Master")
			portal_open = false
			var scene = Global.MAIN.load_scene("battle")
			Global.active_goat.goat_light.hide()
			Global.MAIN.hide_scene("entry",1,true)
			Global.MAIN.add_scene(scene,false)
			portal_blocker.disabled = false
			fight_portal.play("close")
			tile_color.color = Color.white
			DialogGlobal.portal_open = false
			HUD.tooltip_bot("hide",null)
		
	
func title():
	if Global.title_finished:
		HUD.animation.play_backwards("black_screen")
		print("here")
		return
	
	Global.active_goat = null
	HUD.reset_goat_grid()
	
	get_tree().call_group("player", "remove_goat")
	var scene = Global.MAIN.load_scene("title")
	print(Global.goats_to_load)
	Global.MAIN.add_scene(scene,true)
	Global.title_finished = true
	animation.play("fog_out")
	
	
func load_goats():
	for goat in Global.goats_to_load:
		var scene_instance = goat_scene.instance()
		scene_instance.global_position = Vector2(rand_range(200,600),300)
		scene_instance.goat_id = goat
		scene_instance.main = self
		scene_instance.in_fight = false
		add_child(scene_instance)
		
		
func load_NPCS():
	var npc_scene = preload("res://scenes/characters/npc.tscn")
	for npc in Global.NPCs_to_load:
		var scene_instance = npc_scene.instance()
		scene_instance.NPC_id = npc
		add_child(scene_instance)
	

func _on_fight_area_stop_area_entered(area):
	if "goat" in str(area.get_owner()):
		area.get_owner().gravity = 1000
		area.get_owner().input_allowed = false
		area.get_owner().in_underground_area = true
		var tween = get_tree().create_tween()
		tween.tween_property(tile_color,"color",Color("2d2d2d"),2)


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
	Global.active_goat.action_sprite_func("show")		
	HUD.tooltip_bot("tip","Press E to Activate...")
	warp_portal_active = true
	portal_particles.speed_scale = 2	


func _on_portal_area_body_exited(_body):	
	HUD.tooltip_bot("hide",null)
	if Global.active_goat != null: 
		Global.active_goat.action_sprite_func("hide")		
	warp_portal_active = false
	portal_particles.speed_scale = 1
	
	
func open_fight_portal():
	fight_portal.play("default")
	yield(fight_portal,"animation_finished")
	fight_portal.play("open")
	

func _on_fight_portal_body_entered(body):
	if Global.in_battle: return
	AUDIO.play("warp_touch")
	portal_open = true
	if "goat" in str(body):
		Global.active_goat.action_sprite_func("show")		
		HUD.tooltip_bot("tip","Press E to Activate...")
		portal_open = true
		
		
func _on_fight_portal_body_exited(_body):
	if Global.in_battle: return
	HUD.tooltip_bot("hide",null)
	Global.active_goat.action_sprite_func("hide")
	portal_open = false


func _on_training_area_body_entered(body):
	if "goat" in str(body):
		body.in_training_area = true
		animation.play("fog")
		AUDIO.change_bus("hollow")

func _on_training_area_body_exited(body):
	if "goat" in str(body):
		body.in_training_area = false
		animation.play("fog_out")
		AUDIO.change_bus("Master")


func _on_fight_area_stop_area_exited(area):
	if "goat" in str(area.get_owner()):
		AUDIO.change_bus("underground")
