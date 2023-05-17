extends Control

onready var label = $Label
onready var animation = $AnimationPlayer

var damage = 0

var rng = RandomNumberGenerator.new()

func _ready():
	var rand = rng.randf_range(.8,1.0)
	self.modulate = Color (rand,rand,rand,1)
	label.text = str(damage)
	animation.play("hit")
