extends KinematicBody2D

export(Resource) var NPC setget _set_NPC

onready var emote = $emote
onready var emote_area = $emote_area
onready var sprite = $sprite
onready var light = $Light2D
onready var dialog_button = $DialogButton
onready var collision = $CollisionShape2D
onready var movement_timer = $MovementTimer
onready var raycast_right = $RaycastRight
onready var raycast_left = $RaycastLeft



var NPC_id

var NPC_active
var NPC_name
var NPC_shop_name
var NPC_sprite
var NPC_portrait
var NPC_work_loc
var NPC_Light
var NPC_Size
var NPC_sprite_offset
var Emote_offset
var NPC_type
var NPC_dialog
var NPC_inventory

var NPC_talk_pitch
var NPC_talk_voice



### Movement
var gravity = 1000
var velocity = Vector2(0,0)
var speed = 200
var movement_amount = 10 ### In seconds

### Event Type ###
var event_initiated = false

var goat_in_area = false
var goat_node

### Misc ###
var rng = RandomNumberGenerator.new()


func _ready():
	self.NPC = load("res://npcs/repo/%s.tres" %NPC_id)
	add_to_group("NPC")
	NPC_setup()
	Global.current_dialog = "Default" ## make dynamic
	
	if NPC_type == "Background":
		movement_timer.start(1)

func NPC_setup():
	position = NPC_work_loc
	sprite.frames = NPC_sprite
	sprite.scale = NPC_Size
	collision.scale = NPC_Size
	sprite.offset = NPC_sprite_offset
	emote.offset = Emote_offset
	
	if NPC_Light: light.show()

	
	if NPC_type == "Event":
		sprite.animation = "idle"
		sprite.playing = true
	elif NPC_type == "Shop":
		sprite.animation = "idle"
		sprite.playing = true
	else:
		sprite.animation = "idle"
		sprite.playing = true
	

func _set_NPC(newNPC : Resource):
	NPC = newNPC
	
	NPC_active = NPC.get_Active()
	NPC_name = NPC.get_Name()
	NPC_shop_name = NPC.get_Shop_Name()
	NPC_type = NPC.get_Type()
	NPC_sprite = NPC.get_Sprite()
	NPC_portrait = NPC.get_Portrait()
	NPC_work_loc = NPC.get_Work_Loc()
	NPC_Light = NPC.get_Light()
	NPC_Size = NPC.get_Size()
	NPC_sprite_offset = NPC.get_Sprite_Offset()
	Emote_offset = NPC.get_Emote_Offset()
	NPC_dialog = NPC.get_Dialog()
	NPC_inventory = NPC.get_Inventory()
	NPC_talk_pitch = NPC.get_Talk_Pitch()
	NPC_talk_voice = NPC.get_Talk_Voice()
	
	speed = NPC.get_Movement_Speed()
	movement_amount = NPC.get_Movement_Amount()
	
	
func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if NPC_type == "Background":
		if velocity.x > 1:
			sprite.animation = "walk_right"
		elif velocity.x < -1:
			sprite.animation = "walk_left"
		else:
			sprite.animation = "idle"
			
		if raycast_left.is_colliding():
			if "Dirt" or "Ground" in str(raycast_left.get_collider()):
				velocity.x = speed
		elif raycast_right.is_colliding():
			print(raycast_right.get_collider())
			if "Dirt" or "Ground" in str(raycast_right.get_collider()):
				velocity.x = -speed
				print(raycast_right.get_collider())
			
		

func _input(event):
	if event.is_action_pressed("action") and goat_in_area and NPC_dialog != null\
	and not event_initiated and Global.input_allowed and not Global.in_battle\
	and not Global.goat_in_training and goat_node.input_allowed:
		
		if NPC_type == "Background":
			movement_timer.stop()
			velocity.x = 0
			sprite.animation = "idle"
		
		Global.current_npc = self
		event_initiated = true
		goat_node.input_allowed = false
		var dialogue_resource = NPC_dialog
		DialogueManager.show_example_dialogue_balloon(Global.current_dialog,dialogue_resource)
		var _dialogue_line = yield(DialogueManager.get_next_dialogue_line(Global.current_dialog, dialogue_resource), "completed")
		yield(DialogueManager,"dialogue_finished")
		event_initiated = false
		
		if not Global.shop_open:
			goat_node.input_allowed = true
			
		if NPC_type == "Background": 	movement_timer.start(.1)


func _check_goat_in_area():
	for node in emote_area.get_overlapping_bodies():
		if node == Global.active_goat:
			show_emote(node)

func _on_emote_area_body_entered(body):
	show_emote(body)
			
func show_emote(body):
	if "goat" in str(body) and NPC_dialog != null and Global.npc_emote == false:
		if not event_initiated:
			Global.npc_emote = true
			emote.show()
			AUDIO.play("npc_touch")
			goat_in_area = true
			goat_node = body		
				

func _on_emote_area_body_exited(body):
	if "goat" in str(body) and NPC_dialog != null:
		Global.npc_emote = false
		emote.hide()
		goat_in_area = false
		
		get_tree().call_group("NPC","_check_goat_in_area")
		if body:
			pass
	



func _on_DialogButton_pressed():
	pass # Replace with function body.



func _on_MovementTimer_timeout():
	rng.randomize()
	var rand = rng.randi_range(0,3)
	
	if rand == 0:
		sprite.animation = "idle"
		velocity.x = 0
		movement_timer.start(2)
		return
	elif rand == 1:
		velocity.x = -speed
	elif rand == 2:
		sprite.animation = "walk_right"
		velocity.x = speed
		
	var random_time = rng.randf_range(movement_amount-2,movement_amount+2)
	movement_timer.start(random_time)
	
