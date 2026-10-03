class_name Spawner extends Marker2D

var used_by_water
var used_by_trees
var free_cells = []
var world 
var tilemap

@onready var stick: Stick
@onready var slime: Slime

const StickSpawner = preload("res://inventory/stick_collactable.tscn")
const SlimeSpawner = preload("res://scene/slime.tscn")

var count_slimes = 0
var max_slimes = 0

var new_ground_layer: TileMapLayer = null

func _ready():
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


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


# Random free cell whose world position is not blocked (falls back after a few tries).
func pick_free_cell() -> Vector2i:
	var cell: Vector2i = free_cells[randi() % free_cells.size()]
	if new_ground_layer == null:
		return cell
	for i in 12:
		if is_spot_free(get_spawn_position(cell)):
			break
		cell = free_cells[randi() % free_cells.size()]
	return cell


func add_stick_to_world():
	if free_cells.is_empty(): return
	var rand_value = pick_free_cell()
	stick = StickSpawner.instantiate()
	stick.position = get_spawn_position(rand_value)
	world.add_child(stick)




func add_slime_to_world():
	if free_cells.is_empty(): return
	var rand_value = pick_free_cell()
	slime = SlimeSpawner.instantiate()
	slime.position = get_spawn_position(rand_value)
	slime.scale = Vector2(2, 2)
	slime.wander_range = randi_range(50, 150)
	world.add_child(slime)
	#print("Slime: %s" % tilemap.map_to_local(rand_value))


func _on_timer_timeout():
	add_stick_to_world()
	if count_slimes < max_slimes:
		add_slime_to_world()
		count_slimes += 1
	
	$Timer.start()
