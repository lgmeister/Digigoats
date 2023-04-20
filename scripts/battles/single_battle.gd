extends Node2D

var goat_scene = preload("res://scenes/battles/Character_Fight.tscn")
var enemy_scene = preload("res://scenes/battles/Enemy_Fight.tscn")

onready var temptimer = $TempTimer
onready var spawn = $SpawnPoint
onready var tile_color = $Tilemaps/CanvasModulate
onready var portal_progress = $portal_area/portal_progress
onready var portal = $portal_area
onready var portal_particles = $portal_area/portal_particles
onready var tween = $Tween
var portal_open = false

var battle_name = "battle_1"

var goat_node

var temp_deaths ### Initializing number of spawned mobs
var temp_less_mobs = 0 ### how many less mobs are being summoned

var rng = RandomNumberGenerator.new()

func _ready():
	Global.in_battle = true
	Global.controlling_goat = null
	
	temp_deaths = Global.minion_deaths
	
	load_goat()
	set_camera()	
	get_lowest_minion(Global.minion_deaths,false)
	

func get_lowest_minion(number,_recheck): ### Finding the closest thing in battlescript
#	var temp_script = BattleScript.get(battle_name).keys()
	var local_script
	
	if BattleScript.get(battle_name).has(number):
		local_script = BattleScript.get(battle_name)[number]
#		local_script[1] -= temp_less_mobs
		load_enemy(local_script[0], local_script[1])
		
		if number == 0:
			HUD.announcement("WAVE 1","short")
		else:
			if str(local_script[2]) != "boss":
				HUD.announcement("WAVE " + str(local_script[2]),"short")
		
	else:
		temp_deaths -= 1
		Global.minion_deaths -= 1
#		temp_less_mobs += 1
		get_lowest_minion(temp_deaths,false)
	

			
#	if not recheck and number != 0: get_lowest_minion(temp_deaths,true)
	
func set_camera():
	goat_node.goat_cam.current = false
	GlobalCamera.current = true
	GlobalCamera.zoom = Vector2(1,1)
	GlobalCamera.position = Vector2(0,0)
	
func load_goat():
	var scene_instance = goat_scene.instance()
	scene_instance.in_fight = true
	scene_instance.position = Vector2(200,300)
	scene_instance.fight_scene = self
	goat_node = scene_instance
	add_child(scene_instance)
	
func load_enemy(monster,number):
	yield(get_tree().create_timer(1),"timeout") ### Delay between annoucement and spawn
	
	for _n in range(number):
		rng.randomize()
		var random = rng.randi_range(-50,50)
		var scene_instance = enemy_scene.instance()
		scene_instance.position = spawn.position + Vector2(random,random)
		scene_instance.enemy_load = monster
		scene_instance.player = goat_node
		add_child(scene_instance)
		temptimer.start(.1)
		yield(temptimer,"timeout")

func _on_enemy_death():
	Global.minion_deaths += 1
	
	if Global.minion_deaths in BattleScript.get(battle_name):
		var local_script = BattleScript.get(battle_name)[Global.minion_deaths]
		load_enemy(local_script[0], local_script[1])
		if str(local_script[2]) != "boss":
			HUD.announcement("WAVE " + str(local_script[2]),"short")
	

func _on_Character_collided(enemy,collision):
	if collision.collider is TileMap and "Ledges" in str(collision.collider) and enemy.destroy_terrain:
		var tile_pos = collision.collider.world_to_map(enemy.position)
		tile_pos -= collision.normal  # Colliding tile
#		var tile = collision.collider.get_cellv(tile_pos)

### OH GOD PLEASE MAKE MORE EFFICIENT SOMEDAY!!! ####
		### Feet
		collision.collider.set_cell(tile_pos.x, tile_pos.y +1, -1)
		collision.collider.set_cell(tile_pos.x, tile_pos.y +2, -1)
		
		### Side
		collision.collider.set_cell(tile_pos.x, tile_pos.y, -1)
		collision.collider.set_cell(tile_pos.x, tile_pos.y-1, -1)
	
		### Head
		collision.collider.set_cell(tile_pos.x, tile_pos.y -1, -1)
		collision.collider.set_cell(tile_pos.x, tile_pos.y -2, -1)
		collision.collider.set_cell(tile_pos.x+1, tile_pos.y -1, -1)
		collision.collider.set_cell(tile_pos.x-1, tile_pos.y -2, -1)
		collision.collider.set_cell(tile_pos.x, tile_pos.y -1, -2)
		collision.collider.set_cell(tile_pos.x, tile_pos.y -2, -2)
		collision.collider.set_cell(tile_pos.x+1, tile_pos.y -1, -2)
		collision.collider.set_cell(tile_pos.x-1, tile_pos.y -2, -2)


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
	tile_color.color = Color("c4c4c4")
	GlobalCamera.smoothing_enabled = true
	HUD.remove_health_bar()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/entry_world.tscn")
	

func _on_portal_area_body_exited(_body):
	tween.stop_all()
	HUD.animation.stop()
	HUD.black_screen.modulate = Color(0,0,0,0)
	
	portal.modulate = Color(1,1,1,1)
	portal_particles.speed_scale = 1
	portal_progress.hide()
	
func fight_finished():
	portal.show()
	portal.monitoring = true
	
