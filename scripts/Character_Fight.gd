extends KinematicBody2D

export(Resource) var Goat setget _setGoat
export (PackedScene) var weapon = preload("res://scenes/battles/attack.tscn")

### Scenes ###
var goat_profile ## actual profile scene
var fight_scene

### Goat info###
onready var sprite = $GoatSprite
onready var raycast = $RayCast2D
onready var raycast2 = $RayCast2D2
onready var raycast3 = $RayCast2D3
onready var tween = $Tween

onready var goat_light = $Light2D

var goat_id
var goat_name

#var goat_hp
#var goat_max_hp

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


### Movement ###
var gravity = 2000
var speed = 200
var jump_speed = 800
var velocity = Vector2(0,0)
var facing = "right"
var temp_angle = Vector2.ZERO

var jumping = false
var jump_count = 0
var flying = false
var hovering = false ### when the goat is touching mouse and you bounce wwhile flying

var max_fuel = 100
var fuel = 0 ## Zero is a full tank, 100 is out of gas

onready var animation = $MovementAnimationPlayer
onready var misc_animation = $MiscAnimation
onready var fuel_bar = $GoatSprite/Fuel_Bar

### Attacks ###
var cross_hair = preload("res://visual/character/crosshair/convergence-target.png")
var attack_ready = true
var aim_distance = 150
onready var atk_timer = $Attack_Timer

## Bools ##
var in_fight = false ### false if put into main world
var in_training = false 
var profile_open = false
var input_allowed = false
var alive = true
var network_active = false

### Aesthetics ###
onready var headgear = $GoatSprite/headgear
onready var aesthetic_weapon = $GoatSprite/weapon
onready var weapon_strap = $GoatSprite/weapon_strap
onready var action_sprite = $GoatSprite/action_sprite
onready var all_goat_particles = $goat_particles
onready var boost_particles = $GoatSprite/BoostParticles


### MISC ###
onready var cursor = $cursor
onready var goat_cam = $Camera2D

### Network Movement ###
onready var network_timer = $Network_Timer
puppet var puppet_position = Vector2() setget puppet_position_set
puppet var puppet_rotation = 0
puppet var puppet_velocity = Vector2.ZERO

onready var network_tween = $NetworkTween


var goat_particles
var goat_horns
var goat_image
var goat_color

func _ready():
	add_to_group("player")

	if in_fight or in_training:
		Input.set_custom_mouse_cursor(cross_hair)
		set_collision_layer_bit(0,false)
		set_collision_layer_bit(4,true)
		set_collision_mask_bit(0,false)
		set_collision_mask_bit(4,true)
		set_collision_mask_bit(12,true)
	
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
		
	if not in_fight or not in_training:
		cursor.self_modulate = Color(goat_color)
		misc_animation.play("cursor")

func get_input():
	if not input_allowed: return
	
	
	if Input.is_action_just_pressed("profile"):
		if profile_open: return
		if Global.in_battle: return
		
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
		velocity.x = speed
		facing = "right"
		sprite.playing = true
		sprite.animation = "walk_right"
		fuel_bar.rect_scale = Vector2(1,1)
		headgear.position = Vector2(14,-22)
		headgear.flip_h = true
		weapon_strap.flip_h = false
	elif Input.is_action_pressed("ui_left") and not Input.is_action_pressed("boost"):
		velocity.x = -speed
		facing = "left"
		sprite.playing = true
		sprite.animation = "walk_left"
		fuel_bar.rect_scale = Vector2(-1,1)
		headgear.position = Vector2(-14,-22)
		headgear.flip_h = false
		weapon_strap.flip_h = true		
	else:
		sprite.playing = false
		
	if Input.is_action_pressed("left_click") and attack_ready:
		attack()
		
	if Input.is_action_just_pressed("ui_left") or\
	Input.is_action_just_pressed("ui_right"):
		if sprite.frame < sprite.frames.get_frame_count(sprite.animation) - 1: sprite.frame += 1
		else: sprite.frame = 0
		
	if Input.is_action_just_pressed("jump"):
		jumping = true
		if raycast.is_colliding() or flying:
			jump_count = 0
		if jump_count < 2:
			jump_count += 1
			velocity.y = -jump_speed
			if facing == "right" and jump_count == 2:
				animation.play("flip")
			elif facing == "left" and jump_count == 2:
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
		velocity.x = -boost_vector.x * speed * 2
		velocity.y = -boost_vector.y * speed * 2
		
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
		
func out_of_fuel():
#	if flying == false:return
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
		
	####PHYSICS ####
	boost_particles.orbit_velocity = 0
	get_input()
	velocity.y += gravity * delta
	
	if velocity.x > 0:
		velocity.x -= speed * 3 * delta
	elif velocity.x < 0:
		velocity.x += speed * 3 * delta
	else:
		velocity.x = 0
	
	if jumping:
		boost_particles.speed_scale = 4
		if facing == "right": boost_particles.orbit_velocity = 1
		else: boost_particles.orbit_velocity = -1
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
	

func _setGoat(newGoat : Resource):
	Goat = newGoat
	
	goat_name = Goat.get_Name()
	goat_image = Goat.get_Image()
	goat_color = Goat.get_Color()
	goat_weapon = Goat.get_Weapon()
#	goat_max_hp = Goat.get_Max_Health()
#	goat_hp = Goat.get_Health()
	
	goat_current_health = Goat.get_Current_Health()
	goat_max_health = Goat.get_Max_Health()
	goat_max_energy = Goat.get_Max_Energy()
	
	if Global.DEV_MODE: goat_current_energy = goat_max_energy
	else: goat_current_energy = Goat.get_Current_Energy()
	
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

	goat_particles = Goat.get_Particles()
	goat_horns = Goat.get_Horns()
	
	goat_inventory = Goat.get_Inventory()

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

	print("goat saved character FIGHT")
	
# warning-ignore:return_value_discarded
	ResourceSaver.save("res://goats/repo/%s.tres" %goat_id,self.Goat)
	### This will need to be set to user:// eventually, and same with loading said goat. or just 
	### put on server (which is better)

func load_fuel_bar():
	fuel_bar.max_value = max_fuel
	fuel_bar.value = 0
		
	
func load_goat():
	Global.loaded_goats[goat_id] = {"id":goat_id,"name":goat_name,"image":goat_image,"color":goat_color}
	sprite.self_modulate = Color(goat_color)
	
	
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
		elif Global.armor == 0:
			get_tree().call_group("heart","lose_heart")
	

	if goat_current_health <= 0 and alive:
		death()


func death():
	alive = false
	
	all_goat_particles.hide()
	boost_particles.hide()
	get_tree().call_group("armor","disappear_all")
	get_tree().call_group("heart","disappear_all")
	
	HUD.boss_bar("out",null)
	
	animation.play("death")
	HUD.announcement("Defeat","long")
	yield(HUD.animation,"animation_finished")
	HUD.animation.play("black_screen")
	yield(HUD.animation,"animation_finished")
	HUD.animation.play_backwards("black_screen")

	GlobalCamera.smoothing_enabled = true
	HUD.remove_health_bar()
	
	get_tree().call_group("attack","queue_free")
	Global.MAIN.hide_scene("entry",0,false)
	Global.in_battle = false
	Global.active_goat.input_allowed = true
	Global.active_goat.global_position = Vector2(rand_range(200,600),300)
	Global.MAIN.remove_scene("battle",2)



	
	
func _on_Attack_Timer_timeout():
	attack_ready = true
	
func action_sprite_func(type):
	if type == "show":
		action_sprite.show()
	else:
		action_sprite.hide()
	
func activate_goat():
	if self == Global.active_goat: input_allowed = true
	else: input_allowed = false

func _on_goat_button_pressed():
	if Global.multiplayer_active:
		print(is_network_master())
		if not is_network_master(): return
		if Global.in_battle: return
		
	Global.active_goat = self
	get_tree().call_group("player","activate_goat")
	misc_animation.stop()
	misc_animation.play("cursor")


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
