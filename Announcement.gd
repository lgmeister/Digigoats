extends Control

### Scenes ###
var score_scene = load("res://scenes/main/score.tscn")


### Nodes ###
onready var tab_1 = $Frame/TabContainer/Tab1
onready var loading_label = $Frame/LoadingLabel

onready var tab_1_title = $Frame/TabContainer/Tab1/title
onready var tab_1_message = $Frame/TabContainer/Tab1/message
onready var tab_1_date = $Frame/TabContainer/Tab1/date


### Misc ###
var tab1name = "Main"

var announcementNumber = 0


func _ready():
	tab_1.name = tab1name
	load_announcement(announcementNumber)
	

func load_announcement(number):
	var message = AnnouncementText.announcements[number]
	
	if message["type"] == "main":
		tab_1_date.text = message["date"]
		tab_1_title.text = message["title"]
		tab_1_message.text = message["message"]


func _on_X_Button_pressed():
	Global.MAIN.remove_scene("announcement",0)


func _on_nextButton_pressed():
	if announcementNumber + 1 < AnnouncementText.announcements.size():
		announcementNumber += 1
		load_announcement(announcementNumber)


func _on_previousButton_pressed():
	if announcementNumber > 0:
		announcementNumber -= 1
		load_announcement(announcementNumber)


func _on_firstButton_pressed():
	load_announcement(0)


func _on_lastButton_pressed():
	load_announcement(AnnouncementText.announcements.size() - 1)
