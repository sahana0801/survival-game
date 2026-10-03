class_name Arrow extends Area2D

var speed: float = 420.0
var damage: int = 15


func _ready() -> void:
	set_as_top_level(true)
	damage = PlayerStats.get_bow_damage()


func _physics_process(delta: float) -> void:
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func arrow_deal_damage() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") or body.has_method("enemy") or body.has_method("take_damage"):
		await get_tree().create_timer(0.01).timeout
		queue_free()
	elif body is TileMap or body is TileMapLayer or body is StaticBody2D:
		queue_free()
