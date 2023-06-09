extends KinematicBody2D

export(Resource) var Goat setget _setGoat
export (PackedScene) var weapon = preload("res://scenes/battles/attack.tscn")

### Scenes ###
var goat_profile ## actual profile scene
var fight_scene
var dirt_particle_scene = load("res://scenes/particles/dirt.tscn")
var prize_scene = load("res://scenes/main/FloatingPrize.tscn")
var main

### Nodes ###
onready var sprite = $GoatSprite
onready var raycast = $RayCast2D
onready var raycast2 = $RayCast2D2
onready var raycast3 = $RayCast2D3
onready var raycast_left = $RayCast_left
onready var raycast_right = $RayCast_right

onready var tween = $Tween
onready var goat_light = $Light2D

onready var passive_movement_timer = $PassiveMovementTimer
onready var energy_timer = $EnergyTimer


### Goat info###
var goat_id
var goat_name

var goat_initial_login = {}
var goat_last_login = {}

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

var goat_weapon
var goat_armor
var goat_headgear
var goat_misc

var goat_inventory
var goat_gold

### Movement ###
var gravity = 2000
var speed = 200
var jump_speed = 800
var velocity = Vector2(0,0)
var facing = "right"
var temp_angle = Vector2.ZERO

var hold_movement = 0 ### Automatically hold the direction and speed (for passive movement)
var jumping = false
var jump_count = 0
var flying = false
var hovering = false ### when the goat is touching mouse and you bounce wwhile flying

var max_fuel = 100
var fuel = 0 ## Zero is a full tank, 100 is out of gas

var fall_velocity = 0 ### How fast you are falling to determine landing hardness

onready var animation = $MovementAnimationPlayer
onready var misc_animation = $MiscAnimation
onready var fuel_bar = $GoatSprite/Fuel_Bar

### Attacks ###
var attack_ready = true
var aim_distance = 150
onready var atk_timer = $Attack_Timer

## Bools ##
var in_fight = false ### false if put into main world
var in_training = false 

var in_training_area = false
var in_underground_area = false

var profile_open = false
var input_allowed = false
var alive = true
var network_active = false
var on_ground = true


### Aesthetics ###
onready var headgear = $GoatSprite/headgear
onready var aesthetic_weapon = $GoatSprite/weapon
onready var weapon_strap = $GoatSprite/weapon_strap
onready var action_sprite = $GoatSprite/action_sprite
onready var all_goat_particles = $goat_particles
onready var boost_particles = $GoatSprite/BoostParticles
onready var particle_walk_r = $goat_particles/ParticleWalkR
onready var particle_walk_l = $goat_particles/ParticleWalkL

var goat_particles
var goat_horns
var goat_image
var goat_color

### MISC ###
onready var cursor = $cursor
onready var goat_cam = $Camera2D
var rng = RandomNumberGenerator.new()

### Network Movement ###
onready var network_timer = $Network_Timer
puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_rotation = 0
puppet var puppet_velocity = Vector2.ZERO

onready var network_tween = $NetworkTween

### Energy ###
var energy_rate = 720 ### 720 IN MINUTES to get to full 100 energy (12 hours)
var next_energy_time = 432 ### 720/100*60 IN SECONDS

### Reward ###
var previous_reward_time = {"year":0,"day":0}


func _ready():	
	passive_movement_timer.start(rand_range(0,4))
	add_to_group("player")

	if in_fight or in_training:
		set_collision_layer_bit(0,false)
		set_collision_layer_bit(4,true)
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(4,true)
		set_collision_mask_bit(12,true)
	else:
		set_collision_layer_bit(0,true)
		
	if in_training:
		goat_id = Global.training_goat.goat_id
		input_allowed = true
	else:
		if Global.active_goat != null:
			goat_id = Global.active_goat.goat_id

	self.name = "goat" + goat_id
	self.Goat = load("res://goats/repo/%s.tres" %goat_id)
	
	load_goat()
	load_fuel_bar()
	load_headgear()
	load_weapon()

	
	if in_fight:
		HUD.add_health_bar(goat_max_health,goat_current_health)
		if goat_armor != null: HUD.add_armor_bar(int(goat_armor.armor_class))
		
	if not in_fight and not in_training:
		cursor.self_modulate = Color(goat_color)
		misc_animation.play("cursor")
		HUD.load_goat_grid(self)
	else:
		cursor.hide()
		
	
	
	### REMOVE THIS ###
	load_prize()
	load_prize()
	load_prize()
	###################
	
	### TEST ONLY ####
	yield(get_tree().create_timer(2),"timeout")
	save_goat()	
	######
	

func get_input():
	if not input_allowed: return
	
	if Input.is_action_just_pressed("profile"):
		if profile_open or Global.in_battle or Global.goat_in_training: return
		
		profile_open = true
		
		var scene = Global.MAIN.load_scene("profile")	
		scene.global_position = Vector2(200 * GlobalCamera.zoom.x,
			- 100 * GlobalCamera.zoom.y) + Global.active_goat.global_position
		scene.scale = GlobalCamera.zoom
		scene.which_goat_node = self
		goat_profile = scene
		Global.MAIN.add_scene(scene,false)
		
#		GlobalCamera.zoom = Vector2(.3,.3)
	
	
	if Input.is_action_pressed("ui_right") and not Input.is_action_pressed("boost"):
		move_right()
	elif Input.is_action_pressed("ui_left") and not Input.is_action_pressed("boost"):
		move_left()
	else:
		sprite.playing = false
		particle_walk_l.emitting = false
		particle_walk_r.emitting = false
		
	if Input.is_action_pressed("left_click") and attack_ready:
		attack()
		
	if Input.is_action_just_pressed("ui_left") or\
	Input.is_action_just_pressed("ui_right"):
		if sprite.frame < sprite.frames.get_frame_count(sprite.animation) - 1: sprite.frame += 1
		else: sprite.frame = 0
		
	if Input.is_action_pressed("jump"):
		jumping = true
	else:
		jumping = false
		
	if Input.is_action_just_pressed("jump"):
		
#		jumping = true
		if raycast.is_colliding() or raycast2.is_colliding() or raycast3.is_colliding():
			jump_count = 0
		if jump_count < 2:
			AUDIO.play("jump")
			jump_count += 1
			velocity.y = -jump_speed
			if facing == "right" and jump_count == 2:
				AUDIO.play("spin")
				animation.play("flip")
			elif facing == "left" and jump_count == 2:
				AUDIO.play("spin")
				animation.play("flip backward")
			yield(animation,"animation_finished")
			jumping = false

	if Input.is_action_just_pressed("ui_down"):
		var which_raycast
		if raycast.is_colliding(): which_raycast = raycast
		elif raycast2.is_colliding(): which_raycast = raycast2
		elif raycast3.is_colliding(): which_raycast = raycast3
		else:
			return
		
		
		if "Roof" in which_raycast.get_collider().name:
			var roof
			roof = which_raycast.get_collider()
			roof.set_collision_mask_bit(0,false)
			roof.set_collision_layer_bit(0,false)
			yield(get_tree().create_timer(.3),"timeout")
			roof.set_collision_mask_bit(0,true)
			roof.set_collision_layer_bit(0,true)

	if Input.is_action_just_pressed("boost"):
		jumping = false
		boost_particles.orbit_velocity = 0

	if Input.is_action_pressed("boost"):
		boost_particles.orbit_velocity = 0
		if fuel >= max_fuel: 
			boost_particles.hide()
			out_of_fuel()
			return
			
		if AUDIO.boosting == false: AUDIO.play("boost")
		
		var mouse = get_global_mouse_position()
		if mouse.distance_to(self.position) < 40: 
			flying = false
			hovering = true
			return
		
		hovering = false
		flying = true
		
		var angle: float = self.global_position.angle_to_point(mouse)
		var boost_vector = Vector2(cos(angle), sin(angle))
		
		sprite.playing = false
		sprite.animation = "walk_right"
		sprite.frame = 0
		boost_particles.show()
		self.look_at(mouse)
		velocity.x = -boost_vector.x * speed * 2 * happiness_factor()
		velocity.y = -boost_vector.y * speed * 2 * happiness_factor()
		
		if mouse.x - position.x < 0:
			facing = "left"
			sprite.flip_v = true
			headgear.flip_v = true
			headgear.position = Vector2(14,22)
			fuel_bar.rect_scale = Vector2(1,-1)
			aesthetic_weapon.position = Vector2(-1,4)
			weapon_strap.flip_h = true
			weapon_strap.position = Vector2(-1,-2)
			
		elif mouse.x - position.x > 0:
			facing = "right"
			sprite.flip_v = false
			headgear.flip_v = false
			headgear.position = Vector2(14,-22)
			fuel_bar.rect_scale = Vector2(1,1)
			aesthetic_weapon.position = Vector2(-1,-3)
			weapon_strap.position = Vector2(-1,2)
		
	if Input.is_action_just_released("boost"):
		out_of_fuel()
		
func move_right():
	velocity.x = speed * (goat_dex/20 + .95) * happiness_factor() ### Speed * Goat Dexterity

	facing = "right"
	sprite.playing = true
	sprite.animation = "walk_right"
	fuel_bar.rect_scale = Vector2(1,1)
	headgear.position = Vector2(14,-22)
	headgear.flip_h = true
	weapon_strap.flip_h = false
	
	if on_ground:
		particle_walk_r.emitting = true
#		particle_walk_r.show()
		particle_walk_l.emitting = false
#		particle_walk_l.hide()	
	else:
#		particle_walk_r.hide()
#		particle_walk_l.hide()
		particle_walk_l.emitting = false
		particle_walk_r.emitting = false
	
func move_left():
	velocity.x = -(speed * (goat_dex/20 + .95) * happiness_factor())

	facing = "left"
	sprite.playing = true
	sprite.animation = "walk_left"
	fuel_bar.rect_scale = Vector2(-1,1)
	headgear.position = Vector2(-14,-22)
	headgear.flip_h = false
	weapon_strap.flip_h = true
	
	if on_ground:
#		particle_walk_r.hide()
		particle_walk_r.emitting = false
#		particle_walk_l.show()
		particle_walk_l.emitting = true
	else:
#		particle_walk_r.hide()
#		particle_walk_l.hide()
		particle_walk_l.emitting = false
		particle_walk_r.emitting = false
		
func out_of_fuel():
#	if flying == false:return
	if is_instance_valid(AUDIO.boost_node): AUDIO.boost_node.stop()
	flying = false
	hovering = false
	var mouse = get_global_mouse_position()
	
	self.rotation_degrees = 0
	sprite.flip_v = false
	headgear.flip_v = false
	
	if mouse.x - position.x < 0:
		facing = "left"
		sprite.animation = "walk_left"
		fuel_bar.rect_scale = Vector2(-1,1)
		headgear.position = Vector2(-14,-22)
		headgear.flip_h = false
		aesthetic_weapon.flip_h = false
		aesthetic_weapon.rotation_degrees = 19
		aesthetic_weapon.position = Vector2(-1,-3)
		weapon_strap.position = Vector2(-1,2)
	if mouse.x - position.x > 0:
		facing = "right"
		sprite.animation = "walk_right"
		fuel_bar.rect_scale = Vector2(1,1)
		headgear.position = Vector2(14,-22)
		
	boost_particles.orbit_velocity = 0
	boost_particles.hide()
	
func _process(delta):	
	if not alive: return

	
	if Global.multiplayer_active: ### If this is another player
		if not is_network_master():
			set_physics_process(false)
			return
	
	### Energy ###		
	if not in_fight and not in_training:
		pass		
		
	if raycast.is_colliding() or raycast2.is_colliding() or raycast3.is_colliding():
		if "Ground" or "Dirt" in str(raycast.get_collider())\
		or "Ground" or "Dirt" in str(raycast2.get_collider())\
		or "Ground" or "Dirt" in str(raycast3.get_collider())\
		and on_ground == false:
			on_ground = true
			if fall_velocity >= 800:
				AUDIO.play("thud")
				var scene = dirt_particle_scene.instance()
				add_child(scene)
				scene.emitting = true
			fall_velocity = 0
	else:
		if velocity.y > fall_velocity:
			fall_velocity = velocity.y
		on_ground = false
		
	### Aesthetics ###
#	if not raycast3.is_colliding():
#		if facing == "left": sprite.rotation_degrees = 20
#		else: sprite.rotation_degrees = -20
#	elif not raycast2.is_colliding():
#		if facing == "left": sprite.rotation_degrees = 20
#		else: sprite.rotation_degrees = -20
#	else:
#		sprite.rotation_degrees = 0
		
	####PHYSICS ####
	if not jumping:
		boost_particles.orbit_velocity = 0
	get_input()
	velocity.y += gravity * delta
	
	if not in_fight and not in_training:
		if hold_movement == 1 and self != Global.active_goat:
			set_collision_mask_bit(0,false)
			velocity.x = -50
			check_collision()
		elif hold_movement == 2 and self != Global.active_goat:
			set_collision_mask_bit(0,false)
			velocity.x = 50
			check_collision()
		else:
			set_collision_mask_bit(0,true)
	
	
	if velocity.x > 0:
		velocity.x -= speed * 3 * delta
	elif velocity.x < 0:
		velocity.x += speed * 3 * delta
	else:
		velocity.x = 0
	
	if jumping:
		boost_particles.speed_scale = 4
		if facing == "right" and jump_count == 2: boost_particles.orbit_velocity = 1
		elif facing == "left" and jump_count == 2: boost_particles.orbit_velocity = -1
	else:
		boost_particles.orbit_velocity = 0
		boost_particles.speed_scale = 1
#
	velocity = move_and_slide(velocity,Vector2.UP,true)
	#############

	if Global.multiplayer_active:
		if not is_network_master():
			if not network_tween.is_active():
# warning-ignore:return_value_discarded
				move_and_slide(puppet_velocity * speed)
				
			print(puppet_rotation)
			rotation = puppet_rotation
			return
			
	if fuel > 0 and not flying and not hovering and not Input.is_action_pressed("boost"):
		if not raycast.is_colliding() and\
		not raycast2.is_colliding() and\
		not raycast3.is_colliding(): 
			return
		else:
			fuel -= 50 * delta
			fuel_bar.value = fuel
			
	if flying or hovering:
		fuel += 50 * delta
		fuel_bar.value = fuel
	if fuel < 0: fuel = 0
	if fuel > max_fuel: fuel = max_fuel
	
#### ANIMATION ####	
	if sprite.animation == "walk_right":
		headgear.flip_h = true
		aesthetic_weapon.rotation_degrees = -110
		headgear.rotation_degrees = 0
		if not flying:
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
		if not flying:
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
	
	
	###### DEVELOPER MODE ######
#	if Global.DEV_MODE:
#		goat_current_energy = goat_max_energy

	goat_current_energy = Goat.get_Current_Energy()
	###### DEVELOPER MODE ######
	
	goat_max_happiness = Goat.get_Max_Happiness()
	goat_current_happiness = Goat.get_Current_Happiness()
	
	goat_weapon = Goat.get_Weapon()
	goat_armor = Goat.get_Armor()
	goat_headgear = Goat.get_Headgear()
	goat_misc = Goat.get_Misc()
	
	goat_str = Goat.get_Str()
	goat_dex = Goat.get_Dex()
	goat_wis = Goat.get_Wis()
	
	goat_level = Goat.get_Level()
	goat_exp = Goat.get_Exp()
	goat_next_exp = Goat.get_Next_Exp()

	goat_particles = Goat.get_Particles()
	goat_horns = Goat.get_Horns()
	
	goat_inventory = Goat.get_Inventory()
	goat_gold = Goat.get_Gold()
	

func save_goat():
	print("Saving goat ", goat_id, " Level: ", goat_level)
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
	
	Goat.goat_gold = goat_gold
	print ("saving with ", goat_gold, " goat gold")
	
	
# warning-ignore:return_value_discarded
	ResourceSaver.save("res://goats/repo/%s.tres" %goat_id,self.Goat)
	
	var weapon_path
	var armor_path
	var misc_path
	var headgear_path
	var inventory_paths = []
	
	if goat_weapon != null:
		weapon_path = goat_weapon.get_path()
	if goat_armor != null:
		armor_path = goat_armor.get_path()
	if goat_misc != null:
		misc_path = goat_misc.get_path()
	if goat_headgear != null:
		headgear_path = goat_headgear.get_path()
	if goat_inventory.size() != 0:
		for item in goat_inventory:
			inventory_paths.append(item.get_path())
			
	var time_saved = {
		"day": HUD.day_of_year,
		"hour": HUD.hour,
		"minute":HUD.minute,
		"second":HUD.second
	}
	
	var player_data =\
		{"Weapon":weapon_path, "Armor":armor_path, "Misc":misc_path,
		"Headgear":headgear_path,"Energy":goat_current_energy,
		"Happiness":goat_current_happiness, "Health":goat_current_health,
		"Str":goat_str, "Dex":goat_dex, "Wis": goat_wis, 
		"Exp": goat_exp, "Next_Exp":goat_next_exp, "Level":goat_level,
		"Inventory":inventory_paths,
		"Time_Saved":time_saved, "Previous_Reward":previous_reward_time,
		"Gold":goat_gold}
		
	print("saving previous reward ", previous_reward_time)	
	SilentWolf.Players.post_player_data(goat_id, player_data)
	
	
	
	### This will need to be set to user:// eventually, and same with loading said goat. or just 
	### put on server (which is better)

func load_fuel_bar():
	fuel_bar.max_value = max_fuel
	fuel_bar.value = 0
		
	
func load_goat(): ### Find this in Global
	Global.loaded_goats[goat_id] = {
		"id":goat_id,
		"name":goat_name,
		"image":goat_image,
		"color":goat_color,
		"node":self
		}
		
	sprite.self_modulate = Color(goat_color)
	
	goat_initial_login = {
		"day":HUD.day_of_year,
		"hour":HUD.hour,
		"minute":HUD.minute,
		"second":HUD.second
	}
#	print("Goat initialized at: ", goat_initial_login)
	
	yield(SilentWolf.Players.get_player_data(goat_id), "sw_player_data_received")
#	print("Player data: " + str(SilentWolf.Players.player_data))
	
	var data = SilentWolf.Players.player_data
	
	if data.size() == 0:
		print("Nada")
		return
		
	if "Previous_Reward" in data:
		previous_reward_time = data["Previous_Reward"]
	
	if "Time_Saved" in data:
		goat_last_login = data["Time_Saved"]
#		print("Goat last login was: ", goat_last_login)
		
		var _year_diff = 0
		var day_diff = 0
		var hour_diff = 0
		var min_diff = 0
		var sec_diff = 0
		
		var total_min_diff ### adding seconds, hours, days, etc
		
		if goat_initial_login["day"] - goat_last_login["day"] < 0:
			day_diff = goat_initial_login["day"] + 365 - goat_last_login["day"]
			_year_diff -= 1 ### This is never really used
			push_warning("NEW YEAR")
		else:
			day_diff = goat_initial_login["day"] - goat_last_login["day"]
		
		if goat_initial_login["hour"] - goat_last_login["hour"] < 0:
			hour_diff = goat_initial_login["hour"] + 24 - goat_last_login["hour"]
			day_diff -= 1
		else:
			hour_diff = goat_initial_login["hour"] - goat_last_login["hour"]
		
		if goat_initial_login["minute"] - goat_last_login["minute"] < 0:
			min_diff = goat_initial_login["minute"] + 60 - goat_last_login["minute"]
			hour_diff -= 1
		else:
			min_diff = goat_initial_login["minute"] - goat_last_login["minute"]
		
		if goat_initial_login["second"] - goat_last_login["second"] < 0:
			sec_diff = goat_initial_login["second"] + 60 - goat_last_login["second"]
			min_diff -= 1
		else:
			sec_diff = goat_initial_login["second"] - goat_last_login["second"]

		total_min_diff = (sec_diff/60) + min_diff + (hour_diff*60) + (day_diff*1440)
		
		print("Time Passed in Minutes: ", total_min_diff)
#		print("Time passed -",
#		" Days: ", day_diff,
#		" Hours: ", hour_diff,
#		" Minutes: ", min_diff,
#		" Seconds: ", sec_diff)
		
		
		
		load_energy(total_min_diff)
		check_prize(HUD.year,HUD.day_of_year)
	
	var weapon_path
	var armor_path
	var misc_path
	var headgear_path
	var inventory_paths
	
	if "Weapon" in data: weapon_path = data["Weapon"]
	if "Armor" in data: armor_path = data["Armor"]
	if "Misc" in data: misc_path = data["Misc"]
	if "Headgear" in data: headgear_path = data["Headgear"]
	if "Inventory" in data: inventory_paths = data["Inventory"]
	
	goat_current_energy = data["Energy"]
	goat_current_happiness = data["Happiness"]
	goat_current_health = data["Health"]
	goat_str = data["Str"]
	goat_dex = data["Dex"]
	goat_wis = data["Wis"]
	goat_exp = data["Exp"]
	goat_next_exp = data["Next_Exp"]
	goat_level = data["Level"]
	goat_gold = data["Gold"]
	
	### Add gold to global gold pile ###
	Global.currancy_1 += goat_gold	
	print("adding gold " , goat_gold)
	HUD.tooltip_top("currancy",Global.currancy_1)
		
	if weapon_path != null: goat_weapon = load(weapon_path)
	if armor_path != null: goat_armor = load(armor_path)
	if misc_path != null: goat_misc = load(misc_path)
	if headgear_path != null: goat_headgear = load(headgear_path)
	
	if inventory_paths != null:
		for item in inventory_paths:
#			if "fist" in str(inventory_paths): continue
			goat_inventory.append(load(item))
	
	if not in_fight and not in_training:
		HUD.goat_nodes.append(self)
		
	
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
		
func load_energy(ElapsedMinutes):
	if ElapsedMinutes > energy_rate:
		goat_current_energy = goat_max_energy
		next_energy_time = energy_rate/100.0*60.0 ### /100 energy * 60 seconds per min
		energy_timer.start(1) 
	else:
		var energy_add = stepify(ElapsedMinutes / (energy_rate/100.0), 0.1)
		goat_current_energy += energy_add
		print("Adding ", energy_add, " Energy")

		next_energy_time = (energy_rate/100.0*60.0) - (ElapsedMinutes*60.0)
		
		energy_timer.start(1)
#		print("Next energy in: ", next_energy_time/60," minutes")
		
func attack():
	if not in_fight and not in_training: return
	
	var atk = weapon.instance()
	atk.position = self.global_position
	atk.weapon_choice = goat_weapon
	attack_ready = false
	atk_timer.start(.2)
	atk.fired_from = self
	fight_scene.add_child(atk)
	atk.where_look(get_global_mouse_position())
	
func weapon_hit_player(damage):
	tween.interpolate_property(sprite,"self_modulate",Color(1,0,0),
								Color(goat_color),.2,Tween.TRANS_LINEAR)
	tween.start()
	if Global.armor == 0: goat_current_health -= damage ## If not armor, lose health
	
	for _number in range(damage):
		if Global.armor != 0:
			get_tree().call_group("armor","lose_heart")
			Global.armor -= 1
			AUDIO.play("armor_hit")
		elif Global.armor == 0:
			get_tree().call_group("heart","lose_heart")
			AUDIO.play("hurt")

	if goat_current_health <= 0 and alive:
		death()
		goat_current_health = 1
		save_goat()


func death():
	alive = false
	
	all_goat_particles.hide()
	boost_particles.hide()
	get_tree().call_group("armor","disappear_all")
	get_tree().call_group("heart","disappear_all")
	
	HUD.boss_bar("out",null)
	
	animation.play("death")
	HUD.announcement("Defeat","long")
	AUDIO.stop("game_music")
	AUDIO.play("goat_death")
	AUDIO.play("defeat_music")
	yield(HUD.animation,"animation_finished")
	get_tree().call_group("attack","queue_free")
	Global.MAIN.remove_scene("battle",4)
	Global.MAIN.hide_scene("entry",4,false)
	HUD.animation.play("black_screen")
	yield(HUD.animation,"animation_finished")
	HUD.animation.play_backwards("black_screen")
	HUD.set_cursor("normal")
	GlobalCamera.smoothing_enabled = true
	HUD.remove_health_bar()
	HUD.show_HUD_elements(true)
	AUDIO.resume("music")
	
	Global.in_battle = false
	Global.active_goat.input_allowed = true
	Global.input_allowed = true
	Global.active_goat.global_position = Vector2(rand_range(200,600),300)

	
	
func check_collision():
	var random = rng.randi_range(0,2)
	
	if raycast_left.is_colliding():
		if random == 0: ### Jump
			sprite.play("walk_left")
			velocity.y = -jump_speed
			hold_movement = 1
		else:
			sprite.play("walk_right")
			hold_movement = 2
			
		raycast_left.enabled = false
		passive_movement_timer.start(2)
		yield(get_tree().create_timer(4),"timeout")
		raycast_left.enabled = true
		
	if raycast_right.is_colliding():
		if random == 0: #JUMP
			sprite.play("walk_right")
			velocity.y = -jump_speed
			hold_movement = 2
		else:
			sprite.play("walk_left")
			hold_movement = 1
			
		raycast_right.enabled = false
		passive_movement_timer.start(2)
		yield(get_tree().create_timer(4),"timeout")
		raycast_right.enabled = true

	
func _on_Attack_Timer_timeout():
	attack_ready = true
	
func action_sprite_func(type):
	if type == "show":
		action_sprite.show()
	else:
		action_sprite.hide()
	
func activate_goat():
	if self == Global.active_goat:
		input_allowed = true
	else:
		input_allowed = false
		passive_movement_timer.start(rand_range(1,5))

func _on_goat_button_pressed():
	if Global.multiplayer_active:
		if not is_network_master(): return
		if Global.in_battle: return
	select_goat()


func select_goat():
	Global.active_goat = self
	get_tree().call_group("player","activate_goat")
	get_tree().call_group("hud_goat","unselect",self)
	misc_animation.stop()
	misc_animation.play("cursor")
	AUDIO.play("bubble_select")
	
	if in_training_area:
		main.animation.play("fog",-1,3)
		main.tile_color.color = Color.white		
	elif in_underground_area:
		main.tile_color.color = Color("2d2d2d")
		main.animation.play("fog_out")
		main.animation.seek(1,true)
	else:
		main.animation.play("fog_out")
		main.animation.seek(1,true)
		main.tile_color.color = Color.white		
	

func _start_Network_Timer():
	network_timer.start(.05)
	network_active = true

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	network_tween.interpolate_property(self, "global_position", global_position, puppet_position, .05)
	network_tween.start()


func _on_Network_Timer_timeout():
	if is_network_master():
		rset_unreliable("puppet_position", global_position)
#		rset_unreliable("puppet_velocity", velocity)
		rset_unreliable("puppet_rotation", sprite.rotation)
		
func update_stats():
	pass


func _on_PassiveMovementTimer_timeout():
	if self == Global.active_goat or Global.in_battle or Global.goat_in_training: return
	
	if in_training_area or in_underground_area: 
		hold_movement = 0
		return
		
	rng.randomize()
	var choice = rng.randi_range(0,3)
	if choice == 0:
		sprite.play("walk_right")
		hold_movement = 2
	elif choice == 1:
		sprite.play("walk_left")	
		hold_movement = 1
	elif choice == 2:
		sprite.play("eat_left")	
		hold_movement = 0
	elif choice == 3:
		sprite.play("eat_right")	
		hold_movement = 0
	passive_movement_timer.start(rand_range(1,5))

	
func warp_out():
	animation.play("warp_out")
	AUDIO.play("warp_out")
	action_sprite_func("hide")
	
func happiness_factor():
	var happiness = 1
	if goat_current_happiness < 70:
		happiness = goat_current_happiness/float(70)
		if happiness <= .3: happiness = .3	
	
	return happiness

func _on_EnergyTimer_timeout():
	next_energy_time -= 1
	
	if next_energy_time <= 0:
		goat_current_energy += 1
		if is_instance_valid(Global.MAIN.loaded_scenes["profile"]):
			Global.MAIN.loaded_scenes["profile"].update_bars("instant")
		next_energy_time = energy_rate/100.0*60.0 
		
		
	if goat_current_energy > goat_max_energy:
		goat_current_energy = goat_max_energy
		
	if next_energy_time > energy_rate:
		next_energy_time = energy_rate/100.0*60.0 

func check_prize(year,day_of_year):
	var day = day_of_year
	if int(year) > int(previous_reward_time["year"]): ### New year
		day = day_of_year + 365
	if int(day) > int(previous_reward_time["day"]):
		load_prize()


func load_prize():
	var scene = prize_scene.instance()
	scene.goat_node = self
	scene.position = Vector2(rand_range(-300,2000),rand_range(100,-300))
	Global.MAIN.add_child(scene)
	previous_reward_time = {"year":HUD.year,"day":HUD.day_of_year}
	
func remove_goat():
	if network_active:
		if not Network.is_network_master(): return
		
	Global.goats_to_load.erase(goat_id)
	print(goat_id, "   ---   ", Global.goats_to_load)
	self.queue_free()
