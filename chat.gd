extends Control

onready var chat_panel = $ChatPanel
onready var chat_text = $ChatPanel/chat_text
onready var type_box = $ChatPanel/type_box
onready var minimize_button = $top_bar/minimize

var minimized = true

### Discord ###
var discord_active = false
onready var discord_bot = $DiscordBot
var channel_id = "889249438890070064"
var bot_token = "MTEwMzgxOTI3MTIyNzg1NDg1MA.G8xNoB.LBmd1VgcQCMii3ECaaYNIZXuZcWzis2V7WOQvI"
var previous_user ### was the previous user me? don't add name to discord send


func _ready():
	var scrollbar = chat_text.get_v_scroll()
	scrollbar.mouse_filter = Control.MOUSE_FILTER_PASS
	chat_panel.hide()
		
	discord_bot.TOKEN = bot_token
	discord_bot.login()
	discord_bot.connect("bot_ready", self, "_on_DiscordBot_bot_ready")


func _input(event):
	if event.is_action_pressed("ui_accept"):
		submit_message()


func _on_submit_pressed():
	submit_message()

func submit_message():
	if not minimized and type_box.text.replace(" ","") != "":
		
		var message = "[color=%s]\n%s:[/color] %s"\
		%[Network.usercolor,Network.username,type_box.text]
		chat_text.bbcode_text += message
		rpc("_send_message",Network.username,message)	
	
	if discord_active:	
		var info_send
		if previous_user == Network.username:
			info_send = type_box.text
		else:
			info_send = "__**"+ Network.username + "**__:\n" + type_box.text
		discord_bot.send(channel_id,info_send)
		
	type_box.text = ""
		
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
		

func _on_DiscordBot_bot_ready(bot: DiscordBot):
	print('Logged in as ' + bot.user.username + '#' + bot.user.discriminator)
	print('Listening on ' + str(bot.channels.size()) + ' channels and '\
	+ str(bot.guilds.size()) + ' guilds.')
	discord_active = true


func _on_DiscordBot_message_create(_bot, message, channel):
	var user_sent_from = message["author"]["username"]
	
	 ### Check if last message from this GAME user ###
	if channel["id"] == channel_id:
		if message["author"]["bot"] == false:
			previous_user = message["author"]["username"] + " [Discord]"
			print("previous " + previous_user)
		elif ":" in message.content:
			previous_user = (message.content).get_slice(":",0).replace("*","").replace("_","")
			print("previous " + previous_user)
	if channel["id"] == channel_id and user_sent_from != "DigigoatBot":
		var content = message.content
		
		if content == null or content == "": return
		
		chat_text.bbcode_text\
		+= "\n[color=#00c3ff][Discord] [/color][color=#ffffff]%s: [/color]%s"\
		%[user_sent_from,content]

