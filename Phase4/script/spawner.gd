class_name Spawner extends Marker2D

var used_by_water: Array[Vector2i] = []
var used_by_trees: Array[Vector2i] = []
var free_cells: Array[Vector2i] = []
var world: Node = null
var tilemap: TileMap = null

const StickSpawner: PackedScene = preload("res://inventory/stick_collactable.tscn")
const SlimeSpawner: PackedScene = preload("res://scene/slime.tscn")

# Village Safe Zone (Center of starting village and radius)
const VILLAGE_SAFE_CENTER: Vector2 = Vector2(-50.0, 450.0)
const VILLAGE_SAFE_RADIUS: float = 680.0

@export var max_slimes: int = 8
@export var max_sticks: int = 0
@export var slime_spawn_interval: float = 5.0
var slime_spawn_timer: float = 0.0

var new_ground_layer: TileMapLayer = null


func _ready() -> void:
	world = get_node_or_null("/root/World")
	if world == null:
		world = get_parent()
	
	if has_node("../BeginningFields/Map/Ground"):
		new_ground_layer = get_node("../BeginningFields/Map/Ground")
		var water_layer = get_node_or_null("../BeginningFields/Map/Water")
		var rock_layer = get_node_or_null("../BeginningFields/Map/RockSlopes")
		used_by_water = BeginningFields.get_real_cells(water_layer) if water_layer != null else []
		var used_by_rocks = BeginningFields.get_real_cells(rock_layer) if rock_layer != null else []
		for cell in new_ground_layer.get_used_cells():
			if not used_by_water.has(cell) and not used_by_rocks.has(cell):
				free_cells.append(cell)
	elif has_node("../TileMap"):
		tilemap = get_node("../TileMap")
		used_by_water = tilemap.get_used_cells(1)
		used_by_trees = tilemap.get_used_cells(2)
		var rect = tilemap.get_used_rect()
		for i in rect.size.x:
			for j in rect.size.y:
				var tmp = Vector2i(i, j) 
				if !used_by_trees.has(tmp) and !used_by_water.has(tmp):
					free_cells.append(tmp)
	
	$Timer.start()


func is_in_safe_zone(pos: Vector2) -> bool:
	return pos.distance_squared_to(VILLAGE_SAFE_CENTER) < 462400.0 # 680.0 px


func get_spawn_position(cell: Vector2i) -> Vector2:
	if new_ground_layer != null and is_instance_valid(new_ground_layer):
		return new_ground_layer.to_global(new_ground_layer.map_to_local(cell))
	elif tilemap != null and is_instance_valid(tilemap):
		return tilemap.map_to_local(cell)
	return Vector2.ZERO


# True when nothing solid (tree, house, water, cliff) occupies the point.
func is_spot_free(pos: Vector2) -> bool:
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1
	query.collide_with_bodies = true
	query.collide_with_areas = false
	return get_world_2d().direct_space_state.intersect_point(query, 1).is_empty()


# Random free cell whose world position is not blocked.
func pick_free_cell() -> Vector2i:
	var cell: Vector2i = free_cells[randi() % free_cells.size()]
	if new_ground_layer == null:
		return cell
	for i in 12:
		if is_spot_free(get_spawn_position(cell)):
			break
		cell = free_cells[randi() % free_cells.size()]
	return cell


# Random free cell strictly OUTSIDE the village safe zone.
func pick_free_cell_for_enemy() -> Vector2i:
	if free_cells.is_empty():
		return Vector2i.ZERO
	for i in 25:
		var cell: Vector2i = free_cells[randi() % free_cells.size()]
		var pos: Vector2 = get_spawn_position(cell)
		if not is_in_safe_zone(pos) and is_spot_free(pos):
			return cell
	return Vector2i.ZERO


func get_active_slime_count() -> int:
	if world == null or not is_inside_tree():
		return 0
	return get_tree().get_nodes_in_group("slime").size()


func get_active_stick_count() -> int:
	if world == null or not is_inside_tree():
		return 0
	return get_tree().get_nodes_in_group("stick").size()


func add_stick_to_world() -> void:
	if max_sticks <= 0 or free_cells.is_empty() or world == null:
		return
	var rand_value: Vector2i = pick_free_cell()
	var new_stick = StickSpawner.instantiate()
	new_stick.position = get_spawn_position(rand_value)
	new_stick.z_index = 0
	new_stick.y_sort_enabled = true
	world.add_child(new_stick)


func add_slime_to_world() -> void:
	if free_cells.is_empty() or world == null:
		return
	var rand_value: Vector2i = pick_free_cell_for_enemy()
	if rand_value == Vector2i.ZERO:
		return
	var pos: Vector2 = get_spawn_position(rand_value)
	if is_in_safe_zone(pos):
		return
		
	var new_slime = SlimeSpawner.instantiate()
	new_slime.position = pos
	new_slime.scale = Vector2(2, 2)
	new_slime.z_index = 0
	new_slime.y_sort_enabled = true
	if "wander_range" in new_slime:
		new_slime.wander_range = randi_range(50, 150)
	world.add_child(new_slime)


func _on_timer_timeout() -> void:
	slime_spawn_timer += $Timer.wait_time
	if slime_spawn_timer >= slime_spawn_interval:
		slime_spawn_timer = 0.0
		if get_active_slime_count() < max_slimes:
			add_slime_to_world()
	
	$Timer.start()
