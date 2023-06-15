extends Control

### Nodes ###
onready var key_label = $keyLabel
onready var binding_button = $bindingButton
onready var confirmation_dialog = $ConfirmationDialog
onready var change_letter_label = $ConfirmationDialog/ChangeLetterLabel

### Data ###
var original_keycode
var physical_key
var key_description
var temp_event

var key_convert = {
	"ui_up":"Move Up","ui_down":"Move Down","ui_left":"Move Left", "ui_right":"Move Right",
	"escape":"Menu", "profile":"Profile/Inventory","action":"Action","boost":"Boost"}

### Bools ###
var dialog_open = false

func _ready():
	temp_event = physical_key
	binding_button.text = str(physical_key).to_upper()
	
	key_label.text = key_convert[key_description]

func _input(event):
	if event is InputEventKey and dialog_open:
		physical_key = event.as_text()
		change_letter_label.text = str(physical_key)
		temp_event = event
#		var rawcode = InputMap.get_action_list(action)[0]
#		var physical_key = (OS.get_scancode_string(event.scancode))

func _on_bindingButton_pressed():
	confirmation_dialog.popup_centered()
	confirmation_dialog.window_title = key_description + " Key Binding"
	change_letter_label.text = str(physical_key).to_upper()
	dialog_open = true



func _on_ConfirmationDialog_popup_hide():
	dialog_open = false


func _on_ConfirmationDialog_confirmed():
	InputMap.action_erase_event(key_description,original_keycode)
	InputMap.action_add_event(key_description, temp_event)
	binding_button.text = temp_event.as_text().to_upper()
	print(key_description, "   " , temp_event.as_text())
