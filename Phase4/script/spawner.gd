class_name Spawner extends Marker2D

var used_by_water
var used_by_trees
var free_cells = []
var world 
var tilemap

@onready var stick: Stick
@onready var appleTree: AppleTree
@onready var slime: Slime

const StickSpawner = preload("res://inventory/stick_collactable.tscn")
const AppleTreeSpawner = preload("res://scene/apple_tree.tscn")
const SlimeSpawner = preload("res://scene/slime.tscn")

var count_apple_trees = 0
var count_slimes = 0
var max_apple_trees = 10
var max_slimes = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = get_node("../TileMap")
	world = get_node("/root/World")
	used_by_water = tilemap.get_used_cells(1)
	used_by_trees = tilemap.get_used_cells(2)
	var rect = tilemap.get_used_rect()
	#print ("Rect: %s " % rect)
	for i in rect.size.x:
		for j in rect.size.y:
			var tmp = Vector2i(i, j) 
			if !used_by_trees.has(tmp) and !used_by_water.has(tmp):
				free_cells.append(tmp)
	#print(free_cells.size())
	#Place apple trees and slimes
	#for i in count_apple_trees:
	#	add_apple_tree_to_world()
	#for i in count_slimes:
	#	add_slime_to_world()
	
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func add_stick_to_world():
	var rand_value = free_cells[randi() % free_cells.size()]
	stick = StickSpawner.instantiate()
	stick.position = tilemap.map_to_local(rand_value)
	world.add_child(stick)


func add_apple_tree_to_world():
	var rand_value = free_cells[randi() % free_cells.size()]
	#print("AppleTree - randvalue: %s" % rand_value)
	appleTree = AppleTreeSpawner.instantiate()
	appleTree.position = tilemap.map_to_local(rand_value)
	world.add_child(appleTree)
	#print("AppleTree: %s" % tilemap.map_to_local(rand_value))
	var remove_id = free_cells.find(rand_value)
	#print("Remove ID: %s" % remove_id)
	free_cells.remove_at(remove_id)


func add_slime_to_world():
	var rand_value = free_cells[randi() % free_cells.size()]
	#print("Slime - randvalue: %s" % rand_value)
	slime = SlimeSpawner.instantiate()
	slime.position = tilemap.map_to_local(rand_value)
	slime.wander_range = randi_range(50, 150)
	world.add_child(slime)
	#print("Slime: %s" % tilemap.map_to_local(rand_value))


func _on_timer_timeout():
	if count_apple_trees < max_apple_trees:
		add_apple_tree_to_world()
		count_apple_trees += 1
	add_stick_to_world()
	if count_slimes < max_slimes:
		add_slime_to_world()
		count_slimes += 1
	
	$Timer.start()
