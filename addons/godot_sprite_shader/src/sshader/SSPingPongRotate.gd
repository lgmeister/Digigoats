tool
class_name SSPingPongRotate extends SShader

export(float, 0, 100, 0.1) var offset: float = 0.0 setget _set_offset
export(float, -10, 10, 0.01) var speed: float = 1.0 setget _set_speed
export(float, 0, 720, 0.1) var angle_arc: float = 60 setget _set_angle_arc
export(float, -2, 2, 0.001) var center_x: float = 0.5 setget _set_center_x
export(float, -2, 2, 0.001) var center_y: float = 0.5 setget _set_center_y
export(float, 0, 1, 0.001) var smooth_value: float = 1.0 setget _set_smooth_value


func _load_shader():
	return load(SHADER_FOLDER_BASE + "pingpong_rotate.shader")

func _set_offset(value):
	offset = value
	_set_shader_f_value("offset", value)

func _set_speed(value):
	speed = value
	_set_shader_f_value("speed", value)

func _set_angle_arc(value):
	angle_arc = value
	_set_shader_f_value("angle_arc", value)

func _set_center_x(value):
	center_x = value
	_set_shader_f_value("center_x", value)

func _set_center_y(value):
	center_y = value
	_set_shader_f_value("center_y", value)

func _set_smooth_value(value):
	smooth_value = value
	_set_shader_f_value("smooth_value", value)
