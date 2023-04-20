extends Node

var URL
var request_type



#### Clock ####
var clock_running = false
var stopwatch = 0
var hour = 0
var minute = 0
var second = 0


func _process(delta):
	if not clock_running:
		return
		
	stopwatch += delta
	second = stopwatch
		
	if second > 59:
		second = 0
		minute += 1
		stopwatch = -1
	if minute > 59:
		minute = 0
		hour += 1
	if hour > 23:
		hour = 0
	else:
		second += 1
		HUD.time_label.text = "%02d:%02d:%02d"  % [hour,minute,second]




func request(type):
	request_type = type
	var new_request = HTTPRequest.new()
	add_child(new_request)
	new_request.connect("request_completed", self, "_on_request_completed")
	
	if type == "time":
		URL = "https://worldtimeapi.org/api/timezone/Etc/UTC"
	elif type == "version":
		URL = "versionurlhere"
		
	new_request.request(URL)
	
	
func _on_request_completed(_result, _response_code, _headers, body):
	if body == null or str(body) == "[]":
#		print(body)
		print("no time data")
		
		return

	var json = JSON.parse(body.get_string_from_utf8())
	
	if request_type == "time":
#		print(json.result)
		if json.result == null:
			print("Cannot retrieve date/time")
			return 
		var time = ((str((json.result)["datetime"]).right(11)).left(8).replace(":",""))

		hour = int(time.left(2))
		minute = int(time.left(4).right(2))
		second = int(time.right(4))
		
		HUD.time_label.text = "%02d:%02d:%02d"  % [hour,minute,second]
		clock_running = true
		
	#	var date = Global.season_end_date - int(json.result["day_of_year"])
	#	var hour = Global.season_end_time_hour - int(time.left(2))
	#	var minute = Global.season_end_time_min - int(time.left(4).right(2))
	#	var second = Global.season_end_time_sec - int(time.right(4))
	
	elif request_type == "version":
		if "version" in str(json.result):
			print ("Newest Version is: " + str(json.result))
#			print ("Current Version is: " + globals.version)
#		if json.result["version"] != globals.version:
#			get_tree().change_scene("res://Scenes/wrongversion.tscn")
#		else:
#			print("correct version")
#			$TitleScreen/versionLabel.text = "Version Alpha "+globals.version
#


