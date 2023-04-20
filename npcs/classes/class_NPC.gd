extends Resource

class_name NPC

export(bool) var npc_active = true
export(String) var npc_name
export(String) var npc_shop_name
export(String,"Background","Shop","Event") var npc_type = "Background"
export(SpriteFrames) var npc_sprite
export(Texture) var npc_portrait

export(bool) var npc_light = false
export(Vector2) var npc_size = Vector2(1,1)
export(Vector2) var npc_sprite_offset = Vector2(0,0)
export(Vector2) var npc_emote_offset = Vector2(0,0)

export(Vector2) var work_location
export(Resource) var npc_dialog

export(Array,Resource) var npc_inventory

func get_Active() -> bool:
	return npc_active

func get_Name() -> String:
	return npc_name
	
func get_Shop_Name() -> String:
	return npc_shop_name

func get_Type() -> String:
	return npc_type
	
func get_Sprite() -> SpriteFrames:
	return npc_sprite

func get_Portrait() -> Texture:
	return npc_portrait

func get_Work_Loc() -> Vector2:
	return work_location
	
func get_Light() -> bool:
	return npc_light
	
func get_Size() -> Vector2:
	return npc_size
	
func get_Sprite_Offset() -> Vector2:
	return npc_sprite_offset
	
func get_Emote_Offset() -> Vector2:
	return npc_emote_offset
	
func get_Dialog() -> Resource:
	return npc_dialog
	
func get_Inventory() -> Array:
	return npc_inventory
