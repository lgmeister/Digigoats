extends KinematicBody2D

export(Resource) var Enemy setget _setEnemy
export (PackedScene) var weapon = preload("res://scenes/battles/attack.tscn")

var player

### Enemy info###
onready var sprite = $ViewportContainer/Viewport/EnemySprite
onready var dust = $SShaderContainer/SSDissolveDust
onready var burn = $SShaderContainer/SSDissolveBurn
onready var death_tween = $DeathTween

var enemy_name
var enemy_texture
var enemy_scale
var enemy_load 

var enemy_hp
var enemy_speed
var enemy_movement
var enemy_attacks
#var enemy_atk_speed

var boss ### Is this a boss?
var alive = true
var destroy_terrain = false

### Movement ###

var move_time
var gravity = 1000
var speed = 200
var jump_speed = 800
var velocity = Vector2(0,0)
#var waittime = 3
var jump_cooldown_wait = 10
var facing = "right"


### Attacks ###
var weapon_iteration = 0  ### What attack sequence are we on
var enemy_sequence_speed = 3 ### How long sequences last

var currently_attacking = false
var attack_ready = false

var currently_touching = false
var touch_damage
var touch_damage_ready = true
var touch_timer_time = .3
var currently_touch_damaging = false


onready var atk_timer = $Attack_Timer
onready var action_timer = $Action_Timer
onready var move_timer = $Movement_Timer
onready var touch_timer = $Touch_Timer ### waittime between getting hit with touch attacks


############## MISC ###############
onready var animation = $AnimationPlayer
onready var arena ### The battle area

var rng = RandomNumberGenerator.new()


signal enemy_death
signal collided
signal hit_player(damage)


func _ready():
# warning-ignore:return_value_discarded
	connect("enemy_death", arena,"_on_enemy_death")
# warning-ignore:return_value_discarded
	connect("collided",arena,"_on_Character_collided")
# warning-ignore:return_value_discarded
	connect("hit_player",player,"weapon_hit_player")
	
	if enemy_movement != "none":
		move_timer.start(.1)
		
	action_timer.start()
	add_to_group("enemy")
	self.Enemy = load("res://monsters/repo/%s.tres" %enemy_load)
	load_enemy()
	
	if boss:
		HUD.boss_bar("in",enemy_name)
		HUD.boss_bar_top.value = enemy_hp
		HUD.boss_bar_top.max_value = enemy_hp
		
	yield(get_tree().create_timer(1),"timeout")	
	attack_ready = true


func _physics_process(delta):
	if not alive: return
		
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal('collided', self,collision)
			
			
func _process(_delta):
	if not player.alive: return
		
	if currently_attacking and attack_ready:
		attack(enemy_attacks[weapon_iteration].Weapon_Type)
		
	if currently_touching and touch_damage_ready:
		emit_signal("hit_player",touch_damage)
		touch_damage_ready = false
		touch_timer.start(touch_timer_time)

		
func _setEnemy(newEnemy : Resource):
	Enemy = newEnemy
	
	enemy_name = Enemy.get_Name()
	enemy_texture = Enemy.get_Texture()
	enemy_scale = Enemy.get_Scale()
	enemy_hp = Enemy.get_HP()
	enemy_speed = Enemy.get_Speed()
	enemy_movement = Enemy.get_Movement()
	enemy_attacks = Enemy.get_Attacks()
	enemy_sequence_speed = Enemy.get_Sequence_Speed()
	destroy_terrain = Enemy.get_Destroy_Terrain()
	touch_damage = Enemy.get_Touch_Damage()
	boss = Enemy.get_Boss()
	
	
func load_enemy():
	sprite.frames = enemy_texture
	sprite.animation = "move_left"
	scale = enemy_scale


func weapon_hit_enemy(damage):
	if not alive: return
	
	enemy_hp -= damage
	animation.play("hit")
#	print("ENEMY DAMAGE TAKEN:", damage, " HP Left: ", enemy_hp)
	
	if boss:
		HUD.boss_bar_top.value = enemy_hp
		
	if enemy_hp <= 0 and alive:
		death()

	
	
func _on_HitArea_body_entered(body):
	if player.name in str(body) and body.alive:
		currently_touching = true
		
		
func _on_HitArea_body_exited(body):
	if player.name in str(body) and body.alive:
		currently_touching = false


func attack(type):
	if not alive: return
	if not player.alive: return
		
	if type == "full_arc":
		for n in range (50):
			var atk = weapon.instance()
			atk.weapon_choice = enemy_attacks[weapon_iteration]
			atk.position = self.position
			atk.fired_from = self
			HUD.add_child(atk)
			var angle = Vector2(cos((n)*10),sin((n)*10))
			atk.where_look(angle*2800)
			
	elif type == "normal":
		var atk = weapon.instance()
		atk.rotation_degrees = 180
		atk.weapon_choice = enemy_attacks[weapon_iteration]
		atk.position = self.position
		atk.fired_from = self
		HUD.add_child(atk)
		atk.where_look(player.position)
		
	var time_between_shots = enemy_attacks[weapon_iteration].Time_Between_Shots
	attack_ready = false
	atk_timer.start(time_between_shots)
	
	
func death():
	alive = false
	set_collision_layer_bit(4,false)
	sprite.playing = false
	burn.is_active = true
	var death_time =.5
	if boss: death_time = 3
	
	death_tween.interpolate_property(burn,"process_value",0,1,death_time,Tween.TRANS_LINEAR)
	death_tween.start()
	yield(death_tween,"tween_completed")
	emit_signal("enemy_death")
	
	if boss:
		HUD.boss_bar("out","Victory")
		HUD.announcement("Victory","long")
		yield(HUD.animation,"animation_finished")
		HUD.animation.play("black_screen")
		yield(HUD.animation,"animation_finished")
		GlobalCamera.smoothing_enabled = true
		HUD.remove_health_bar()
		get_tree().call_group("attack","queue_free")
		
	set_collision_layer_bit(1,false)
	yield(get_tree().create_timer(2),"timeout")
	queue_free()
	
	if boss:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/entry_world.tscn")


func _on_Attack_Timer_timeout():		
	attack_ready = true
	
	
func _on_Touch_Timer_timeout():
	touch_damage_ready = true


func _on_Action_Timer_timeout():
	action_timer.wait_time = enemy_sequence_speed
	if currently_attacking == true:
		currently_attacking = false
	else:
		weapon_iteration += 1
		if weapon_iteration > (enemy_attacks.size() - 1):
			weapon_iteration = 0
			
		currently_attacking = true
		

func _on_Movement_Timer_timeout():
	if enemy_movement == "random":
		rng.randomize()
		move_time = rng.randi_range(1,4)
		random_move()
	if enemy_movement == "seeking":
		move_time = .5
		seeking_move()


func random_move():
	rng.randomize()
	var randommove = rng.randi_range(1,5)
	if randommove == 1:
		moveit(enemy_speed,gravity)
		sprite.play("move_right")
	elif randommove == 2:
		moveit(-enemy_speed,gravity)
		sprite.play("move_left")
	elif randommove == 3:
		moveit(0,gravity)
		sprite.stop()
	elif randommove == 4:
		sprite.play("move_right")
		moveit(enemy_speed*2,-jump_speed)
	elif randommove == 5:
		sprite.play("move_left")
		moveit(-enemy_speed*2,-jump_speed)
		
		
func seeking_move():
	rng.randomize()
	var randommove = rng.randi_range(1,8)
	
	if player.position.x > self.position.x:
		moveit(enemy_speed,gravity)
		sprite.play("move_right")
	elif player.position.x < self.position.x:
		moveit(-enemy_speed,gravity)
		sprite.play("move_left")
	if player.position.y < self.position.y and randommove == 1:
		moveit(enemy_speed*2,-jump_speed)
		sprite.play("move_right")
	elif player.position.y < self.position.y and randommove == 2:
		moveit(-enemy_speed*2,-jump_speed)
		sprite.play("move_left")
		
		
func moveit(x,y):
	velocity = Vector2(x,y)
	move_timer.set_wait_time(move_time)








