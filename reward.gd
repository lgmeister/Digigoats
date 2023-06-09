extends RigidBody2D


### NODEs ###
onready var animation = $AnimationPlayer
onready var collect_area = $collect_area
onready var reward_texture = $RewardTexture
onready var rare_particles = $RareParticles
onready var get_label = $RareParticles/GetLabel

var goat ## player goat

###ICONS###
var money_icon = preload("res://visual/GUI/icons/individual_32x32/icon011.png")

### Bool ###
var collected = false
var add_impulse = true

var collect_amount = 0
var collect_type
var number
var reward_type

func _ready():
	self.hide()
	get_reward_type()
	yield(get_tree().create_timer(number/float(4)),"timeout")
	self.show()
	
	if reward_type != "currancy":
		rare_particles.emitting = true
	
	if add_impulse:
		apply_impulse(Vector2(0,10),Vector2(rand_range(-200,200),-500))
		
	collect_area.monitorable = true
	collect_area.monitoring = true
	set_collision_mask_bit(4, true)
	set_collision_layer_bit(4, true)
	
	if Global.in_battle:
		set_collision_mask_bit(8,false)
	
	
func _process(_delta):
	rare_particles.rotation_degrees = -(self.rotation_degrees)


func get_reward_type():
	if reward_type == "currancy":
		reward_texture.texture = money_icon
		collect_amount = 100
		collect_type = "Gold"		
	elif number == 0 or number == 1:
		reward_texture.texture = money_icon
		collect_amount = 100
		collect_type = "Gold"
		
		
func _on_collect_area_body_entered(body):
	if "goat" in str(body):
		if not collected:
			AUDIO.play("pickup")
			collected = true
			set_collision_mask_bit(4, false)
			set_collision_layer_bit(4, false)
			set_collision_layer_bit(13, false)
			set_collision_mask_bit(0, false)
			set_collision_layer_bit(0, false)
			animation.play("get")
			
			if collect_amount > 1:
				get_label.text = "+" + (str(collect_amount) + " " + collect_type)
			if collect_type == "Gold":
				gold_gain(collect_amount)
				HUD.tooltip_top("currancy",Global.currancy_1)
				HUD.tooltip_top("money_add",str(Global.currancy_1) + " (+" + str(collect_amount) + ")")
		
			self.set_collision_layer_bit(4,false)
			yield(animation,"animation_finished")
			self.queue_free()
			
func gold_gain(amount):
	var goat_number = get_tree().get_nodes_in_group("player").size()
	var divide_even = amount/goat_number
	var remainder = amount -  (int(divide_even) * goat_number)
	
	Global.currancy_1 += amount
	
	for goat in get_tree().get_nodes_in_group("player"):
		goat.goat_gold += amount
	
	if remainder > 0:
		Global.active_goat.goat_gold += remainder
			
			
