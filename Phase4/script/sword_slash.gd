class_name SwordSlash extends Area2D

# Sát thương cơ bản roll từ PlayerStats
var damage: int = 15
var is_crit: bool = false
var duration: float = 0.20
var elapsed: float = 0.0
var hit_enemies: Array[Node2D] = []


func _ready():
	set_as_top_level(true)
	var hit_data = PlayerStats.roll_attack_damage()
	damage = hit_data["damage"]
	is_crit = hit_data["is_crit"]


func sword_deal_damage() -> void:
	pass


func _physics_process(delta: float):
	elapsed += delta
	if elapsed >= duration:
		queue_free()


func _on_area_entered(area: Area2D):
	_check_hit(area.get_parent(), area)


func _on_body_entered(body: Node2D):
	_check_hit(body, null)


func _check_hit(target: Node2D, _area: Area2D = null) -> void:
	if target == null or target in hit_enemies:
		return
	if target.is_in_group("player") or target.name == "Player":
		return
		
	if target.is_in_group("enemy") or target.has_method("enemy") or target.has_method("take_damage") or target.has_method("take_hit"):
		hit_enemies.append(target)
		
		# Bia tập đánh phản hồi cử động (Training dummy wobble)
		if target.has_method("take_hit"):
			target.take_hit(global_position)
			
		# Áp dụng sát thương trực tiếp lên quái vật
		if target.has_method("take_damage"):
			target.take_damage(damage, is_crit)
