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


var collected = false
var collect_amount = 0
var collect_type
var number

func _ready():
	self.hide()
	reward_type()
		
	
	yield(get_tree().create_timer(number/float(4)),"timeout")
	self.show()
	apply_impulse(Vector2(0,10),Vector2(rand_range(-200,200),-500))
	collect_area.monitorable = true
	collect_area.monitoring = true
	set_collision_mask_bit(4, true)
	set_collision_layer_bit(4, true)
	
	
func _process(_delta):
	rare_particles.rotation_degrees = -(self.rotation_degrees)
	

func reward_type():
	if number == 0 or number == 1:
		reward_texture.texture = money_icon
		collect_amount = 100
		collect_type = "Gold"
		
		
func _on_collect_area_body_entered(body):
	if "goat" in str(body):
		if not collected:
			collected = true
			animation.play("get")
			if collect_amount > 1:
				get_label.text = "+" + (str(collect_amount) + " " + collect_type)
			if collect_type == "Gold":
				Global.currancy_1 += collect_amount
				HUD.tooltip_top("currancy",Global.currancy_1)
				HUD.tooltip_top("money_add",str(Global.currancy_1) + " + " + str(collect_amount))
			self.set_collision_layer_bit(4,false)
			yield(animation,"animation_finished")
			self.queue_free()
			
			
