extends RigidBody2D

### Scenes ###
var reward_scene = load("res://scenes/battles/reward.tscn")
var main

### Nodes ###
onready var balloon_particles = $BalloonParticles
onready var balloon = $balloon
onready var balloon_area = $BalloonArea
onready var box = $box
onready var box_particles = $BoxParticles
onready var animation = $AnimationPlayer
onready var reset_timer = $ResetTimer

## Bools ##
var box_open = false
var popped = false
var reset_available = true

var speed = 30

func _ready():
	speed = rand_range(10,40)
	animation.play("float")
	add_central_force(Vector2(-speed,0))

func _integrate_forces(_state):
#	print(global_position)
	if global_position.x < 350 and reset_available:
		reset()
		reset_timer.start(30)
		
func reset():
	reset_available = false
	add_central_force(Vector2(speed,0))
	

func _on_BaloonArea_body_entered(_body):
	if not popped:
		popped = true
		animation.stop()
		balloon_particles.emitting = true
		balloon.hide()
		call_deferred("set_mode",2)

		self.gravity_scale = 3
		self.add_force(Vector2.ZERO,Vector2(0,300))
		set_collision_layer_bit(0,true)
		

func _on_PrizeArea_body_entered(body):
	if "TileMap" in str(body) or "Roof" in str(body):
		if not box_open:
			box_open = true
			rotation_degrees = 0
			box.hide()
			box_particles.emitting = true
			
			var scene = reward_scene.instance()
			scene.position = self.position + Vector2(40,100)
			scene.number = 0
			scene.add_impulse = false
			scene.set_collision_mask_bit(8, true)
			balloon_area.set_collision_mask_bit(0,false)
			balloon_area.set_collision_mask_bit(8, true)
			main.call_deferred("add_child",scene)
			yield(get_tree().create_timer(2),"timeout")
			queue_free()


func _on_ResetTimer_timeout():
	reset_available = true
