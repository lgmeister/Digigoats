extends KinematicBody2D

export(Resource) var Goat setget _setGoat

var random = RandomNumberGenerator.new()

onready var screen_middle = get_viewport_rect().size/2


### Movement
var gravity = 1000
var velocity = Vector2(0,0)
var waittime = 3
var jump_cooldown_wait = 10

onready var camera = GlobalCamera
onready var timer = $Movement_Timer
onready var raycast = $raycasts/RayCast
onready var raycast_forward = $raycasts/RayCastForward
onready var raycast_back = $raycasts/RayCastBack
onready var jump_cooldown = $Jump_Cooldown
onready var jump_cooldown_active = false

### Nodes ###
onready var glow_shader = $GoatSprite.get_material()
onready var collision = $goat_collision
onready var sprite = $GoatSprite
onready var headgear = $GoatSprite/headgear
onready var aesthetic_weapon = $GoatSprite/weapon
onready var weapon_strap = $GoatSprite/weapon_strap
onready var main = get_tree().get_root().get_node("entry_world")


### Load in ###
var cursor = load("res://visual/GUI/cursors/Arrow_Rounded_Blue.png")
var profile = preload("res://scenes/Profile.tscn")
var goat_profile ## actual profile scene
var goat_id

### Bools ###
var clicked = false
var pinned = false
var player_controlled = false
var camera_follow = false


var moving_goat

### Goat Info ###
var goat_name
var goat_image
var goat_color

var goat_weapon
var goat_armor
var goat_headgear
var goat_misc

var goat_current_health
var goat_max_health

var goat_current_energy
var goat_max_energy

var goat_current_happiness
var goat_max_happiness

var goat_str
var goat_dex
var goat_wis
var goat_exp
var goat_next_exp
var goat_level

var goat_inventory

### Aesthetics ###
var goat_particles
var goat_horns


func _ready():
	add_to_group("goat")
	
	self.Goat = load("res://goats/repo/%s.tres" %goat_id)
	load_goat()
	self.name = "goat" + goat_id
	timer.start()
	
	## TEMP FOR TESTING ##
	goat_current_energy = 100
	######################
	
	load_moving_goat()

	
func _physics_process(delta):
	if not player_controlled:
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector2.UP)
	if player_controlled:
		pass


func _process(_delta):
	if camera_follow:
		camera.position = moving_goat.position - screen_middle * camera.zoom
		
	
	if not player_controlled:
		if raycast_forward.is_colliding():
			if "Ground" in raycast_forward.get_collider().name:
				moveit(-30,gravity)
				sprite.play("walk_left")
		elif raycast_back.is_colliding():
			if "Ground" in raycast_back.get_collider().name:
				moveit(30,gravity)
				sprite.play("walk_right")
			
	if sprite.animation == "walk_right":
		headgear.flip_h = true
		aesthetic_weapon.rotation_degrees = -110
		headgear.rotation_degrees = 0
		if sprite.frame == 0 or sprite.frame == 2:
			headgear.position = Vector2(14,-22)
			aesthetic_weapon.position = Vector2(-1,-3)
			weapon_strap.position = Vector2(-1,2)
		elif sprite.frame == 1:
			headgear.position = Vector2(13,-21)
			aesthetic_weapon.position = Vector2(-2,-2)
			weapon_strap.position = Vector2(-2,3)
		else:
			headgear.position = Vector2(14,-21)
			aesthetic_weapon.position = Vector2(-1,-2)
			weapon_strap.position = Vector2(-1,3)
			
	elif sprite.animation == "walk_left":
		headgear.flip_h = false
		aesthetic_weapon.rotation_degrees = 19
		headgear.rotation_degrees = 0
		if sprite.frame == 0 or sprite.frame == 2:
			headgear.position = Vector2(-14,-22)
			aesthetic_weapon.position = Vector2(-1,-3)
			weapon_strap.position = Vector2(-1,2)
		elif sprite.frame == 1:
			headgear.position = Vector2(-14,-21)
			aesthetic_weapon.position = Vector2(-1,-2)
			weapon_strap.position = Vector2(-1,3)
		else:
			headgear.position = Vector2(-14,-21)
			aesthetic_weapon.position = Vector2(-1,-2)
			weapon_strap.position = Vector2(-1,3)
			
		
	elif sprite.animation == "eat_right":
		headgear.flip_h = true
		aesthetic_weapon.rotation_degrees = -110
		aesthetic_weapon.position = Vector2(-1,-3)
		weapon_strap.position = Vector2(-1,2)
		if sprite.frame == 0 or sprite.frame >= 12:
			headgear.position = Vector2(14,-21)
			headgear.rotation_degrees = 0
		elif sprite.frame == 1 or sprite.frame == 11:
			headgear.position = Vector2(21,-8)
			headgear.rotation_degrees = 10
		elif sprite.frame == 2 or sprite.frame == 10:
			headgear.position = Vector2(28,-1)
			headgear.rotation_degrees = 37.5
		else:
			headgear.position = Vector2(32,4)
			headgear.rotation_degrees = 60
			
	elif sprite.animation == "eat_left":
		headgear.flip_h = false
		aesthetic_weapon.rotation_degrees = 19
		aesthetic_weapon.position = Vector2(-1,-3)
		weapon_strap.position = Vector2(-1,2)
		if sprite.frame == 0 or sprite.frame >= 12:
			headgear.position = Vector2(-14,-21)
			headgear.rotation_degrees = 0
		elif sprite.frame == 1 or sprite.frame == 11:
			headgear.position = Vector2(-21,-8)
			headgear.rotation_degrees = -10
		elif sprite.frame == 2 or sprite.frame == 10:
			headgear.position = Vector2(-28,-1)
			headgear.rotation_degrees = -37.5
		else:
			headgear.position = Vector2(-32,4)
			headgear.rotation_degrees = -60
	

func _setGoat(newGoat : Resource):
	Goat = newGoat
	
	goat_name = Goat.get_Name()
	goat_image = Goat.get_Image()
	goat_color = Goat.get_Color()
	
	goat_current_health = Goat.get_Current_Health()
	goat_max_health = Goat.get_Max_Health()
	goat_max_energy = Goat.get_Max_Energy()
	goat_current_energy = Goat.get_Current_Energy()
	goat_max_happiness = Goat.get_Max_Happiness()
	goat_current_happiness = Goat.get_Current_Happiness()
	
	goat_weapon = Goat.get_Weapon()
	goat_armor = Goat.get_Armor()
	goat_headgear = Goat.get_Headgear()
	goat_misc = Goat.get_Misc()
	
	goat_str = Goat.get_Str()
	goat_dex = Goat.get_Dex()
	goat_wis = Goat.get_Wis()
	
	goat_exp = Goat.get_Exp()
	goat_next_exp = Goat.get_Next_Exp()
	
	goat_inventory = Goat.get_Inventory()
	
	goat_particles = Goat.get_Particles()
	goat_horns = Goat.get_Horns()
	
func load_moving_goat():
#	Global.active_goat = goat_id
#	Global.controlling_goat = self
#	player_controlled = true
#	camera_follow = true
	
#	set_collision_mask_bit(0,false)
#	set_collision_layer_bit(0,false)
	
	var goat_scene = preload("res://scenes/battles/Character_Fight.tscn")
	var scene_instance = goat_scene.instance()
	scene_instance.position = self.position
	scene_instance.in_fight = false
	scene_instance.goat_id = goat_id
	main.add_child(scene_instance)
	
	if sprite.animation == "walk_right": scene_instance.sprite.animation = "walk_right"
	else: scene_instance.sprite.animation = "walk_left"
	
#	moving_goat = scene_instance
#	self.hide()
	
#	yield(get_tree().create_timer(.1),"timeout")
#	camera.smoothing_enabled = false
	
	
func unload_moving_goat():
	clicked = false
	Global.active_goat = null
	Global.controlling_goat = null
	player_controlled = false
	camera_follow = false
	camera.smoothing_enabled = true
	camera.position = moving_goat.position - screen_middle
	
	set_collision_mask_bit(0,true)
	set_collision_layer_bit(0,true)
	
	self.position = moving_goat.position
	moving_goat.queue_free()
	self.show()


func save_goat():
	Goat.goat_weapon = goat_weapon
	Goat.goat_armor = goat_armor
	Goat.goat_misc = goat_misc
	Goat.goat_headgear = goat_headgear
	Goat.goat_current_energy = goat_current_energy
	Goat.goat_current_happiness = goat_current_happiness
	Goat.goat_current_health = goat_current_health

	Goat.goat_str = goat_str
	Goat.goat_dex = goat_dex
	Goat.goat_wis = goat_wis
	Goat.goat_exp = goat_exp
	Goat.goat_next_exp = goat_next_exp
	Goat.goat_level = goat_level

	print("goat saved character")
	
# warning-ignore:return_value_discarded
	ResourceSaver.save("res://goats/repo/%s.tres" %goat_id,self.Goat)
	### This will need to be set to user:// eventually, and same with loading said goat. or just 
	### put on server (which is better)
	
func load_goat():
	Global.loaded_goats[goat_id] = {"id":goat_id,"name":goat_name,
									"image":goat_image,"color":goat_color}
	sprite.self_modulate = goat_color
	load_headgear()
	load_weapon()
	if goat_particles != null:
		add_child(goat_particles.instance())
	if goat_horns != null:
		pass

func load_headgear():
	if goat_headgear == null:
		headgear.texture = null
	elif goat_headgear != null:
		headgear.texture = goat_headgear.Item_Icon

func load_weapon(): ### aesthtic only
	if goat_weapon == null:
		aesthetic_weapon.texture = null
		weapon_strap.hide()
	elif goat_weapon.Item_Name == "Goat Fists":
		aesthetic_weapon.texture = null
		weapon_strap.hide()
	else:
		aesthetic_weapon.texture = goat_weapon.Item_Icon
		weapon_strap.show()
	

func _on_goat_button_pressed():
	if clicked:
		return

	clicked = true
	
	if Global.controlling_goat != null: Global.active_goat.unload_moving_goat()
	
	load_moving_goat()
	Global.active_goat = goat_id


func _input(event):
	if player_controlled and event.is_action_pressed("escape") and Global.input_allowed:
		unload_moving_goat()
		Input.set_custom_mouse_cursor(cursor)
	
	if !clicked:
		return
		
	if event.is_action_pressed("escape"):
		clicked = false
#		glow_shader.set_shader_param("on",false)
		
	if event.is_action("ui_page_up"):
		GlobalCamera.zoom_in()
	elif event.is_action("ui_page_down"):
	   GlobalCamera.zoom_out()
	

func _on_Movement_Timer_timeout():
	if pinned:
		return
		
	random.randomize()
	var randommove = random.randi_range(1,5)
	if self.position.x >= 1700:
		randommove = 2
	elif self.position.x <= 200:
		randommove = 1
	else:
		pass
		
	if randommove == 1:
		moveit(30,gravity)
		sprite.play("walk_right")
	elif randommove == 2:
		moveit(-30,gravity)
		sprite.play("walk_left")
	elif randommove == 3:
		pass
	elif randommove == 4:
		moveit(0,gravity)
		sprite.play("eat_left")
	elif randommove == 5:
		moveit(0,gravity)
		sprite.play("eat_right")

func moveit(x,y):
	velocity = Vector2(x,y)
	random.randomize()
	waittime = random.randf_range(3,7)
	timer.set_wait_time(waittime)

func pin_goat():
	if pinned == false:
		pinned = true
		velocity = Vector2.ZERO
		sprite.stop()
	else:
		pinned = false
		
func _on_forward_collision_area_body_entered(body):
	if "Ground" in body.name and not jump_cooldown_active:
		random.randomize()
		var jump = random.randf_range(400,600)
		var sideways = 0
		
		if sprite.animation == "walk_left":
			sideways = -30
		if sprite.animation == "walk_right":
			sideways = 30
		
		moveit(sideways,-jump)
	
		jump_cooldown.wait_time = jump_cooldown_wait
		jump_cooldown.start()
		jump_cooldown_active = true
		
	elif "Ground" in body.name and jump_cooldown_active:
		if sprite.animation == "walk_left":
			moveit(30,gravity)
			sprite.play("walk_right")
		if sprite.animation == "walk_right":
			moveit(-30,gravity)
			sprite.play("walk_left")

func _on_Jump_Cooldown_timeout():
	jump_cooldown_active = false
