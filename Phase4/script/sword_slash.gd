class_name SwordSlash extends Area2D

var damage: int = 75
var duration: float = 0.20
var elapsed: float = 0.0
var knockback_strength: float = 300.0
var hit_enemies: Array = []


func _ready():
	set_as_top_level(true)
	# 25% Critical Hit Chance on Sword
	if randf() < 0.25:
		damage = int(round(damage * 1.5))


func sword_deal_damage():
	pass


func _process(delta: float):
	elapsed += delta
	queue_redraw()
	
	if elapsed >= duration:
		queue_free()


func _draw():
	var progress = clamp(elapsed / duration, 0.0, 1.0)
	var alpha = (1.0 - progress) * 0.95
	var current_radius = lerp(20.0, 44.0, progress)
	
	# Sweeping arc angle
	var start_angle = -PI * 0.42
	var end_angle = PI * 0.42
	var sweep_angle = lerp(start_angle, end_angle, clamp(progress * 1.5, 0.0, 1.0))
	
	# Draw glowing outer arc
	var points_outer: PackedVector2Array = []
	var points_inner: PackedVector2Array = []
	var segments = 18
	
	for i in range(segments + 1):
		var t = float(i) / float(segments)
		var angle = lerp(start_angle, sweep_angle, t)
		var dir = Vector2(cos(angle), sin(angle))
		points_outer.append(dir * current_radius)
		points_inner.append(dir * (current_radius * 0.45))
		
	# Draw crescent polygon
	var poly: PackedVector2Array = []
	for p in points_outer:
		poly.append(p)
	for i in range(points_inner.size() - 1, -1, -1):
		poly.append(points_inner[i])
		
	# Gradient glowing colors
	var core_color = Color(0.92, 0.96, 1.0, alpha)
	var outer_color = Color(0.25, 0.8, 1.0, alpha * 0.8)
	
	if poly.size() >= 3:
		draw_colored_polygon(poly, outer_color)
		
	# Draw sharp inner blade trail
	if points_outer.size() >= 2:
		draw_polyline(points_outer, core_color, 2.5)


func _on_area_entered(area: Area2D):
	_check_hit(area.get_parent(), area)


func _on_body_entered(body: Node2D):
	_check_hit(body, null)


func _check_hit(target: Node2D, _area: Area2D):
	if target == null or target in hit_enemies:
		return
		
	if target.has_method("enemy") or target.has_method("take_damage"):
		hit_enemies.append(target)
		var knockback_dir = (target.global_position - global_position).normalized()
		if knockback_dir == Vector2.ZERO:
			knockback_dir = Vector2.RIGHT.rotated(rotation)
			
		if target.has_method("apply_knockback"):
			target.apply_knockback(knockback_dir * knockback_strength)
