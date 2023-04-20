extends Node2D


onready var tween = $Tween




func day_to_night():
	emit_signal("nighttime")
	
#	tween.interpolate_property(world_canvas, "color",
#		Color(1,1,1,1), Color(.1,.008,.008,1), 5,
#		Tween.TRANS_LINEAR)
#	tween.start()	
