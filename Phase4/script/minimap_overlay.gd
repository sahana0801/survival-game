extends Control

var minimap: MiniMap


func _ready():
	minimap = get_parent() as MiniMap


func _draw():
	if minimap != null:
		minimap.draw_overlay(self)
