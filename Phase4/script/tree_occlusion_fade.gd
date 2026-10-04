class_name TreeOcclusionFade extends Area2D

var target_sprite: Sprite2D = null
var parent_body: Node2D = null
var is_faded: bool = false
var tween: Tween = null
var target_player: Node2D = null
var is_inside: bool = false


func setup(p_body: Node2D, p_sprite: Sprite2D) -> void:
	parent_body = p_body
	target_sprite = p_sprite
	
	if target_sprite != null and target_sprite.texture != null:
		var tex_size: Vector2 = target_sprite.texture.get_size()
		var shape := RectangleShape2D.new()
		# Canopy covers the upper 80% of the tree/house
		shape.size = Vector2(tex_size.x * 1.1, tex_size.y * 0.82)
		
		var col := CollisionShape2D.new()
		col.shape = shape
		# Position the detection shape over the canopy (above the base)
		col.position = Vector2(target_sprite.offset.x, target_sprite.offset.y - tex_size.y * 0.08)
		add_child(col)
	
	collision_layer = 0
	collision_mask = 1 # Player is on layer 1
	monitoring = true
	monitorable = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.has_method("player") or body.name == "Player":
		target_player = body
		is_inside = true
		_update_fade()


func _on_body_exited(body: Node2D) -> void:
	if body == target_player:
		is_inside = false
		target_player = null
		_update_fade()


func _physics_process(_delta: float) -> void:
	if is_inside:
		_update_fade()


func _update_fade() -> void:
	if target_sprite == null or not is_instance_valid(target_sprite):
		return
		
	var should_fade: bool = false
	if is_inside and target_player != null and is_instance_valid(target_player):
		# Player is behind the base of the object
		if target_player.global_position.y < parent_body.global_position.y + 6.0:
			should_fade = true
			
	if should_fade != is_faded:
		is_faded = should_fade
		if tween != null and tween.is_valid():
			tween.kill()
		tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		var target_alpha: float = 0.40 if is_faded else 1.0
		tween.tween_property(target_sprite, "modulate:a", target_alpha, 0.22)
