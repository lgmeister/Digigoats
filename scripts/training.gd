extends Node2D

var which_goat_node

var str_gain = 50
var dex_gain = 50
var wis_gain = 50

var base_attribute_gain = .001
var base_exp_gain = 100

var spinner
var portal_active = false

onready var middle_label = $middle_label

onready var str_label = $str_label/Label
onready var dex_label = $dex_label/Label
onready var wis_label = $wis_label/Label

onready var pre_str_label = $str_label
onready var pre_dex_label = $dex_label
onready var pre_wis_label = $wis_label

onready var portal = $portal_area
onready var portal_progress = $portal_area/portal_progress
onready var portal_particles = $portal_area/CPUParticles2D

onready var animation = $AnimationPlayer
onready var tween = $Tween

var cursor = load("res://visual/GUI/cursors/Arrow_Rounded_Blue.png")

func _ready():
	GlobalCamera.reset()
	portal.hide()
	portal.monitoring = false
	
	pre_dex_label.modulate = Color(0,0,0,1)
	pre_wis_label.modulate = Color(0,0,0,1)
	
	str_label.text = str(str_gain) + "%"
	dex_label.text = str(dex_gain) + "%"
	wis_label.text = str(wis_gain) + "%"
	
	load_goat()
	load_training()
	

func load_goat():
	var goat_scene = load("res://scenes/battles/Character_Fight.tscn")
	var scene_instance = goat_scene.instance()
	scene_instance.position = Vector2(200,300)
	scene_instance.in_training = true
	scene_instance.input_allowed = true
	scene_instance.fight_scene = self
	which_goat_node = scene_instance
	add_child(scene_instance)


func load_training():
	var training_scene = load("res://scenes/training/spinner.tscn")
	var scene_instance = training_scene.instance()
	add_child(scene_instance)
	spinner = scene_instance

func percent_change(percent,type):
	var type_text
	
	if type == 1: type_text = "Strength"
	elif type == 2: type_text = "Dexterity"
	elif type == 3: type_text = "Wisdom"
	else: type_text = "ERROR"
	
	middle_label.text = type_text + " +" + str(percent) + "%"
	animation.play("middle")
	yield(animation,"animation_finished")
	
	if type == 1:
		str_gain += percent
		str_label.text = str(str_gain) + "%"
		animation.play("str_done")
		yield(animation,"animation_finished")
		pre_dex_label.modulate = Color(1,1,1,1)
		animation.play_backwards("middle")
		yield(animation,"animation_finished")
		spinner.new_spinner()
	elif type == 2:
		dex_gain += percent
		dex_label.text = str(dex_gain) + "%"
		animation.play("dex_done")
		yield(animation,"animation_finished")
		pre_wis_label.modulate = Color(1,1,1,1)
		animation.play_backwards("middle")
		yield(animation,"animation_finished")
		spinner.new_spinner()
	elif type == 3:	
		wis_gain += percent
		wis_label.text = str(wis_gain) + "%"
		animation.play("wis_done")
		yield(animation,"animation_finished")
		animation.play_backwards("middle")
		spinner.fade_spinner()
		yield(animation,"animation_finished")
		
		load_profile()
		
		portal.show()	
		animation.play("portal")

func _input(event):
	if event.is_action_pressed("action") and portal_active:
		which_goat_node.input_allowed = false
		HUD.animation.play("black_screen")
		yield(HUD.animation,"animation_finished")

		GlobalCamera.smoothing_enabled = true
		HUD.remove_health_bar()
		HUD.tooltip_bot("hide",null)
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/entry_world.tscn")	

func load_profile():
	Input.set_custom_mouse_cursor(cursor)
	var profile_scene = load("res://scenes/training/TrainingProfile.tscn")
	var profile_instance = profile_scene.instance()
	
	profile_instance.which_goat_node = which_goat_node
	profile_instance.str_gain = float(str_gain) * base_attribute_gain
	profile_instance.dex_gain = float(dex_gain) * base_attribute_gain
	profile_instance.wis_gain = float(wis_gain) * base_attribute_gain
	
	profile_instance.exp_gain = float(100) *\
		(float(str_gain + dex_gain + wis_gain)/3/base_exp_gain)
	add_child(profile_instance)
	

func _on_portal_area_body_entered(body):
	if "TileMap" in str(body):
		return
	which_goat_node.action_sprite_func("show")		
	HUD.tooltip_bot("tip","Press E to Activate...")
	portal_active = true
	portal_particles.speed_scale = 2
	

func _on_portal_area_body_exited(_body):
	HUD.tooltip_bot("hide",null)
	which_goat_node.action_sprite_func("hide")		
	portal_active = false
	portal_particles.speed_scale = 1
