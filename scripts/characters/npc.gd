extends KinematicBody2D

export(Resource) var NPC setget _set_NPC

onready var emote = $emote
onready var sprite = $sprite
onready var light = $Light2D
onready var dialog_button = $DialogButton
onready var collision = $CollisionShape2D


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


### Movement
var gravity = 1000
var velocity = Vector2(0,0)

### Event Type ###
var event_initiated = false

var goat_in_area = false
var goat_node


func _ready():
	self.NPC = load("res://npcs/repo/%s.tres" %NPC_id)
	NPC_setup()
	Global.current_dialog = "Default" ## make dynamic
	 

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
	
	
func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	

func _input(event):
	if event.is_action_pressed("action") and goat_in_area and NPC_dialog != null\
	and not event_initiated and Global.input_allowed:
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


func _on_emote_area_body_entered(body):
	if "goat" in str(body) and NPC_dialog != null:
		if not event_initiated:
			emote.show()
			goat_in_area = true
			goat_node = body
			

func _on_emote_area_body_exited(body):
	if "goat" in str(body) and NPC_dialog != null:
		emote.hide()
		goat_in_area = false


func _on_DialogButton_pressed():
	pass # Replace with function body.

