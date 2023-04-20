 
extends TextureButton

export(Resource) var Item setget _setItem

var loaded_item

var item_type
var item_name
var item_icon
var item_cost
var item_damage
var item_armor
var item_description
var item_amount

### Consumables Only ###
var consumable_type  # HP, MP, etc
var consumable_pos_eff
var consumable_neg_type # HP, MP, etc
var consumable_neg_eff

var item_origin = "Player" ## Shop? Player? etc

var which_goat_node
var which_shop_node

var item_empty = false ### Is this an empty slot?
var drop_zone ## Where an item is being dropped (inventory)
var specific_type = null ## Can only a weapon etc be placed here?
var item_held = false
var currently_equipped = false


### Tooltip ###
onready var tooltip = $tooltip
onready var tool_title = $tooltip/title_label
onready var tool_gold = $tooltip/gold_label
onready var gold_icon = $tooltip/gold_label/icon
onready var tool_label_1 = $tooltip/label_1
onready var tool_label_2 = $tooltip/label_2
onready var tool_icon_1  = $tooltip/label_1/icon
onready var tool_icon_2 = $tooltip/label_2/icon
onready var tool_description = $tooltip/description


onready var item = $item_node/item
onready var item_node = $item_node
onready var amount_label = $amount_label

onready var profile = which_goat_node.goat_profile

var popup = HUD.general_pop

var fists = load("res://inventory/repo/weapon/fist.tres")

func _ready():
	set_process(false)
	self.Item = load(loaded_item)
	if item_empty: return
	
	load_info()
	load_tooltip()
	
func _process(_delta):
	if item_empty: return
	if item_held:
		item_node.global_position = get_global_mouse_position() - self.rect_size/2

func _setItem(newItem : Resource):
	Item = newItem
	
	item_type = Item.get_Item_Type()
	item_name = Item.get_Name()
	item_icon = Item.get_Icon()
	item_cost = Item.get_Cost()
	item_description = Item.get_Description()
	item_amount = Item.get_Amount()
	
	if item_type == "Weapon":item_damage = Item.get_Damage()
	if item_type == "Armor":item_armor = Item.get_Armor_Class()
	if item_type == "Empty": item_empty = true
	
	if item_type == "Consumable":
		consumable_type = Item.get_Consume_Type()
		consumable_pos_eff = Item.get_Consume_Pos_Eff()
		consumable_neg_type = Item.get_Consume_Neg_Type()
		consumable_neg_eff = Item.get_Consume_Neg_Eff()
	
	
func load_info():
	item.texture = item_icon
	
	if item_origin == "Shop":
		item_cost *= 2
		
	if item_amount > 1:
		amount_label.text = str(item_amount)

func load_tooltip():
	if item_empty: return

	if item_type == "Weapon":
		tool_icon_1.texture = load("res://inventory/icon/tooltip/icon178.png")
		tool_label_1.text = str(item_damage)
	elif item_type == "Consumable":
		tool_icon_1.texture = load("res://inventory/icon/tooltip/icon104.png")
		tool_label_1.text = str(consumable_pos_eff) 
		## Add negative effects later on
		
		
	elif item_type == "Armor":
		tool_icon_1.texture = load("res://inventory/icon/tooltip/icon008.png")
		tool_label_1.text = str(item_armor) 

	tool_title.text = item_name
	tool_description.text = item_description
	if item_cost >= 0:
		tool_gold.text = str(item_cost)
	else:
		gold_icon.hide()
		tool_gold.hide()
		

func _on_grid_mouse_entered():
	if item_empty: return
	tooltip.show()

func _on_grid_mouse_exited():
	if item_empty: return
	tooltip.hide()


func _on_grid_button_down():
	if item_empty or Global.shop_open: return
	amount_label.hide()
	tooltip.hide()
	set_process(true)
	item_node.z_index = 2
	item_held = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	

func _on_grid_button_up():	
	amount_label.show()
	set_process(false)
	item_node.z_index = 0
	item_held = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	item_node.global_position = self.rect_global_position 
	
	if drop_zone == null: return
	
	if drop_zone.specific_type == null:
		drop_zone.add_new_item(loaded_item,false)
		item_empty = true
	elif drop_zone.specific_type == item_type:
		drop_zone.add_new_item(loaded_item,true)
		item_empty = true
	else:
		return
		
	if drop_zone.specific_type == "Weapon":
		which_goat_node.goat_weapon = load(loaded_item)
		which_goat_node.goat_inventory.erase(Item)
		profile.weapon_equipped = true
		currently_equipped = true ## is this line needed??
		which_goat_node.load_weapon()	
			
	elif drop_zone.specific_type == "Armor":
		which_goat_node.goat_armor = load(loaded_item)
		which_goat_node.goat_inventory.erase(Item)
		profile.armor_equipped = true
		currently_equipped = true ## is this line needed?? I think so?
		
	elif drop_zone.specific_type == "Misc":
		which_goat_node.goat_misc = load(loaded_item)
		which_goat_node.goat_inventory.erase(Item)
		profile.misc_equipped = true
		currently_equipped = true 
	
	elif drop_zone.specific_type == "Headgear":
		which_goat_node.goat_headgear = load(loaded_item)
		which_goat_node.goat_inventory.erase(Item)
		profile.headgear_equipped = true
		currently_equipped = true 
		which_goat_node.load_headgear()	

	if drop_zone.specific_type == null:  ### Dropped in a regular inventory spot
		if item_type == "Weapon" and currently_equipped:
			which_goat_node.goat_weapon = null
			profile.weapon_equipped = false
			currently_equipped = false 
			which_goat_node.goat_inventory.append(Item)
			which_goat_node.load_weapon()	
			
		elif item_type == "Armor" and currently_equipped:
			which_goat_node.goat_armor = null
			profile.armor_equipped = false
			currently_equipped = false
			which_goat_node.goat_inventory.append(Item)
			
		elif item_type == "Misc" and currently_equipped:
			which_goat_node.goat_misc = null
			profile.misc_equipped = false
			currently_equipped = false
			which_goat_node.goat_inventory.append(Item)
			
		elif item_type == "Headgear" and currently_equipped:
			which_goat_node.goat_headgear = null
			profile.headgear_equipped = false
			currently_equipped = false## is this line needed??
			which_goat_node.goat_inventory.append(Item)
			which_goat_node.load_headgear()	

	which_goat_node.save_goat()
	add_new_item("res://inventory/repo/empty.tres",false)
	profile.load_equipment()	
	


func _on_Area2D_area_entered(area):
	if item_empty:
		area.get_owner().drop_zone = self

func _on_Area2D_area_exited(area):
	if area.get_owner().drop_zone == self: area.get_owner().drop_zone = null
	else: return
	
func add_new_item(new_item,is_equipped):
	amount_label.text = ""
	loaded_item = new_item
	currently_equipped = is_equipped
	item_empty = false
	set_process(false)
	self.Item = load(loaded_item)
	
	load_info()
	load_tooltip()
	

func _on_right_button_pressed():
	if item_empty: return
	
	popup.connect("id_pressed", self, "_on_item_pressed")
	popup.connect("popup_hide",self,"_on_popup_hide")
	popup.clear()
	
	if Global.shop_open:
		popup.add_item("Buy")
		popup.add_item("Sell")
		
		if item_origin == "Shop":
			popup.set_item_disabled(1,true)
		else:
			popup.set_item_disabled(0,true)
			
		if item_cost <= 0:
			popup.set_item_disabled(1,true)
			popup.set_item_disabled(0,true)
		
	else:
		if item_type == "Consumable":
			popup.add_item("Consume")
			
		else:
			if currently_equipped:
				popup.add_item("Unequip")
			else:
				popup.add_item("Equip")
			
			
	popup.rect_global_position = get_global_mouse_position()
	popup.popup()
	

func _on_item_pressed(id):
	var action = HUD.general_pop.get_item_text(id)
	if action == "Unequip":
		if item_type == "Weapon":
			profile.weapon_equipped = false
			which_goat_node.goat_weapon = null
			which_goat_node.goat_inventory.append(Item)
			which_goat_node.load_weapon()	### This is here to load aesthetics 
		elif item_type == "Armor":
			profile.armor_equipped = false
			which_goat_node.goat_armor = null
			which_goat_node.goat_inventory.append(Item)
		elif item_type == "Misc":
			profile.misc_equipped = false
			which_goat_node.goat_misc = null
			which_goat_node.goat_inventory.append(Item)
		elif item_type == "Headgear":
			profile.headgear_equipped = false
			which_goat_node.goat_headgear = null
			which_goat_node.goat_inventory.append(Item)
			which_goat_node.load_headgear() ### This is here to load aesthetics 
			
		add_new_item("res://inventory/repo/empty.tres",false)
		which_goat_node.save_goat()
		profile.load_inventory(profile.sort_types[profile.current_sort_type])
		profile.load_equipment()

	elif action == "Equip":
		if item_type == "Weapon":
			if profile.weapon_equipped:
#				if not which_goat_node.goat_weapon.Item_Name == "Goat Fists":
				which_goat_node.goat_inventory.append(which_goat_node.goat_weapon)
			which_goat_node.goat_weapon = load(loaded_item)
			which_goat_node.goat_inventory.erase(Item)	
			which_goat_node.load_weapon()	
		elif item_type == "Armor":
			if profile.armor_equipped:
				which_goat_node.goat_inventory.append(which_goat_node.goat_armor)
			which_goat_node.goat_armor = load(loaded_item)
			which_goat_node.goat_inventory.erase(Item)		
		elif item_type == "Misc":
			if profile.misc_equipped:
				which_goat_node.goat_inventory.append(which_goat_node.goat_misc)
			which_goat_node.goat_misc = load(loaded_item)
			which_goat_node.goat_inventory.erase(Item)		
		elif item_type == "Headgear":
			if profile.headgear_equipped:
				which_goat_node.goat_inventory.append(which_goat_node.goat_headgear)
			which_goat_node.goat_headgear = load(loaded_item)
			which_goat_node.goat_inventory.erase(Item)	
			which_goat_node.load_headgear()	
		
		which_goat_node.save_goat()
		profile.load_inventory(profile.sort_types[profile.current_sort_type])
		profile.load_equipment()	
		
	elif action == "Sell":
		Global.currancy_1 += item_cost
		which_goat_node.goat_inventory.erase(Item)	
		Global.current_npc.NPC_inventory.append(Item)
		HUD.tooltip_top("money",Global.currancy_1)
		add_new_item("res://inventory/repo/empty.tres",false)
		which_goat_node.save_goat()
		which_shop_node.load_inventory(
			which_shop_node.sort_types[which_shop_node.current_shop_sort_type],
			which_shop_node.sort_types[which_shop_node.current_sort_type])
			
	elif action == "Buy":
		if Global.currancy_1 < item_cost:	
			HUD.tooltip_top("shake",Global.currancy_1)
		else:
			which_goat_node.goat_inventory.append(Item)
			Global.current_npc.NPC_inventory.erase(Item)
			Global.currancy_1 -= item_cost
			HUD.tooltip_top("money",Global.currancy_1)
			
			add_new_item("res://inventory/repo/empty.tres",false)
			which_goat_node.save_goat()
			which_shop_node.load_inventory(
				which_shop_node.sort_types[which_shop_node.current_shop_sort_type],
				which_shop_node.sort_types[which_shop_node.current_sort_type])
		
	elif action == "Consume":
		if consumable_type == "HP":
			which_goat_node.goat_current_health += consumable_pos_eff
			if which_goat_node.goat_current_health > which_goat_node.goat_max_health:
				which_goat_node.goat_current_health = which_goat_node.goat_max_health
				
		Item.Item_Amount -= 1
		
		if Item.Item_Amount == 0: which_goat_node.goat_inventory.erase(Item)
		
		which_goat_node.save_goat()
		profile.load_inventory(profile.sort_types[profile.current_sort_type])
		profile.update_bars("slow")
		

func _on_popup_hide():
	popup.disconnect("id_pressed", self, "_on_item_pressed")
	popup.disconnect("popup_hide",self,"_on_popup_hide")
