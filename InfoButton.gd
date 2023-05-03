extends Control

onready var label = $Label


var type
var bounds

var type_info = {
	"hp":"Determines how much life you have in battle",
	"happiness":"Goats fight better with higher happiness. All stats are negatively affected with low happiness",
	"energy":"Allows you to train your goat to gain better stats. Regenerates throughout the day",
	"exp":"Determines the level of your goat",
	"str":"Determines how much damage is output on your attacks",
	"dex":"Determines how fast each goat can move",
	"wis":"Determines..."
}


func _ready():
	self.rect_position = get_global_mouse_position() - Vector2(-18,4)
	label.text = type_info[type]
	

func _input(event):
	if event is InputEventKey or event.is_action_pressed("boost"):
		queue_free()
