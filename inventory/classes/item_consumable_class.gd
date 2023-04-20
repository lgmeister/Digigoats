tool
extends GOAT_ITEM

class_name GOAT_ITEM_CONSUMABLE

export(String,"HP","MP","Happiness") var Consumable_Type = "HP"

export(int) var Consumable_Positive_Effect = 0

export(String,"None", "HP","MP","Happiness") var Consumable_Negative_Type = "None"

export(int) var Consumable_Negative_Effect = 0



func get_Name() -> String:
	return Item_Name

func get_Icon() -> Texture:
	return Item_Icon
	
func get_Cost() -> int:
	return Item_Cost
	
func get_Description() -> String:
	return Item_Description
	
func get_Consume_Type() -> String:
	return Consumable_Type
	
func get_Consume_Pos_Eff() -> float:
	return Consumable_Positive_Effect
	
func get_Consume_Neg_Type() -> String:
	return Consumable_Negative_Type
	
func get_Consume_Neg_Eff() -> float:
	return Consumable_Negative_Effect
	
