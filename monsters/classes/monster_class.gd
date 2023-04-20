tool
extends Resource

class_name MONSTER

export(String) var Monster_Name
export(SpriteFrames) var Monster_Texture
export(Vector2) var Monster_Scale = Vector2(1,1)

export(int) var Monster_HP = 1
export(int) var Monster_Speed = 30
export(int) var Monster_Sequence_Speed = 3 ### changes sequence every x amount of time
export(int) var Monster_Touch_Damage = 0

export(String,
	"none","random","seeking")\
	var Monster_Movement = "none"
	
export(Array,Resource) var Monster_Attacks

export(bool) var Destroy_Terrain = false
export(bool) var Boss = false

func get_Name() -> String:
	return Monster_Name
	
func get_Texture() -> Texture:
	return Monster_Texture
	
func get_Scale() -> Vector2:
	return Monster_Scale

func get_HP() -> Vector2:
	return Monster_HP
	
func get_Speed() -> int:
	return Monster_Speed
	
func get_Sequence_Speed() -> int:
	return Monster_Sequence_Speed	
	
func get_Movement() -> String:
	return Monster_Movement
	
func get_Attacks():
	return Monster_Attacks

func get_Destroy_Terrain():
	return Destroy_Terrain
	
func get_Touch_Damage():
	return Monster_Touch_Damage
	
func get_Boss():
	return Boss
