tool
extends GOAT_ITEM

class_name GOAT_ITEM_WEAPON

export(Texture) var Attack_Icon
export(Color) var Attack_Modulate = Color(1,1,1,1)
export(String, "none","flame","magic","trail") var Weapon_Particles = "none"
export(String, "melee-slash","melee-stab","ranged") var Weapon_Style = "ranged"
export(float) var Weapon_Damage = 1.0
export(int) var Weapon_Speed = 750
export(float) var Time_Between_Shots = 1.0
export(int) var Weapon_Range = 2000
export(String,"normal","full_arc","seeking") var Weapon_Type = "normal"

export(Vector2) var Weapon_Scale = Vector2(1,1)

export(bool) var Hit_Player
export(bool) var Hit_Enemies
export(bool) var Ignore_Terrain
export(bool) var Destroy_Terrain




func get_Name() -> String:
	return Item_Name
	
func get_Style() -> String:
	return Weapon_Style

func get_Icon() -> Texture:
	return Item_Icon
	
func get_Modulate() -> Color:
	return Attack_Modulate
	
func get_Cost() -> int:
	return Item_Cost

func get_Damage() -> int:
	return Weapon_Damage
	
func get_Range() -> int:
	return Weapon_Range
	
func get_Type() -> String:
	return Weapon_Type
	
func get_Speed() -> int:
	return Weapon_Speed
	
func get_Scale() -> Vector2:
	return Weapon_Scale

func get_Ignore_Terrain() -> bool:
	return Ignore_Terrain
	
func get_Destroy_Terrain() -> bool:
	return Destroy_Terrain
	
func get_Hit_Player() -> bool:
	return Hit_Player
	
func get_Hit_Enemies() -> bool:
	return Hit_Enemies
	
func get_Time_Between() -> float:
	return Time_Between_Shots
	
func get_Description() -> String:
	return Item_Description
	
func get_Attack_Icon() -> Texture:
	return Attack_Icon

func get_Particles() -> String:
	return Weapon_Particles
