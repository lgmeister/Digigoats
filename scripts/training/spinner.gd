extends Node2D

onready var stop_animation = $StopAnimation
onready var spin_animation = $SpinAnimation
onready var stop_sprite = $Area2D/stop_sprite
onready var spin_sprite = $spinner_sprite

signal percent_change(percent)

var spinner_type
var attribute = 1
var rng = RandomNumberGenerator.new()

var training_scene

func _ready():
# warning-ignore:return_value_discarded
	connect("percent_change",training_scene,"percent_change")
	next_spinner(1)


func _on_Area2D_body_entered(_body):
	pass
#	print(body)




func _on_Area2D_area_entered(area):
	var percent_change
	if "attack" in str(area) and spin_animation.is_playing():	
		spin_animation.stop()
		stop_animation.stop()
		
		if spin_sprite.rotation_degrees >= 0 and spin_sprite.rotation_degrees <= 90:
			if spinner_type == 1: percent_change = 10
			elif spinner_type == 2: percent_change = 30
			elif spinner_type == 3: percent_change = 50 
			emit_signal("percent_change",percent_change,attribute)
			attribute += 1
		elif spin_sprite.rotation_degrees > 90 and spin_sprite.rotation_degrees <= 181:
			if spinner_type == 1: next_spinner(2)
			elif spinner_type == 2: next_spinner(3)
			elif spinner_type == 3: 
				percent_change = 50 
				emit_signal("percent_change",percent_change,attribute)
		elif spin_sprite.rotation_degrees > 181 and spin_sprite.rotation_degrees <= 197:
			if spinner_type == 1: percent_change = -50
			elif spinner_type == 2: percent_change = -50
			elif spinner_type == 3: percent_change = 100 
			emit_signal("percent_change",percent_change,attribute)
			attribute += 1
		elif spin_sprite.rotation_degrees > 197 and spin_sprite.rotation_degrees <= 360:
			percent_change = 0
			emit_signal("percent_change",percent_change,attribute)
			attribute += 1
		
		for attack in get_tree().get_nodes_in_group("attack"):
			attack.queue_free()

func new_spinner():
	next_spinner(1)
		
func next_spinner(number):
	rng.randomize()
	var random = rng.randf_range(-.3,.3)
	rng.randomize()
	var random2 = rng.randf_range(-.3,.3)
	rng.randomize()
	var stop_rand = rng.randf_range(0,1)
	rng.randomize()
	var start_rand = rng.randf_range(0,1)
	
	spinner_type = number
	spin_sprite.texture = load("res://visual/training/wheel/wheel_%s.png" %spinner_type)
	stop_animation.play("move")
	stop_animation.seek(stop_rand)
	spin_animation.play("spin_2")
	spin_animation.seek(start_rand)
	stop_animation.playback_speed = number + random 
	spin_animation.playback_speed = number + random2
		

func fade_spinner():
	stop_animation.play("fade")
	spin_animation.play("fade")
	yield(spin_animation,"animation_finished")
	queue_free()
