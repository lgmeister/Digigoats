extends Node2D

var which_goat_node

var str_gain
var dex_gain
var wis_gain

var exp_gain

var local_exp
var local_max_exp
var local_previous_exp # for leveling

var mini = false ### is this the mini profile or regular?

onready var exp_bar = $Frame/Info/TabContainer/Stats/Bars/EXP_Bar
onready var exp_bar_label = $Frame/Info/TabContainer/Stats/Bars/EXP_Bar/EXP_Amount
onready var goat_pic = $"%Goat_Pic"

onready var exp_label = $Frame/Info/TabContainer/Stats/Exp_label
onready var str_label = $Frame/Info/TabContainer/Stats/Str_Label
onready var dex_label = $Frame/Info/TabContainer/Stats/Dex_Label
onready var wis_label = $Frame/Info/TabContainer/Stats/Wis_Label
onready var level_label = $Frame/Info/TabContainer/Stats/Level_Label
onready var goat_frame = $Frame/Info/goat_frame

onready var tween = $Tween
onready var timer = $Tick_Timer
onready var animation = $AnimationPlayer

func _ready():
	goat_pic.texture = which_goat_node.goat_image
	update_labels(false)
	which_goat_node.goat_exp += ceil(exp_gain)
	
	str_label.text = "Str: " + str(which_goat_node.goat_str) + " + " + str(str_gain)
	which_goat_node.goat_str += str_gain
	dex_label.text = "Dex: " + str(which_goat_node.goat_dex) + " + " + str(dex_gain)
	which_goat_node.goat_dex += dex_gain
	wis_label.text = "Wis: " + str(which_goat_node.goat_wis) + " + " + str(wis_gain)
	which_goat_node.goat_wis = wis_gain
	
	check_level_up()	
	
	tween.interpolate_property(exp_bar,"value",exp_bar.value,exp_bar.value + exp_gain,1)
	tween.start()
	
	save_stats()
	
	if mini: ### Quick Training
		animation.play("fade_in")
		yield(animation,"animation_finished")
		queue_free()
	
func update_labels(level):
	if level:
		exp_label.text = "Exp: 0 + " + str(which_goat_node.goat_exp)
		local_max_exp = int(ceil(which_goat_node.goat_exp))
		level_label.text = "Level: " + str(which_goat_node.goat_level)
	else:
		exp_label.text = "Exp: " + str(which_goat_node.goat_exp) + " + " + str(ceil(exp_gain))
		local_max_exp = int(ceil(which_goat_node.goat_exp + exp_gain))
		
	exp_bar.max_value = which_goat_node.goat_next_exp
	exp_bar.value = which_goat_node.goat_exp
	exp_bar_label.text = str(which_goat_node.goat_exp) + "/" + str(which_goat_node.goat_next_exp)
	local_exp = int(which_goat_node.goat_exp)
	timer.start(.02)

	
func _on_Tick_Timer_timeout():
	if local_exp < local_max_exp:
		local_exp += 1
		exp_bar_label.text = str(str(local_exp) + "/" + str(which_goat_node.goat_next_exp))
	else:
		which_goat_node.goat_exp += ceil(exp_gain)
		timer.stop()
		
		
func check_level_up():
	if which_goat_node.goat_exp > which_goat_node.goat_next_exp:
		which_goat_node.goat_level += 1
		print("LEVEL UP ", which_goat_node.goat_level)
		which_goat_node.goat_exp -= which_goat_node.goat_next_exp
		which_goat_node.goat_next_exp *= 1.1
		print("Next level needs ", which_goat_node.goat_next_exp, " exp" )
		save_stats()
		update_labels(true)

func save_stats():
	Global.active_goat.goat_exp = which_goat_node.goat_exp
	Global.active_goat.goat_level = which_goat_node.goat_level
	Global.active_goat.goat_next_exp = which_goat_node.goat_next_exp
	Global.active_goat.goat_str = which_goat_node.goat_str
	Global.active_goat.goat_dex = which_goat_node.goat_dex
	Global.active_goat.goat_wis = which_goat_node.goat_wis
	Global.active_goat.save_goat()
