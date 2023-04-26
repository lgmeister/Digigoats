extends Node2D

onready var screen_middle = get_viewport_rect().size/2

### Main Frame ###
onready var frame = $Frame
onready var name_label = $Frame/Info/Name_Label
onready var shop_name_label = $Frame/Info/Shop_Label
onready var portrait = $Frame/ViewportContainer/Viewport/Shop_pic
onready var portrait_frame = $Frame/Info/goat_frame
onready var portrait_color = $Frame/ColorRect

### Inventory ###
onready var inventory = $Inventory_Frame/Inventory_Grid
onready var shop_inventory = $Frame/Info/Shop_Panel/Inventory_Grid
onready var sort_texture = $Inventory_Frame/sort_button/sort_texture
onready var shop_sort_texture = $Frame/Info/Shop_Panel/shop_sort_button/sort_texture
onready var left_arrow = $Inventory_Frame/arrow_left
onready var right_arrow = $Inventory_Frame/arrow_right
onready var left_shop_arrow = $Frame/Info/Shop_Panel/shop_arrow_left
onready var right_shop_arrow = $Frame/Info/Shop_Panel/shop_arrow_right

### Info ###
var which_goat_node ## which goat's profile
var which_npc_node

### Inventory ###
var number_of_pages = 1
var number_of_shop_pages = 1
var current_page = 0
var current_shop_page = 0

var all_items = []
var all_shop_items = []
var temp_page_items

var sort_types = ["All","Weapon","Armor","Headgear","Misc","Consumable"]
var sort_icons = [preload("res://inventory/icon/tooltip/infinite.png"), # All
				preload("res://inventory/icon/tooltip/icon444.png"), ## Weapon
				preload("res://inventory/icon/tooltip/icon633.png"), ## Armor
				preload("res://inventory/icon/tooltip/icon716.png"), ## Headgear
				preload("res://inventory/icon/tooltip/icon788.png"), ## Misc
				preload("res://inventory/icon/consumables/sm_potion.png")] ## Consumable
var current_sort_type = 0
var current_shop_sort_type = 0


onready var empty = preload("res://inventory/repo/empty.tres")

### MISC ###
onready var camera = GlobalCamera
onready var animation = $AnimationPlayer
onready var train_popup = $Action_Frame/train_button/train_popup
onready var tween = $Tween
onready var page_label = $Inventory_Frame/page_label
onready var shop_page_label = $Frame/Info/Shop_Panel/shop_page_label

func _ready():
	Global.shop_open = true
	Global.input_allowed = false
	load_shop()
	self.position = Vector2(screen_middle.x - 100,screen_middle.y)
	animation.play("action_down")
	load_inventory("All","All")
	HUD.tooltip_top("currancy",Global.currancy_1)
	
func load_shop():
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
	
func load_inventory(shop_filter,filter):
	clear_inventory()
	var items_on_page = 0
	var items_on_shop_page = 0

	for load_item in which_goat_node.goat_inventory:
		if filter == "All" or load_item.Item_Type == filter:
			all_items.append(load_item)
			
	for shop_load_item in which_npc_node.NPC_inventory:
		if shop_filter == "All" or shop_load_item.Item_Type == shop_filter:
			all_shop_items.append(shop_load_item)
			
	for item in (all_items.size()-current_page*12):
		if items_on_page < 12:
			load_items(all_items[item+(current_page*12)],inventory,"Empty")
			items_on_page += 1
			
	for shop_item in (all_shop_items.size()-current_shop_page*15):
		if items_on_shop_page < 15:
			load_items(all_shop_items[shop_item+(current_shop_page*15)],shop_inventory,"Shop")
			items_on_shop_page += 1

	
	for _slots in range(12-items_on_page):
		load_items(empty,inventory,"Player")
	for _shop_slots in range(15-items_on_shop_page):
		load_items(empty,shop_inventory,"Shop")
	
	number_of_pages = ceil(float(all_items.size())/12)
	if number_of_pages == 0: number_of_pages = 1
	page_label.text = str(current_page+1) + "/" + str(number_of_pages)
	
	number_of_shop_pages = ceil(float(all_shop_items.size())/15)
	if number_of_shop_pages == 0: number_of_shop_pages = 1
	shop_page_label.text = str(current_shop_page+1) + "/" + str(number_of_shop_pages)
	
	if current_page == 0: left_arrow.disabled = true
	else: left_arrow.disabled = false
	
	if current_shop_page == 0: left_shop_arrow.disabled = true
	else: left_shop_arrow.disabled = false
	
	if number_of_pages == current_page + 1: right_arrow.disabled = true
	else: right_arrow.disabled = false
	
	if number_of_shop_pages == current_shop_page + 1: right_shop_arrow.disabled = true
	else: right_shop_arrow.disabled = false
	
func clear_inventory():
	all_items = []
	all_shop_items = []
	
	for equipment in inventory.get_children():
		equipment.queue_free()
		
	for shop_equipment in shop_inventory.get_children():
		shop_equipment.queue_free()
	
	
func load_items(item,grid,origin):
	var item_scene = preload("res://scenes/inventory_item.tscn")
	var item_instance = item_scene.instance()
	item_instance.item_origin = origin
	item_instance.loaded_item = item.resource_path
	item_instance.which_goat_node = which_goat_node
	item_instance.which_shop_node = self
	grid.add_child(item_instance)							
	

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
	Global.shop_open = false
	Global.active_goat.input_allowed = true
	Global.input_allowed = true
	HUD.tooltip_top("hide",null)
	queue_free()


func _on_fight_button_pressed():
	Global.active_goat = which_goat_node.goat_id
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/battles/single_battle.tscn")
	pass # Replace with function body.


func _on_train_button_pressed():
	train_popup.unselect_all()
	train_popup.show()


func _on_sort_button_pressed():
	if current_sort_type == sort_icons.size() - 1:
		current_sort_type = 0
	else:
		current_sort_type += 1
	sort_texture.texture = sort_icons[current_sort_type]
	
	current_page = 0
	load_inventory(sort_types[current_shop_sort_type],sort_types[current_sort_type])


func _on_arrow_right_pressed():
	current_page += 1
	load_inventory(sort_types[current_shop_sort_type],sort_types[current_sort_type])


func _on_arrow_left_pressed():
	current_page -= 1
	load_inventory(sort_types[current_shop_sort_type],sort_types[current_sort_type])


func _on_shop_sort_button_pressed():
	if current_shop_sort_type == sort_icons.size() - 1:
		current_shop_sort_type = 0
	else:
		current_shop_sort_type += 1
	shop_sort_texture.texture = sort_icons[current_shop_sort_type]
	
	current_shop_page = 0
	load_inventory(sort_types[current_shop_sort_type],sort_types[current_sort_type])


func _on_shop_arrow_left_pressed():
	current_shop_page -= 1
	load_inventory(sort_types[current_shop_sort_type],sort_types[current_sort_type])


func _on_shop_arrow_right_pressed():
	current_shop_page += 1
	load_inventory(sort_types[current_shop_sort_type],sort_types[current_sort_type])
