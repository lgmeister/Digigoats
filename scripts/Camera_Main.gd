extends Camera2D


var previous_location
var mouse_start_pos
var screen_start_position
var dragging = false

var following_goat


#### Events ####
var intro_ani = false


### Min Max Screen ####
var min_screen_y = 0
var max_screen_y = -100
var min_screen_x = -200
var max_screen_x = 600

const camera_zoom_level = .1

onready var screen_mid = get_viewport_rect().size / 2
onready var tween = $Tween

func _ready():
	pass
	
func _process(_delta):
	if Global.goat_in_training or Global.in_battle: return
	
	if following_goat != null:
		self.position = following_goat.global_position - Vector2(screen_mid.x,screen_mid.y)
	
func reset():
#	smoothing_enabled = false
	position = Vector2(0,0)	
	
	
func _start_game():
	intro_ani = true
	tween.interpolate_property(self,"position",Vector2(0,-3300),Vector2(0,0),7)
	tween.start()
	yield(tween,"tween_completed")
	intro_ani = false
	

func _input(event):
	### Skip Intro
	if event.is_action_pressed("escape") and intro_ani:
		tween.stop(self)
		position = Vector2(0,0)
		intro_ani = false
	
	
	
	### Drag Screen
	if event.is_action("mouse_middle_click") and not Global.in_battle:
		check_bounderies()
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position = zoom * (mouse_start_pos - event.position) + screen_start_position


	### Zoom
	if event.is_action("ui_page_down") and not Global.in_battle:
		zoom_out()

	if event.is_action("ui_page_up") and not Global.in_battle:
		zoom_in()
		
		
func zoom_in():
	if zoom <= Vector2(.3,.3):
		zoom = Vector2(.3,.3)
		return
			
	smoothing_enabled = false		
	self.zoom.x -= Global.camera_zoom_level
	self.zoom.y -= Global.camera_zoom_level
	
	if Global.controlling_goat == null:
		var mouse_pos = get_global_mouse_position()
		var local_mouse = get_local_mouse_position()
		position = mouse_pos * zoom - screen_mid * zoom
		get_viewport().warp_mouse(local_mouse)
	yield(get_tree().create_timer(.1),"timeout")
	smoothing_enabled = true	
	



func zoom_out():
	if zoom >= Vector2(1,1):
		zoom = Vector2(1,1)
		return
			
	self.zoom.x += Global.camera_zoom_level
	self.zoom.y += Global.camera_zoom_level
	
	smoothing_enabled = false		
	yield(get_tree().create_timer(.1),"timeout")
	smoothing_enabled = true	

func check_bounderies():
	return ### Take out and fix
# warning-ignore:unreachable_code
	if position.y > min_screen_y * zoom.y:
			position.y = min_screen_y
	if position.y < max_screen_y * zoom.y:
			position.y = max_screen_y
			
	if position.x < min_screen_x * zoom.x:
			position.x = min_screen_x
	if position.x > max_screen_x * zoom.x:
			position.x = max_screen_x


