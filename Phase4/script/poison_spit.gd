class_name PoisonSpit extends Area2D

var speed: float = 230.0
var direction: Vector2 = Vector2.RIGHT
var damage: int = 12
var lifetime: float = 2.0
var elapsed: float = 0.0


func _ready():
	set_as_top_level(true)


func _process(delta: float):
	elapsed += delta
	position += direction * speed * delta
	queue_redraw()
	
	if elapsed >= lifetime:
		queue_free()


func _draw():
	# Draw glowing toxic poison glob
	draw_circle(Vector2.ZERO, 5.0, Color(0.2, 0.95, 0.3, 0.9))
	draw_circle(Vector2.ZERO, 3.0, Color(0.8, 1.0, 0.5, 1.0))
	draw_circle(-direction * 4.0, 2.5, Color(0.15, 0.75, 0.25, 0.6))


func _on_body_entered(body: Node2D):
	if body.has_method("player"):
		if body.has_method("hurtByEnemy"):
			body.hurtByEnemy(self)
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		queue_free()


func _on_area_entered(area: Area2D):
	if area.name == "hurtBox":
		var p = area.get_parent()
		if p != null and p.has_method("hurtByEnemy"):
			p.hurtByEnemy(self)
		queue_free()
