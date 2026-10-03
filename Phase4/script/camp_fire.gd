class_name Campfire extends StaticBody2D

var is_burning: bool = true
var is_placed: bool = false
var player: CharacterBody2D = null
var tutorial_message_2_shown: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_glow: Sprite2D = get_node_or_null("FireGlow")
@onready var point_light: PointLight2D = get_node_or_null("PointLight2D")

var flicker_timer: float = 0.0
var base_glow_scale: Vector2 = Vector2(0.55, 0.55)
var current_light_intensity: float = 0.0

const GLOW_COLOR: Color = Color(1.0, 0.58, 0.18)


func _ready() -> void:
	set_process(true)
	if sprite != null and sprite.animation == &"not_burning":
		is_burning = false
	else:
		is_burning = true
		if sprite != null:
			sprite.play("burning")
	
	# Only illuminate if it is night and burning; otherwise turn off during daytime
	var is_night_time: bool = PlayerStats.is_night if PlayerStats != null else false
	current_light_intensity = 1.0 if (is_night_time and is_burning) else 0.0
	_apply_light_intensity(current_light_intensity, 0.0)


func _process(delta: float) -> void:
	if player != null and Input.is_action_just_pressed("fire"):
		toggle_fire()
	
	# Determine target intensity: 1.0 if night & burning, 0.0 during daytime or when extinguished
	var is_night_time: bool = PlayerStats.is_night if PlayerStats != null else false
	var target_intensity: float = 1.0 if (is_burning and is_night_time) else 0.0
	
	# Smooth fade transition (approx 1.2s between day and night or toggle)
	if current_light_intensity != target_intensity:
		current_light_intensity = move_toward(current_light_intensity, target_intensity, delta * 0.85)
	
	if current_light_intensity > 0.001:
		flicker_timer += delta * 7.0
		var wave: float = sin(flicker_timer) * 0.04 + randf_range(-0.02, 0.02)
		_apply_light_intensity(current_light_intensity, wave)
	else:
		if fire_glow != null and fire_glow.visible:
			fire_glow.visible = false
		if point_light != null and point_light.enabled:
			point_light.enabled = false


func _apply_light_intensity(intensity: float, wave: float) -> void:
	if intensity <= 0.001:
		if fire_glow != null:
			fire_glow.visible = false
		if point_light != null:
			point_light.enabled = false
		return
	
	# 1. Warm amber additive glow for night atmosphere
	if fire_glow != null:
		fire_glow.visible = true
		fire_glow.scale = base_glow_scale * (1.0 + wave * 0.05)
		var glow_a: float = clampf((0.36 + wave * 0.04) * intensity, 0.0, 0.45)
		fire_glow.modulate = Color(GLOW_COLOR.r, GLOW_COLOR.g, GLOW_COLOR.b, glow_a)
	
	# 2. PointLight2D soft light
	if point_light != null:
		point_light.enabled = true
		point_light.energy = clampf((0.65 + wave * 0.12) * intensity, 0.0, 0.8)


func toggle_fire() -> void:
	is_burning = !is_burning
	if is_burning:
		sprite.play("burning")
	else:
		sprite.play("not_burning")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player = body as CharacterBody2D
		if !tutorial_message_2_shown:
			PlayerStats.send_message("Nhấn \"F\" để thắp sáng hoặc dập tắt lửa trại")
			tutorial_message_2_shown = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
