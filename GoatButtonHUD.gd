extends Button

onready var number_label = $number_label

var goat_node
var goat_number


func _ready():
	self.icon = goat_node.goat_image
	self.rect_min_size = Vector2(50,50)
	self.rect_size = Vector2(50,50)
	number_label.text = str(goat_number)
	add_to_group("hud_goat")


func _on_GoatButtonHUD_pressed():
	goat_node.select_goat()
	get_tree().call_group("hud_goat","unselect",goat_node)

func unselect(exception):
	if exception != goat_node:
		self.self_modulate = Color("55ffffff")
	else:
		self.self_modulate = Color("ffffff")
