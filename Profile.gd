extends Node2D


### Main Frame ###
onready var frame = $Frame
onready var name_label = $Frame/Info/Name_Label
onready var portrait = $"%Goat_Pic"
onready var goat_line = $Line2D
onready var tabs = $Frame/Info/TabContainer

### buttons ###
onready var expand = $Frame/expand_button
onready var contract = $Frame/contract_button
onready var inventory_button = $Action_Frame/inventory_button
onready var train_button = $Action_Frame/train_button

### Bars ###
onready var health_bar = $Frame/Info/TabContainer/Stats/Bars/HP_Bar
onready var health_label = $Frame/Info/TabContainer/Stats/Bars/HP_Bar/HP_Amount
onready var energy_bar = $Frame/Info/TabContainer/Stats/Bars/Energy_Bar
onready var energy_label = $Frame/Info/TabContainer/Stats/Bars/Energy_Bar/Energy_Amount
onready var happiness_bar = $Frame/Info/TabContainer/Stats/Bars/Happiness_Bar
onready var happiness_label = $Frame/Info/TabContainer/Stats/Bars/Happiness_Bar/Happiness_Amount
onready var exp_bar = $Frame/Info/TabContainer/Stats/Bars/EXP_Bar
onready var exp_label = $Frame/Info/TabContainer/Stats/Bars/EXP_Bar/EXP_Amount

### Attributes ###
onready var str_label = $Frame/Info/Str_Label
onready var dex_label = $Frame/Info/Dex_Label
onready var wis_label = $Frame/Info/Wis_Label


### Equipment ####
onready var weapon_slot = $Frame/Info/TabContainer/Gear/weapon_slot
onready var head_slot = $Frame/Info/TabContainer/Gear/head_slot
onready var misc_slot = $Frame/Info/TabContainer/Gear/misc_slot
onready var armor_slot = $Frame/Info/TabContainer/Gear/armor_slot

### Inventory ###
onready var inventory = $Inventory_Frame/Inventory_Grid
onready var sort_texture = $Inventory_Frame/sort_button/sort_texture
onready var left_arrow = $Inventory_Frame/arrow_left
onready var right_arrow = $Inventory_Frame/arrow_right

### Status/Bools ###
var move_frame = false
var inventory_open = false
var profile_pinned = false

var weapon_equipped = false
var armor_equipped = false
var headgear_equipped = false
var misc_equipped = false


### Goat Info ###
var which_goat_node ## which goat's profile
var pinned_location = Vector2()

### Inventory ###
var number_of_pages = 1
var current_page = 0

var all_items = []
var temp_page_items

var sort_types = ["All","Weapon","Armor","Headgear","Misc","Consumable"]
var sort_icons = [preload("res://inventory/icon/tooltip/infinite.png"), # All
				preload("res://inventory/icon/tooltip/icon444.png"), ## Weapon
				preload("res://inventory/icon/tooltip/icon633.png"), ## Armor
				preload("res://inventory/icon/tooltip/icon716.png"), ## Headgear
				preload("res://inventory/icon/tooltip/icon788.png"), ## Misc
				preload("res://inventory/icon/consumables/sm_potion.png")] ## Consumable
var current_sort_type = 0


### MISC ###
onready var camera = GlobalCamera
onready var animation = $AnimationPlayer
onready var train_popup = $Action_Frame/train_button/train_popup
onready var tween = $Tween
onready var page_label = $Inventory_Frame/page_label
onready var timer = $Timer


var temp_mouse_pos


func _ready():
	animation.play("action_down")
	load_equipment()
	load_inventory("All")
	load_profile()
	create_line()
	update_bars("instant")
	update_attributes(false)
#	which_goat_node.goat_exp = 100 
	timer.start(1)
	
func load_inventory(filter):
	clear_inventory()
	var items_on_page = 0

	for load_item in which_goat_node.goat_inventory:
		if filter == "All" or load_item.Item_Type == filter:
			all_items.append(load_item)
	
	for item in (all_items.size()-current_page*12):
		if items_on_page < 12:
			load_items(all_items[item+(current_page*12)])
			items_on_page += 1
	
	for _slots in range(12-items_on_page):
		load_items(preload("res://inventory/repo/empty.tres"))
	
	number_of_pages = ceil(float(all_items.size())/12)
	if number_of_pages == 0: number_of_pages = 1
	page_label.text = str(current_page+1) + "/" + str(number_of_pages)
	
	if current_page == 0: left_arrow.disabled = true
	else: left_arrow.disabled = false
	
	if number_of_pages == current_page + 1: right_arrow.disabled = true
	else: right_arrow.disabled = false
	
func clear_inventory():
	all_items = []
	for equipment in inventory.get_children():
		equipment.queue_free()
	

func load_equipment():
	var item_instance
	var item_scene = preload("res://scenes/inventory_item.tscn")
	var empty_item = ("res://inventory/repo/empty.tres")
	
	if which_goat_node.goat_weapon != null:
		item_instance = item_scene.instance()
		item_instance.loaded_item = which_goat_node.goat_weapon.resource_path
		item_instance.currently_equipped = true
		weapon_equipped = true
	else:
		item_instance = item_scene.instance()
		item_instance.loaded_item = empty_item
	item_instance.specific_type = "Weapon"
	item_instance.which_goat_node = which_goat_node
	weapon_slot.add_child(item_instance)
		
	if which_goat_node.goat_armor != null:
		item_instance = item_scene.instance()
		item_instance.loaded_item = which_goat_node.goat_armor.resource_path
		item_instance.currently_equipped = true
		armor_equipped = true
	else:
		item_instance = item_scene.instance()
		item_instance.loaded_item = empty_item
	item_instance.specific_type = "Armor"
	item_instance.which_goat_node = which_goat_node
	armor_slot.add_child(item_instance)
	
	if which_goat_node.goat_headgear != null:
		item_instance = item_scene.instance()
		item_instance.loaded_item = which_goat_node.goat_headgear.resource_path		
		item_instance.currently_equipped = true
		headgear_equipped = true
	else:
		item_instance = item_scene.instance()
		item_instance.loaded_item = empty_item
	item_instance.specific_type = "Headgear"
	item_instance.which_goat_node = which_goat_node
	head_slot.add_child(item_instance)
	
	if which_goat_node.goat_misc != null:
		item_instance = item_scene.instance()
		item_instance.loaded_item = which_goat_node.goat_misc.resource_path
		item_instance.currently_equipped = true
		misc_equipped = true
	else:
		item_instance = item_scene.instance()
		item_instance.loaded_item = empty_item
	item_instance.specific_type = "Misc"
	item_instance.which_goat_node = which_goat_node
	misc_slot.add_child(item_instance)
	
func load_items(item):
	var item_scene = preload("res://scenes/inventory_item.tscn")
	var item_instance = item_scene.instance()
	item_instance.loaded_item = item.resource_path
#	item_instance.profile = self ## Maybe add this to the equipmen load as well
	item_instance.which_goat_node = which_goat_node
	inventory.add_child(item_instance)


func load_profile():
	portrait.texture = which_goat_node.goat_image
	name_label.text = which_goat_node.goat_name
	
	health_bar.value = which_goat_node.goat_current_health
	health_bar.max_value =  which_goat_node.goat_max_health
	health_label.text = str(which_goat_node.goat_current_health)\
				+ "/" + str(which_goat_node.goat_max_health)
	
	exp_bar.value = which_goat_node.goat_exp
	exp_bar.max_value =  which_goat_node.goat_next_exp
	exp_label.text = str(which_goat_node.goat_exp)\
				+ "/" + str(which_goat_node.goat_next_exp)	
				

func update_bars(type):
	if type == "instant":
		health_bar.value = which_goat_node.goat_current_health
		energy_bar.value = which_goat_node.goat_current_energy
		happiness_bar.value = which_goat_node.goat_current_happiness
		exp_bar.value = which_goat_node.goat_exp
		
	elif type == "slow":
		tween.interpolate_property(health_bar,"value", health_bar.value,
			which_goat_node.goat_current_health,.3,Tween.TRANS_LINEAR)
		tween.start()
		
		tween.interpolate_property(happiness_bar,"value", happiness_bar.value,
			which_goat_node.goat_current_happiness,.3,Tween.TRANS_LINEAR)
		tween.start()
		
		tween.interpolate_property(energy_bar,"value",energy_bar.value,
			which_goat_node.goat_current_energy,.3,Tween.TRANS_LINEAR)
		tween.start()
		
		tween.interpolate_property(exp_bar,"value",exp_bar.value,
			which_goat_node.goat_exp,.3,Tween.TRANS_LINEAR)
		tween.start()
		
	exp_label.text = str(which_goat_node.goat_exp) +\
					"/" + str(which_goat_node.goat_next_exp)
		
	happiness_label.text = str(which_goat_node.goat_current_happiness) +\
						 "/" + str(which_goat_node.goat_max_happiness)
	energy_label.text = str(which_goat_node.goat_current_energy) +\
						 "/" + str(which_goat_node.goat_max_energy)
	health_label.text = str(which_goat_node.goat_current_health) +\
						 "/" + str(which_goat_node.goat_max_health)
						

func update_attributes(flash):
	str_label.text = "Str: " + str(which_goat_node.goat_str)
	dex_label.text = "Dex: " + str(which_goat_node.goat_dex)
	wis_label.text = "Wis: " + str(which_goat_node.goat_wis)
	if flash:
		animation.play("attribute_flash")
	

func create_line():
	var frame_to_goat = self.global_position - which_goat_node.global_position
	goat_line.points[0] = Vector2(0,0)
	goat_line.points[1] = Vector2(-frame_to_goat.x,0) / self.scale
	goat_line.points[2] = Vector2(-frame_to_goat.x,-frame_to_goat.y) / self.scale
	
# warning-ignore:unused_argument
func _process(delta):
	create_line() ###Maybe change this. This is due to zoom not changing what i need it to
	
	if move_frame:
		self.position = Vector2(get_global_mouse_position().x-temp_mouse_pos.x-1,\
		get_global_mouse_position().y + (80*self.scale.x)) - which_goat_node.position\
		+ Global.active_goat.global_position
		
	elif profile_pinned:
		pass

func _input(event):
	var frame_to_goat = self.global_position - which_goat_node.global_position
	
	if event.is_action("ui_page_up"):
		if self.scale <= Vector2(.3,.3):
			self.scale = Vector2(.3,.3)
			return
		self.scale -= Vector2(Global.camera_zoom_level,Global.camera_zoom_level)
		self.position -= frame_to_goat * Global.camera_zoom_level
	if event.is_action("ui_page_down"):
		if self.scale >= Vector2(1,1):
			self.scale = Vector2(1,1)
			return
		self.scale += Vector2(Global.camera_zoom_level,Global.camera_zoom_level)
		self.position += frame_to_goat * Global.camera_zoom_level

func _on_exit_button_pressed():
	which_goat_node.profile_open = false
	Global.MAIN.remove_scene("profile",0)


func _on_move_button_button_down():
	move_frame = true
	temp_mouse_pos = get_local_mouse_position()

func _on_move_button_button_up():
	move_frame = false
	
func _on_inventory_button_pressed():
	inventory_button.disabled = true
	if not inventory_open:
		animation.play("inventory_show")
		inventory_open = true
#		tabs.current_tab = 2
	else:
		animation.play_backwards("inventory_show")
		inventory_open = false
		
	yield(animation,"animation_finished")
	inventory_button.disabled = false


func _on_expand_button_pressed():
	expand.disabled = true
	animation.play("expand")
	yield(animation,"animation_finished")
	expand.hide()
	contract.disabled = false
	contract.show()

func _on_contract_button_pressed():
	contract.disabled = true
	animation.play_backwards("expand")
	contract.hide()
	expand.disabled = false
	expand.show()
	

func _on_fight_button_pressed():
	Global.active_goat = which_goat_node
	Global.active_goat.input_allowed = false
	which_goat_node.profile_open = false
	Global.MAIN.remove_scene("profile",0)
	var scene = Global.MAIN.load_scene("battle")
	Global.MAIN.add_scene(scene,false)
	Global.MAIN.hide_scene("entry",0,true)


func _on_train_button_pressed():
	train_popup.unselect_all()
	train_popup.show()

func _on_train_popup_item_selected(index):
	train_popup.hide()
	var choice = train_popup.get_item_text(index)
	if choice == "Train":
		Global.active_goat = which_goat_node
		which_goat_node.goat_current_energy -= 25
# warning-ignore:return_value_discarded
		Global.active_goat.input_allowed = false
		which_goat_node.profile_open = false
		Global.training_goat = which_goat_node
		Global.MAIN.remove_scene("profile",0)
		var scene = Global.MAIN.load_scene("training")
		Global.MAIN.add_scene(scene,false)
	elif choice == "Quick Train (50%)":
		which_goat_node.goat_current_energy = 0
		update_bars("slow")
		
	

func _on_sort_button_pressed():
	if current_sort_type == sort_icons.size() - 1:
		current_sort_type = 0
	else:
		current_sort_type += 1
	sort_texture.texture = sort_icons[current_sort_type]
	
	current_page = 0
	load_inventory(sort_types[current_sort_type])


func _on_arrow_right_pressed():
	current_page += 1
	load_inventory(sort_types[current_sort_type])


func _on_arrow_left_pressed():
	current_page -= 1
	load_inventory(sort_types[current_sort_type])


func _on_Timer_timeout():
	if Global.active_goat.position.distance_to(self.position) > 500:
		Global.MAIN.remove_scene("profile",1) 
		
func load_info(type):
	Global.MAIN.remove_scene("info",0)
	var scene = Global.MAIN.load_scene("info")
	scene.type = type
	Global.MAIN.add_scene(scene,true)
	
func close_info():
	Global.MAIN.remove_scene("info",0)


func _on_hp_info_mouse_entered():
	load_info("hp")

func _on_hp_info_mouse_exited():
	close_info()

func _on_happiness_info_mouse_entered():
	load_info("happiness")

func _on_happiness_info_mouse_exited():
	close_info()

func _on_energy_info_mouse_entered():
	load_info("energy")

func _on_energy_info_mouse_exited():
	close_info()

func _on_exp_info_mouse_entered():
	load_info("exp")

func _on_exp_info_mouse_exited():
	close_info()

func _on_str_info_mouse_entered():
	load_info("str")

func _on_str_info_mouse_exited():
	close_info()

func _on_dex_info_mouse_entered():
	load_info("dex")

func _on_dex_info_mouse_exited():
	close_info()

func _on_wis_info_mouse_entered():
	pass
#	load_info("wis") PUT BACK WHEN WISDOM IS ADDED

func _on_wis_info_mouse_exited():
	pass
#	close_info() PUT BACK WHEN WISDOM IS ADDED
