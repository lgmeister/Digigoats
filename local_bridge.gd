extends Control


## Nodes ##
onready var loading = $Loading
onready var loading_label = $Loading/Label
onready var security_text = $Frame/Security/SecurityLabel
onready var eye_button = $Frame/Security/EyeButton
onready var security = $Frame/Security
onready var security_check = $Frame/SecurityCheck
onready var time_remaining = $TimeRemaining
onready var random_button = $Frame/Security/RandomButton
onready var check_data_timer = $CheckDataTimer
onready var openButton = $Frame/OpenButton
onready var connect_timer = $ConnectTimer

### Scenes ###
var title_scene

### Icons ###
var eye = load("res://visual/GUI/icons/UI/sight.png")
var eye_dis = load("res://visual/GUI/icons/UI/sight-disabled.png")


### Bools ###
var connection = false
var wallet_open = false ### is wallet open?
var attempting = false


### Info ###
var send_attempt = 0
var main_address
var ip_address
var all_tokens = []
var exp_time = 0
var current_time
var security_code = ""
var experation_amount = 120 ### Seconds
var exp_time_remaining = experation_amount
var final_check_time = 20 ### Every x seconds

var final_data
	
### Network ###
var headers = ["X-Master-Key:$2b$10$PpCK9hebSlugKnT4JXEps.4g6t79anBTAEbPB66L0GnsiSzKuGww.","Content-Type:application/json"]

var final_http_request = HTTPRequest.new()
var final_time_http_request = HTTPRequest.new()

### Misc ###
var rng = RandomNumberGenerator.new()
var randChar = [
	"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p",
	"q","r","s","t","u","v","w","x","y","z","!","@","#","$","%","^",
	"&","*","(",")","1","2","3","4","5","6","7","8","9","10"
	]
	
	

func _ready():
	add_child(final_http_request)
	final_http_request.connect("request_completed",self,"_pull_final_data")
	
	add_child(final_time_http_request)
	final_time_http_request.connect("request_completed",self,"_final_time_request_completed")
	
func _process(delta):
	if exp_time_remaining < experation_amount:
		exp_time_remaining -= 1 * delta
		
		time_remaining.text = "Login Expires in: " + str(floor(exp_time_remaining)) + " seconds"
		if exp_time_remaining <= 0:
			exp_time_remaining = experation_amount
			time_remaining.hide()
			openButton.show()
			security_check.disabled = false
			random_button.disabled = false
			loading.hide()
	
func _input(event):
	if event.is_action_pressed("escape") and attempting:
		stop_all	()
	
	
func _IP_request_completed(result, _response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Could not get to API")
		
		
	var json = JSON.parse(body.get_string_from_utf8())
	ip_address = json.result["ipNumeric"]
	
	print("IP ADDRESS: " + str(ip_address))

func _on_OpenButton_pressed():
	loading.show()
	loading_label.text = "Loading..."
	openButton.hide()
	OS.set_clipboard(security_code)
	load_ip()
	load_time()
	pull_info()
	
		
func load_time():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed",self,"_time_request_completed")
	http_request.request("http://worldtimeapi.org/api/timezone/utc")
	
func load_ip():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed",self,"_IP_request_completed")
	http_request.request("https://api.bigdatacloud.net/data/client-ip")
	
	
func disconnect_wallet():
	JavaScript.eval("""
		async function f1(){
		await ergoConnector.nautilus.disconnect();
		};
		f1();
	""")

		
		
func _time_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	
	print("CURRENT UNIX TIME: " + str(json.result["unixtime"]))
	exp_time = int(json.result["unixtime"]) + experation_amount
	current_time = json.result["unixtime"]


func pull_info():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed",self,"_data_pull_completed")
	http_request.request("https://api.jsonbin.io/v3/b/64655b6a8e4aa6225e9f0583/latest",headers)
	

func send_info(previousData):
	send_attempt += 1
	if ip_address == null or exp_time == null:
		push_warning("Send Attempt #%s, No data, trying again" %send_attempt)
		yield(get_tree().create_timer(1),"timeout")
		if send_attempt >3:
			push_warning("Send attempt timeout, try again later")
			return
		else:
			send_info(previousData)
			return
	else:
		print("Sending data")
		
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed",self,"_send_info_completed")
	
	previousData[ip_address] =\
		{
		"tokens":all_tokens,
		"expiration": exp_time,
		"security":security_code
		}

	
	var query = JSON.print(previousData)
	http_request.request("https://api.jsonbin.io/v3/b/64655b6a8e4aa6225e9f0583",headers,\
	false, HTTPClient.METHOD_PUT, query)
	

func _send_info_completed(_result, _response_code, _headers, _body):
# warning-ignore:return_value_discarded
	OS.shell_open("https://ephemeral-bridge.netlify.app/")
	loading_label.text += "\nPress Esc to Stop"
	attempting = true
	time_remaining.show()
	
	security_check.disabled = true
	random_button.disabled = true
	exp_time_remaining -= 1
	check_data_timer.start(final_check_time)
	

func _data_pull_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var previousData = (json.result["record"])
	print(previousData)
	
	send_info(previousData)
	

func _on_EyeButton_pressed():
	if security_text.secret:
		security_text.secret  = false
		eye_button.icon = eye
	else:
		security_text.secret  = true
		eye_button.icon = eye_dis


func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		security.show()
		random_hash()
	else:
		security.hide()
		security_code = ""


func _on_RandomButton_pressed():
	random_hash()
	

func random_hash():
	security_code = ""
	rng.randomize()
	
	for _i in 36:
		var tempChar = randChar[rng.randi_range(0,randChar.size()-1)]
		security_code += tempChar
		
	security_text.text = security_code
	
	


func _on_CheckDataTimer_timeout():
	print("CHECKING FINAL TIME")
	final_http_request.request("https://api.jsonbin.io/v3/b/64655b6a8e4aa6225e9f0583/latest",headers)
	
	
func _pull_final_data(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	var previousData = (json.result["record"])
	if str(ip_address) in previousData:
		final_data = previousData[str(ip_address)]
		if previousData[str(ip_address)]["tokens"] == []:
			print("No tokens here. Rechecking in %s seconds" % final_check_time)
			
			check_data_timer.start(final_check_time)
			loading_label.text += "\nStill Loading..."
			return
		else:
			final_data = previousData[str(ip_address)]["tokens"]
			final_time_http_request.request("http://worldtimeapi.org/api/timezone/utc")
	else:
		print("Data is not here...")
		
	stop_all()
	

func _final_time_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
#	print("CURRENT UNIX TIME: " + str(json.result["unixtime"]))
	current_time = int(json.result["unixtime"])
	if current_time < exp_time:
		print("Data Recieved")
		custom_data_parser()
	else:
		final_data = null
		OS.alert("Time has expired, try again...")
		
func stop_all():
	check_data_timer.stop()
	exp_time_remaining = 0
		
		
func custom_data_parser(): ### This should be custom to each game
	for token in final_data:
		if "Ergoats" in str(token):
			Global.goats_to_load.append(str(token.keys()).get_slice("#",1).replace("]",""))	
		
	security.hide()
	openButton.text = "Sucessfully Bridged"
	openButton.disabled = true
	title_scene.load_ingame_goats()
	Global.MAIN.remove_scene("bridge",2)
	


func _on_BackButton_pressed():
	openButton.disabled = true
	Global.MAIN.remove_scene("bridge",0)
