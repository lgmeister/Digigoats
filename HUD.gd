extends CanvasLayer

var pop_bounds = 560 ### When does HUD come up based on where cursor iss

var heart_scene = preload("res://scenes/battles/health_heart.tscn")

onready var bottom_hud = $bottom_hud
onready var animation = $AnimationPlayer
onready var boss_animation = $BossAnimation

onready var file_button = $bottom_hud/file_button
onready var file_popup = $bottom_hud/file_button/file_popup
onready var goat_button = $bottom_hud/goat_button
onready var goat_popup = $bottom_hud/goat_button/goat_popup
onready var time_label = $bottom_hud/time_label
onready var boss_label = $Boss_Bar/Label
onready var boss_bar_top = $Boss_Bar
onready var announcement_label = $CenterAnnouncementLabel
onready var health_grid = $health
onready var black_screen = $BlackScreen
onready var general_pop = $GenPop/GeneralPopupMenu ### used for whatever. Item right click etc
onready var tween = $Tween

### Tips ###
onready var tip_top = $tip_bar_top
onready var tip_bot = $tip_bar_bot
onready var tip_top_label = $tip_bar_top/Label
onready var tip_top_texture = $tip_bar_top/TextureRect
onready var tip_bot_label = $tip_bar_bot/Label
onready var tip_bot_texture = $tip_bar_bot/TextureRect

### Network ###
onready var game_info_label = $game_info_label
var chat_scene = load("res://scenes/network/chat.tscn")

### Bools ###
var tooltip_active = false ### Bottom only
var boss_bar_active = false ## health bar in?
var bottom_HUD = false
var menu_open = false
var middle_button = false

### Scenes ###
var chat



func _ready():
	pass


func _input(event):
	if event.is_action_pressed("mouse_middle_click"):
		middle_button = true
	if event.is_action_released("mouse_middle_click"):
		middle_button = false
		
	if event.is_action_pressed("escape") and tooltip_active:
		tooltip_bot("hide",null)
		
		
	if event is InputEventMouseMotion:	
		if event.position.y >= pop_bounds and not bottom_HUD and not middle_button and not Global.in_battle:
			slide_in()
		if event.position.y < pop_bounds and bottom_HUD:
			slide_out()

func load_chat():
	var scene_instance = chat_scene.instance()
	chat = scene_instance
	add_child(scene_instance)
	


func update_network_info():
	if Global.multiplayer_active:
		game_info_label.show()
		game_info_label.text = "Game Name: Random Name\nGame IP Address: %s" %Global.game_ip_address
			
func slide_in(): ### Bottom HUD ####
	bottom_HUD = true
	tween.interpolate_property(bottom_hud,"rect_position",Vector2(0,40),Vector2(0,0),.3,Tween.TRANS_QUART)
	tween.start()
	
func slide_out(): ### Bottom HUD ####
	if menu_open:
		return
	bottom_HUD = false
	tween.interpolate_property(bottom_hud,"rect_position",Vector2(0,0),Vector2(0,40),.3,Tween.TRANS_QUART)
	tween.start()
	

func _on_file_button_pressed():
	if menu_open:
		return
	menu_open = true
	file_popup.rect_position = Vector2(file_button.rect_global_position.x - 180, file_button.rect_global_position.y - 430)
	file_popup.show()


func _on_file_popup_id_pressed(_id):
#	print(id)
	menu_open = false


func _on_goat_button_pressed():
	if menu_open:
		return
	menu_open = true
	goat_populate()
	goat_popup.show()

func goat_populate(): ### populate goat_menu with each goat
	for goat in Global.loaded_goats:

		goat_popup.add_item\
		(Global.loaded_goats[goat]["id"] + " - " + \
		Global.loaded_goats[goat]["name"],\
		Global.loaded_goats[goat]["image"])
		
func _on_goat_popup_item_selected(index):
	var goat_number = goat_popup.get_item_text(index).left(5) ### Maybe change this to an array variable
	var goat_instance = get_tree().get_root().get_node("entry_world/%s" %goat_number)
	var view = get_viewport().get_visible_rect().size
	GlobalCamera.position = Vector2(goat_instance.global_position.x - view.x / 2 * GlobalCamera.zoom.x, \
	goat_instance.global_position.y - view.y / 2 * GlobalCamera.zoom.y - 100*GlobalCamera.zoom.y)
	goat_instance._on_goat_button_pressed()
	goat_popup.clear()
	goat_popup.hide()
	menu_open = false

func boss_bar(direction,title):
	if direction == "in":
		boss_label.text = title
		boss_animation.play("boss_bar_in")
		boss_bar_active = true
	elif direction == "out" and boss_bar_active:
		boss_animation.play("boss_bar_out")
		boss_bar_active = false
		
#	if title != null: announcement(title,"long")
		
func announcement(title,length):
	if length == "long":
		animation.playback_speed = 1
	elif length == "medium":
		animation.playback_speed = 2
	elif length == "short":
		animation.playback_speed = 3
	
	announcement_label.text = title
	animation.play("annoucement")
	
func chat_announcement(message):
	chat.announcement(message)
		
		
func add_health_bar(max_health,health):
	var odd = true
	if health % 2 == 0: odd = false
	var health_range = ceil(float(health)/2)

	for number in range(health_range):
		var scene_instance = heart_scene.instance()
		scene_instance.health_number = number
		health_grid.add_child(scene_instance)
		if number == health_range-1:
			scene_instance.current_heart = true
			if odd: scene_instance.initialize_odd()
		
	for _number in range(floor((max_health-health)/2)): ## for empty hearts (missing HP)
		var scene_instance = heart_scene.instance()
		health_grid.add_child(scene_instance)
		scene_instance.initialize_none()

func add_armor_bar(armor):
	Global.armor = 0
	var odd = true
	if armor % 2 == 0: odd = false
	var armor_range = ceil(float(armor)/2)
	Global.armor = armor
	
	for number in range(armor_range):
#		Global.armor += 1
		var scene_instance = heart_scene.instance()
		scene_instance.health_number = number
		scene_instance.type = "armor"
		health_grid.add_child(scene_instance)
		if number == armor_range-1:
			scene_instance.current_heart = true
			if odd: scene_instance.initialize_odd()

		
func remove_health_bar():
	for health in health_grid.get_children():
		health.queue_free()
		
		
func tooltip_top(type,value):
	if type == "currancy":
		tip_top_texture.texture = preload("res://visual/GUI/icons/individual_32x32/icon010.png")
	elif type == "hide":
		tip_top.hide()
		return
	elif type == "shake":
		animation.play("money_shake")
	tip_top_label.text = str(value)
	tip_top.show()
	
	
func tooltip_bot(type,value):
	if type == "tip":
		tip_bot_texture.texture = preload("res://visual/GUI/icons/individual_32x32/icon374.png")
	elif type == "hide":
		tip_bot.hide()
		tooltip_active = false
		return
	
	tip_bot_label.text = str(value)
	tip_bot.show()
	tooltip_active = true
	animation.play("tip_bot")
	yield(animation,"animation_finished")
	tooltip_active = false
	
func set_cursor(type):
	var normal_cursor = load("res://visual/GUI/cursors/Arrow_Rounded_Blue.png")
	var cross_cursor = load("res://visual/character/crosshair/convergence-target.png")
	if type == "normal": Input.set_custom_mouse_cursor(normal_cursor)
	elif type == "crosshair": Input.set_custom_mouse_cursor(cross_cursor)
