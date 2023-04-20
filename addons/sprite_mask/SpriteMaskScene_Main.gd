tool
extends Node2D

func update_mask_texture(val):
	$MaskViewport/Mask.texture = val

func update_mask_layers(layers_to_show):
	$LightMask.range_item_cull_mask = layers_to_show

func update_mask_pos(val):
	$MaskViewport/Mask.position = val
	$MaskViewport/TrailMask.position = val

func update_mask_scale(val):
	$MaskViewport/Mask.scale = Vector2(val,val)
	$MaskViewport/TrailMask.process_material.scale = val

func update_follow_mouse(val):
	$MaskViewport/Mask.follow_mouse = val
	$MaskViewport/TrailMask.follow_mouse = val

func update_show_trail(val):
	$MaskViewport/TrailMask.emitting = val

func update_size(val):
	$MaskViewport.size = val
	$LightMask.offset = val/2
