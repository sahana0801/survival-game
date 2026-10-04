class_name Arrow extends Area2D

var speed: float = 450.0
var damage: int = 15
var is_crit: bool = false
var arrow_tier_idx: int = 1
var lifetime: float = 2.0


func _ready() -> void:
	set_as_top_level(true)
	
	# Dynamic Arrow Sprite based on Archer Weapon Tier
	var tex_path = PlayerStats.get_arrow_texture_path()
	if ResourceLoader.exists(tex_path) and has_node("Sprite2D"):
		$Sprite2D.texture = load(tex_path)
	arrow_tier_idx = PlayerStats.get_arrow_tier_index()
	
	# Roll attack damage & crit from PlayerStats
	var hit_data = PlayerStats.roll_attack_damage()
	damage = hit_data["damage"]
	is_crit = hit_data["is_crit"]


func _physics_process(delta: float) -> void:
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()


func arrow_deal_damage() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	# Bỏ qua người chơi
	if body is Player or body.has_method("player"):
		return
	
	# Bỏ qua sông, nước, và các layer vách đá/địa hình -> Mũi tên bay xuyên qua sông/vách đá!
	if body.name == "WaterBlock" or body.is_in_group("water") or body.is_in_group("terrain"):
		return
	if body is TileMap or body is TileMapLayer:
		var b_name := body.name.to_lower()
		if "water" in b_name or "cliff" in b_name or "ground" in b_name or "road" in b_name or "decor" in b_name:
			return
	
	# Va chạm quái vật / kẻ địch
	if body.is_in_group("enemy") or body.has_method("enemy") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage(damage, is_crit)
		Helpers.spawn_arrow_impact(global_position, arrow_tier_idx)
		await get_tree().create_timer(0.01).timeout
		queue_free()
		return
	
	# Va chạm các vật cản kín kiên cố (tường biên giới, tường boss arena, nhà cửa)
	if body.name.begins_with("ArenaWalls") or body.name == "collisions" or body.name.begins_with("outer_border") or body.name.begins_with("House"):
		Helpers.spawn_arrow_impact(global_position, arrow_tier_idx)
		queue_free()
