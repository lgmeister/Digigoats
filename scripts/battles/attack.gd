extends Area2D

export(Resource) var Weapon setget _setWeapon


var fired_from ### Who fired the weapon?
onready var starting_position = self.position### Where did we start?
var type


var weapon_choice

var weapon_speed = 750
var fall_speed = 0
var weapon_damage
var weapon_type = "normal"
var weapon_style

var attack_icon ### Icon that is thrown
var attack_color
var weapon_icon ### Icon shown in inventory
var weapon_hit_player
var weapon_hit_enemies
var weapon_scale
var weapon_range
var weapon_particles

var ignore_terrain


onready var check_distance = $check_distance
onready var remove = $remove_timer
onready var sprite = $Sprite

#### Particles ####
onready var particle_fire = $fire_particles
onready var particle_shimmer = $shimmer_particles
onready var particle_trail = $magic_trail

var weak_ref = weakref(fired_from)

func _ready():
	remove.start(3)
	check_distance.start(.1)
	
	add_to_group("attack")
	
	self.Weapon = weapon_choice
	load_weapon()
	load_particles(weapon_particles)

	
func _setWeapon(newWeapon : Resource):
	Weapon = newWeapon
	
	attack_icon = Weapon.get_Attack_Icon()
	attack_color = Weapon.get_Modulate()
	weapon_icon = Weapon.get_Icon() 
	weapon_damage = Weapon.get_Damage()
	weapon_hit_player = Weapon.get_Hit_Player()
	weapon_hit_enemies = Weapon.get_Hit_Enemies()
	weapon_scale = Weapon.get_Scale()
	weapon_speed = Weapon.get_Speed()
	weapon_type = Weapon.get_Type()
	weapon_range = Weapon.get_Range()
	weapon_particles = Weapon.get_Particles()
	ignore_terrain = Weapon.get_Ignore_Terrain()
	weapon_style = Weapon.get_Style()
	
	

func load_weapon():
	sprite.texture = attack_icon
	sprite.modulate = attack_color
	self.scale = weapon_scale
	
func load_particles(particle_type):
	if particle_type == "none":
		return
	elif particle_type == "flame":
		particle_fire.emitting = true
		particle_fire.show()
	elif particle_type == "magic":
		particle_shimmer.emitting = true
		particle_shimmer.show()
	elif particle_type == "trail":
		particle_trail.emitting = true
		particle_trail.show()
		

func _physics_process(delta):
	if weapon_style == "ranged":
		position += transform.x * (weapon_speed/weapon_scale.x) * delta
	elif weapon_style == "melee-stab":
		position += (transform.x * (weapon_speed/weapon_scale.x) * delta)
	elif weapon_style == "melee-slash":
		pass

func _on_attack_body_entered(body):
	if body.is_in_group("enemy") and weapon_hit_enemies:
		if not body.alive: return
		body.weapon_hit_enemy(weapon_damage)
		queue_free()
	elif body.is_in_group("player") and weapon_hit_player:
		if not body.alive: return
		body.weapon_hit_player(weapon_damage)
		queue_free()
		
	if "Ledges" in str(body) and not ignore_terrain:
		queue_free()

		
func where_look(where):
	look_at(where)

func _on_remove_timer_timeout():
	queue_free()
	

func _on_check_distance_timeout():
	if self.position.distance_to(starting_position) > weapon_range:
		queue_free()
