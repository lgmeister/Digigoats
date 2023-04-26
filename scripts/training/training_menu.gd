extends Node2D

onready var screen_middle = get_viewport_rect().size/2

var which_npc_node

### Main Frame ###
onready var frame = $Frame
onready var name_label = $Frame/Info/Name_Label
onready var shop_name_label = $Frame/Info/Shop_Label
onready var portrait = $Frame/ViewportContainer/Viewport/Shop_pic
onready var portrait_frame = $Frame/Info/shop_portrait
onready var portrait_color = $Frame/ColorRect

onready var goat_list = $Inventory_Frame/GoatList
onready var training_list = $Frame/Info/Shop_Panel/TrainingList
onready var energy_bar = $Inventory_Frame/Energy_Bar
onready var energy_label = $Inventory_Frame/Energy_Bar/Energy_Amount

onready var animation = $AnimationPlayer

### Selections ###
var all_goats = []
var training_choice
var goat_choice
var which_goat_node

### Dropdowns ###
var char_menu = false
var start_menu = false

## MISC ##
var training_cost = 25

var base_attribute_gain = .001
var base_exp_gain = 100


func _ready():
	Global.shop_open = true
	Global.input_allowed = false
	HUD.tooltip_top("currancy",Global.currancy_1)
	load_training()
	load_goats()
	self.position = Vector2(screen_middle.x,screen_middle.y)
#	animation.play("action_down")
	
func load_training():
	if which_npc_node.NPC_portrait != null:
		portrait.texture = which_npc_node.NPC_portrait
	else:
		portrait.hide()
		portrait_frame.hide()
		portrait_color.hide()
		
	if which_npc_node.NPC_name != null:
		name_label.text = which_npc_node.NPC_name
	else:
		name_label.text = ""
		
	if which_npc_node.NPC_shop_name != null:
		shop_name_label.text = which_npc_node.NPC_shop_name
	else:
		shop_name_label.text = ""
		
func load_goats():
	for goat in Global.loaded_goats:
		all_goats.append(Global.loaded_goats[goat]["id"])
		goat_list.add_item\
		(Global.loaded_goats[goat]["id"] + " - " + \
		Global.loaded_goats[goat]["name"],\
		Global.loaded_goats[goat]["image"])


func _on_exit_button_pressed():
	Global.shop_open = false
	Global.active_goat.input_allowed = true
	Global.input_allowed = true
	HUD.tooltip_top("hide",null)
	queue_free()


func _on_TrainingList_item_selected(index):
	training_choice = training_list.get_item_text(index)
	if char_menu == false:
		var tween = get_tree().create_tween()
		tween.tween_property(self,"position",Vector2(position.x - 100,position.y),.3)
		animation.play("char_show")
		char_menu = true
	

func _on_GoatList_item_selected(index):
	goat_choice = (all_goats[index])
	
	for goat in get_tree().get_nodes_in_group("player"): ### Gets the goat node
		if goat_choice == goat.goat_id:
			which_goat_node = goat
	
	update_energy()
	Global.training_goat = goat_choice
	if start_menu == false:
		animation.play("action_down")
		start_menu = true

func update_energy():	
	which_goat_node.save_goat()
	energy_bar.max_value = which_goat_node.goat_max_energy
	
	var tween = get_tree().create_tween()
	tween.tween_property(energy_bar,"value",float(which_goat_node.goat_current_energy),.2)
	
	energy_label.text = str(which_goat_node.goat_current_energy)\
	 + "/" + str(which_goat_node.goat_max_energy)
	energy_bar.show()
	

func _on_train_button_pressed():
	if goat_choice == null:
		animation.play("goat_flash")
		return
	if which_goat_node.goat_current_energy >= training_cost:
		which_goat_node.goat_current_energy -= 25
		update_energy()
		Global.goat_in_training = true
	# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/training.tscn")
		queue_free()
	else:
		animation.play("energy_flash")


func _on_quick_train_button_pressed():
	if goat_choice == null:
		animation.play("goat_flash")
		return
	if which_goat_node.goat_current_energy >= training_cost:
		which_goat_node.goat_current_energy -= 25
		update_energy()
		load_profile()
	else:
		animation.play("energy_flash")

func load_profile():
	var quick_gain = 50
	var profile_scene = preload("res://scenes/training/TrainingProfileMini.tscn")
	var profile_instance = profile_scene.instance()
	
	profile_instance.mini = true
	profile_instance.which_goat_node = which_goat_node
	profile_instance.str_gain = float(quick_gain) * base_attribute_gain
	
	profile_instance.dex_gain = float(quick_gain) * base_attribute_gain
	profile_instance.wis_gain = float(quick_gain) * base_attribute_gain
	
	profile_instance.exp_gain = float(100) *\
		(float(quick_gain + quick_gain + quick_gain)/3/base_exp_gain)
	HUD.add_child(profile_instance)
