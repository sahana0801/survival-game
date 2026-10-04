class_name ShadowWraith extends CharacterBody2D

const SPEED: float = 75.0
var max_health: int = 180
var current_health: int = max_health
var is_dead: bool = false
var is_active_at_night: bool = false
var player: Node2D = null

var blink_timer: float = 0.0
const BLINK_INTERVAL: float = 4.5
var is_blinking: bool = false
var knockback: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: TextureProgressBar = $healthBar
@onready var laugh_audio: AudioStreamPlayer2D = $LaughAudio


func _ready():
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health
		
	PlayerStats.DayStarted.connect(_on_day_started)
	PlayerStats.NightStarted.connect(_on_night_started)
	
	if PlayerStats.is_night:
		_awaken_wraith()
	else:
		_sleep_wraith()


func _sleep_wraith():
	is_active_at_night = false
	visible = false
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = true
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.disabled = true
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.disabled = true
	if health_bar != null:
		health_bar.visible = false


func _awaken_wraith():
	if is_dead:
		is_dead = false
		current_health = max_health
		if health_bar != null:
			health_bar.value = current_health
			
	is_active_at_night = true
	visible = true
	set_physics_process(true)
	$CollisionShape2D.disabled = false
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = false
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.disabled = false
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.disabled = false
	if health_bar != null:
		health_bar.visible = true
		
	# Ethereal rising fade-in
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.85, 1.2)
	
	if laugh_audio != null:
		laugh_audio.pitch_scale = randf_range(0.9, 1.2)
		laugh_audio.play()


func _on_day_started():
	if !is_active_at_night:
		return
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	if not is_inside_tree():
		return
	_sleep_wraith()


func _on_night_started():
	_awaken_wraith()


func enemy():
	pass


func apply_knockback(force: Vector2):
	knockback = force


func _physics_process(delta: float):
	if is_dead or !is_active_at_night:
		return
		
	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, delta * 520.0)
		move_and_slide()
		return
		
	# Ethereal floating hover bobbing
	var float_offset = sin(Time.get_ticks_msec() * 0.004) * 0.35
	position.y += float_offset
	
	if blink_timer > 0.0:
		blink_timer -= delta
		
	if player != null and is_instance_valid(player) and player.get("is_alive") and !is_blinking:
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * SPEED
		sprite.flip_h = dir.x < 0
		move_and_slide()
		
		# Shadow Blink behind player
		var dist_sq = global_position.distance_squared_to(player.global_position)
		if dist_sq < 57600.0 and dist_sq > 2500.0 and blink_timer <= 0.0: # 50px < dist < 240px
			perform_shadow_blink()


func perform_shadow_blink():
	if player == null or is_dead or !is_active_at_night:
		return
		
	is_blinking = true
	blink_timer = BLINK_INTERVAL
	
	if laugh_audio != null:
		laugh_audio.pitch_scale = randf_range(1.1, 1.4)
		laugh_audio.play()
		
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.08, 0.25)
	await tween.finished
	if not is_inside_tree():
		return
	
	if is_dead or player == null or !is_active_at_night:
		return
		
	# Reappear 38px behind or to the side of the player
	var behind_dir = (global_position - player.global_position).normalized()
	if behind_dir == Vector2.ZERO:
		behind_dir = Vector2.UP
	global_position = player.global_position + behind_dir * 38.0
	
	Helpers.spawn_damage_number(global_position, "✦ SHADOW BLINK ✦", Color(0.7, 0.3, 1.0), true)
	
	# Fade in
	var tween_in = create_tween()
	tween_in.tween_property(self, "modulate:a", 0.88, 0.2)
	await tween_in.finished
	if not is_inside_tree():
		return
	is_blinking = false


func take_damage(damage: int, is_crit: bool = false):
	if is_dead or !is_active_at_night:
		return
		
	current_health -= damage
	if health_bar != null:
		health_bar.value = current_health
		
	var num_color = Color(1.0, 0.6, 0.1) if is_crit else Color(0.85, 0.5, 1.0)
	Helpers.spawn_damage_number(global_position, damage, num_color, is_crit, "-")
	
	# Spectral hurt flash
	modulate = Color(2.0, 1.0, 2.0, 1.0)
	var tree = get_tree()
	if tree != null:
		await tree.create_timer(0.12).timeout
	if not is_inside_tree():
		return
	modulate = Color(1.0, 1.0, 1.0, 0.85)
	
	if current_health <= 0:
		death()


func death():
	is_dead = true
	is_active_at_night = false
	if health_bar != null:
		health_bar.visible = false
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.disabled = true
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = true
		
	PlayerStats.shooting_level(12)
	
	# Death spiral dissolve
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.6, 0.1), 0.4)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
	await tween.finished
	if not is_inside_tree():
		return
	
	_sleep_wraith()
	scale = Vector2.ONE


func _on_detection_area_body_entered(body: Node2D):
	if body.has_method("player"):
		player = body


func _on_detection_area_body_exited(body: Node2D):
	if body == player:
		player = null


func _on_hit_box_area_entered(area: Area2D):
	if !is_active_at_night:
		return
	var damage = 0
	var is_crit = area.is_crit if "is_crit" in area else false
	if area.has_method("arrow_deal_damage"):
		damage = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		take_damage(damage, is_crit)
	elif area.has_method("sword_deal_damage"):
		# Sword deals +20% bonus holy damage to Wraiths!
		var s_dmg = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		damage = int(round(s_dmg * 1.2))
		take_damage(damage, is_crit)
