extends StaticBody2D


func _ready():
	fall_from_tree()


func fall_from_tree():
	$AnimationPlayer.play("falling_from_tree")
	var tree = get_tree()
	if tree != null:
		await tree.create_timer(1.5).timeout
	if not is_inside_tree():
		return
	$AnimationPlayer.play("fade")
	tree = get_tree()
	if tree != null:
		await tree.create_timer(0.3).timeout
	if not is_inside_tree():
		return
	queue_free()
