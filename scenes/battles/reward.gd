extends RigidBody2D

onready var animation = $AnimationPlayer
onready var collect_area = $collect_area

var collected = false
var number

func _ready():
	self.hide()
	yield(get_tree().create_timer(number/float(4)),"timeout")
	self.show()
	apply_impulse(Vector2(0,10),Vector2(rand_range(-200,200),-500))
	collect_area.monitorable = true
	collect_area.monitoring = true
	set_collision_mask_bit(4, true)
	set_collision_layer_bit(4, true)
	
	

func _on_RewardButton_pressed():
	queue_free()



func _on_collect_area_body_entered(body):
	if "goat" in str(body):
		if not collected:
			animation.play("get")
			self.set_collision_layer_bit(4,false)
			yield(animation,"animation_finished")
			self.queue_free()
