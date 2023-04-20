extends Control

var type = "heart" ### Heart or shield

var current_heart = false
var health_number
var rng = RandomNumberGenerator.new()

var heart = 2   # 0-none 1-half 2-full

onready var whole = $whole
onready var half = $half
onready var none = $none
onready var particles = $blood_particles
onready var explode_particles = $explode_particles
onready var armor_particles = $armor_particles
onready var animation = $AnimationPlayer


func _ready():	
	if type == "heart":add_to_group("heart")
	else: add_to_group("armor")
	
	if type == "heart":
		whole.texture = load("res://visual/GUI/icons/individual_32x32/icon001.png")
		half.texture = load("res://visual/GUI/icons/individual_32x32/icon0001.png")
		none.texture = load("res://visual/GUI/icons/individual_32x32/icon002.png")
	elif type == "armor":
		whole.texture = load("res://visual/GUI/icons/armor_icons/full.png")
		half.texture = load("res://visual/GUI/icons/armor_icons/half.png")
		none.texture = load("res://visual/GUI/icons/armor_icons/none.png")
		
	rng.randomize()
	var number = rng.randf_range(0,.5)
	yield(get_tree().create_timer(number),"timeout")
	if heart != 0: animation.play("rest")

func activate_current_heart(number):
	if number == health_number: 
		current_heart = true


func initialize_odd(): ### if its an odd number (half heart)
	heart = 1
	whole.hide()
	half.show()
	
func initialize_none(): ### if heart is empty
	heart = 0
	whole.hide()
	half.hide()
	none.show()
	
func lose_heart():
	if not current_heart: return
	if type == "armor" :
		particles.hide()
		explode_particles.hide()
		armor_particles.emitting = true
		animation.play("armor_hit")
		yield(animation,"animation_finished")
		
		
	else:
		animation.play("hit")
		
	if heart == 2:
		heart = 1
		whole.hide()
		half.show()
	elif heart == 1:
		heart = 0
		half.hide()
		none.show()
		current_heart = false
		
		if type == "heart":
			get_tree().call_group("heart","activate_current_heart",health_number-1)
			
	yield(animation,"animation_finished")
	if heart != 0:
		animation.play("rest")
		

func disappear_all():
	animation.play("disappear")
	whole.hide()
	half.hide()
	none.show()
