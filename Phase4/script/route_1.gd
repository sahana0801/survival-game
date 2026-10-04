class_name Route1 extends Node2D

const SKELETON_SCENE: PackedScene = preload("res://scene/skeleton.tscn")
const RESPAWN_TIME: float = 35.0

@onready var monsters_container: Node2D = $Monsters


func _ready() -> void:
	if monsters_container != null:
		for child in monsters_container.get_children():
			if child is Skeleton:
				track_skeleton(child, child.position)


func track_skeleton(sk: Skeleton, spawn_pos: Vector2) -> void:
	if not sk.skeleton_died.is_connected(_on_skeleton_died):
		sk.skeleton_died.connect(_on_skeleton_died.bind(spawn_pos))


func _on_skeleton_died(spawn_pos: Vector2) -> void:
	_schedule_respawn(spawn_pos)


func _schedule_respawn(spawn_pos: Vector2) -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
		
	await tree.create_timer(RESPAWN_TIME).timeout
	
	if not is_inside_tree() or not is_instance_valid(monsters_container):
		return
		
	var new_sk = SKELETON_SCENE.instantiate()
	new_sk.position = spawn_pos
	monsters_container.add_child(new_sk)
	track_skeleton(new_sk, spawn_pos)
