extends Resource

class_name GOAT

export(String) var goat_name
export(Texture) var image
export(Color) var goat_color

export(int) var goat_max_health = 1
export(int) var goat_current_health = 1

export(int) var goat_max_energy = 100
export(int) var goat_current_energy = 100

export(int) var goat_max_happiness = 100
export(int) var goat_current_happiness = 100

export(float) var goat_dex = 1.0
export(float) var goat_str = 1.0
export(float) var goat_wis = 1.0
export(float) var goat_exp = 0.0
export(int) var goat_next_exp = 1000
export(int) var goat_level = 1

export(Array,Resource) var goat_inventory

export(Resource) var goat_weapon
export(Resource) var goat_headgear
export(Resource) var goat_armor
export(Resource) var goat_misc

export(Resource) var goat_particles
export(Resource) var goat_horns 

func get_Name() -> String:
	return goat_name
	
func get_Image() -> Texture:
	return image
	
func get_Inventory() -> Array:
	return goat_inventory

func get_Color() -> Color:
	return goat_color
	
func get_Dex() -> float:
	return goat_dex
	
func get_Str() -> float:
	return goat_str

func get_Wis() -> float:
	return goat_wis
	
func get_Exp() -> float:
	return goat_exp
	
func get_Next_Exp() -> int:
	return goat_next_exp
	
func get_Level() -> int:
	return goat_level
	
func get_Weapon():
	if goat_weapon == null:
		goat_weapon = load("res://inventory/repo/weapon/fist.tres")

	return goat_weapon

func get_Armor():
	return goat_armor

func get_Headgear():
	return goat_headgear

func get_Misc():
	return goat_misc
	
func get_Max_Health():
	return goat_max_health

func get_Current_Health():
	return goat_current_health
	
func get_Max_Energy():
	return goat_max_energy

func get_Current_Energy():
	return goat_current_energy
	
func get_Max_Happiness():
	return goat_max_happiness

func get_Current_Happiness():
	return goat_current_happiness

func set_Dex(number):
	goat_dex = number

func get_Particles() -> Resource:
	return goat_particles
	
func get_Horns() -> Resource:
	return goat_horns
