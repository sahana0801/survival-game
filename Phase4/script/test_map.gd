extends Node2D

var used_by_water
var used_by_trees
var free_cells = []
var tilemap
var world 

@onready var stick: Stick
@onready var appleTree: AppleTree
@onready var slime: Slime

const StickSpawner = preload("res://inventory/stick_collactable.tscn")
const AppleTreeSpawner = preload("res://scene/apple_tree.tscn")
const SlimeSpawner = preload("res://scene/slime.tscn")

var count_apple_trees = 0
var count_slimes = 0
var max_apple_trees = 2
var max_slimes = 3

@onready var chest = $Chest
@onready var inventory_chest = chest.ctrl_inventory_stacked
@onready var inventory_player = $Player.ctrl_inventory_stacked

@onready var inv2 = $Player/InventoryStacked

#var inventory: CtrlInventoryStacked

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap = get_node("TileMap")
	world = get_node("/root/test_map")
	used_by_water = tilemap.get_used_cells(1)
	used_by_trees = tilemap.get_used_cells(2)
	var rect = tilemap.get_used_rect()
	for i in rect.size.x:
		for j in rect.size.y:
			var tmp = Vector2i(i, j) 
			if !used_by_trees.has(tmp) and !used_by_water.has(tmp):
				free_cells.append(tmp)
	
	# init chest
	PlayerStats.inventory = $Chest/InventoryStacked
	PlayerStats.inventory.create_and_add_item("health_potion")
	PlayerStats.player_inventory = $Player/InventoryStacked
	PlayerStats.c_inventory = $Chest/CtrlInventoryStacked
	PlayerStats.cp_inventory = $Player/CtrlInventoryStacked
	
	$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("right_mouse") and inventory_chest.visible and inventory_player.visible:
		PlayerStats.check_item_selected(PlayerStats.c_inventory)
		PlayerStats.check_item_selected(PlayerStats.cp_inventory)


func add_stick_to_world():
	var rand_value = free_cells[randi() % free_cells.size()]
	#print(rand_value)
	var stick = StickSpawner.instantiate()
	stick.position = tilemap.map_to_local(rand_value)
	add_child(stick)
	
func add_apple_tree_to_world():
	var rand_value = free_cells[randi() % free_cells.size()]
	#print("AppleTree - randvalue: %s" % rand_value)
	var appleTree = AppleTreeSpawner.instantiate()
	appleTree.position = tilemap.map_to_local(rand_value)
	world.add_child(appleTree)
	#print("AppleTree: %s" % tilemap.map_to_local(rand_value))
	var remove_id = free_cells.find(rand_value)
	#print("Remove ID: %s" % remove_id)
	free_cells.remove_at(remove_id)


func add_slime_to_world():
	var rand_value = free_cells[randi() % free_cells.size()]
	var slime = SlimeSpawner.instantiate()
	slime.position = tilemap.map_to_local(rand_value)
	world.add_child(slime)
	#print("Slime: %s" % tilemap.map_to_local(rand_value))

func _on_timer_timeout():
	if count_apple_trees < max_apple_trees:
		add_apple_tree_to_world()
		count_apple_trees += 1
	add_stick_to_world()
	if count_slimes < max_slimes:
		#add_slime_to_world()
		count_slimes += 1
	$Timer.start()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
