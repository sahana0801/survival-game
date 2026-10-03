class_name SlimeOrb extends Area2D

var speed: float = 190.0
var direction: Vector2 = Vector2.RIGHT
var damage: int = 14
var lifetime: float = 2.5
var elapsed: float = 0.0
var orb_color: Color = Color(0.2, 0.85, 0.4)


func _ready():
	set_as_top_level(true)


func _process(delta: float):
	elapsed += delta
	position += direction * speed * delta
	queue_redraw()
	
	if elapsed >= lifetime:
		queue_free()


func _draw():
	draw_circle(Vector2.ZERO, 7.0, orb_color)
	draw_circle(Vector2.ZERO, 4.5, Color.WHITE)
	draw_circle(-direction * 5.0, 3.5, Color(orb_color.r, orb_color.g, orb_color.b, 0.5))


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
