tool
extends TextureButton


func _enter_tree():
	connect("button_down",self,"_button_down")
	connect("button_up",self,"_button_up")

func _button_down():
	AUDIO.play("click_down")
	
func _button_up():
	AUDIO.play("click_up")
