tool
extends Resource

class_name GOAT_ITEM

export(String,"Empty","Weapon","Armor","Consumable","Headgear","Misc") var Item_Type
export(String) var Item_Name
export(Texture) var Item_Icon
export(int) var Item_Amount = 1
export(int) var Item_Cost
export(String, MULTILINE) var Item_Description = "NEED INFO HERE"

func get_Item_Type() -> String:
	return Item_Type
	
func get_Name() -> String:
	return Item_Name

func get_Icon() -> Texture:
	return Item_Icon
	
func get_Amount() -> int:
	return Item_Amount
	
func get_Cost() -> int:
	return Item_Cost

func get_Description() -> String:
	return Item_Description
