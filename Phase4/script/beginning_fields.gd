class_name BeginningFields extends Node2D
## Post-processing for the imported "Beginning Fields" Tiled map.
## - Removes the baked campfire tiles (the game uses its own animated camp_fire scene).
## - The Tiled "Water" layer is filled edge to edge with a transparent filler tile, so the
##   real water cells are every cell that is NOT the most common tile. Interior water cells
##   have no tile collision, so a blocker is generated for them, plus the drinking area.

@export var water_area_path: NodePath = ^"../water_collect_area"

@onready var map: Node2D = $Map


func _ready() -> void:
	_remove_baked_campfire()
	var water := map.get_node_or_null("Water") as TileMapLayer
	if water != null:
		_build_water_collision(water)
		_build_water_area(water)


## Cells of a layer that contain a real tile (ignores the single most common filler tile).
static func get_real_cells(layer: TileMapLayer) -> Array[Vector2i]:
	var counts := {}
	var cells := layer.get_used_cells()
	for c in cells:
		var key := str(layer.get_cell_source_id(c)) + str(layer.get_cell_atlas_coords(c))
		counts[key] = counts.get(key, 0) + 1
	var filler := ""
	var best := -1
	for k in counts:
		if counts[k] > best:
			best = counts[k]
			filler = k
	var result: Array[Vector2i] = []
	for c in cells:
		var key := str(layer.get_cell_source_id(c)) + str(layer.get_cell_atlas_coords(c))
		if key != filler:
			result.append(c)
	return result


func _remove_baked_campfire() -> void:
	for n in map.get_node("Object Layer 1").get_children():
		if n.name.begins_with("Animation_Campfire"):
			n.queue_free()


func _cell_world_size(layer: TileMapLayer) -> Vector2:
	return Vector2(layer.tile_set.tile_size) * layer.global_scale


func _build_water_collision(water: TileMapLayer) -> void:
	var body := StaticBody2D.new()
	body.name = "WaterBlock"
	add_child(body)
	var size := _cell_world_size(water)
	var has_physics := water.tile_set.get_physics_layers_count() > 0
	for cell in get_real_cells(water):
		var data := water.get_cell_tile_data(cell)
		# Shore tiles already carry their own collision polygons.
		if has_physics and data != null and data.get_collision_polygons_count(0) > 0:
			continue
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = size
		shape.shape = rect
		shape.position = to_local(water.to_global(water.map_to_local(cell)))
		body.add_child(shape)


func _build_water_area(water: TileMapLayer) -> void:
	var area := get_node_or_null(water_area_path) as Area2D
	if area == null:
		return
	for child in area.get_children():
		if child is CollisionPolygon2D:
			child.queue_free()
	var size := _cell_world_size(water) * 3.0
	for cell in get_real_cells(water):
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = size
		shape.shape = rect
		shape.position = area.to_local(water.to_global(water.map_to_local(cell)))
		area.add_child(shape)
