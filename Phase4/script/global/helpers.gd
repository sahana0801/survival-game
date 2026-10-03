extends Node

const FloatingTextScene = preload("res://scene/floating_text.tscn")


func choose(array: Array):
	array.shuffle()
	return array.front()


func spawn_damage_number(global_pos: Vector2, value, color: Color = Color.WHITE, is_crit: bool = false, prefix: String = "", suffix: String = ""):
	var tree = get_tree()
	if tree == null:
		return
	var current_scene = tree.current_scene
	if current_scene == null:
		return
		
	var text_node = FloatingTextScene.instantiate()
	text_node.global_position = global_pos + Vector2(0, -12)
	current_scene.add_child(text_node)
	text_node.setup(value, color, is_crit, prefix, suffix)
