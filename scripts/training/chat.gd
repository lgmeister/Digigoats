extends Control

onready var chat_panel = $ChatPanel
onready var chat_text = $ChatPanel/chat_text
onready var type_box = $ChatPanel/type_box
onready var minimize_button = $top_bar/minimize

var minimized = true

func _ready():
	var scrollbar = chat_text.get_v_scroll()
	scrollbar.mouse_filter = Control.MOUSE_FILTER_PASS
	chat_panel.hide()
#	self.hide()


func _input(event):
	if event.is_action_pressed("ui_accept"):
		submit_message()


func _on_submit_pressed():
	submit_message()

func submit_message():
	if not minimized and type_box.text.replace(" ","") != "":
		
		var message = "[color=%s]\n%s:[/color] %s"\
		%[Network.usercolor,Network.username,type_box.text]
		print(Network.usercolor)
		chat_text.bbcode_text += message
		type_box.text = ""
		
		rpc("_send_message",Network.username,message)	
		
remote func _send_message(_player,message):
	chat_text.bbcode_text += message



func announcement(message):
	chat_text.bbcode_text += "[color=#00ffff]\n--- %s ---[/color]" %message


func _on_minimize_pressed():
	if minimized:
		chat_panel.show()
		minimized = false
		type_box.focus_mode = FOCUS_CLICK
		type_box.grab_focus()
	else:
		chat_panel.hide()
		minimized = true
		type_box.focus_mode = FOCUS_NONE
