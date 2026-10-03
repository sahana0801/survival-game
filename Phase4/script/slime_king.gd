class_name SlimeKing extends CharacterBody2D

signal boss_health_updated(current_hp: int, phase: int)
signal boss_defeated

const BASE_SPEED: float = 55.0
const ENRAGED_SPEED: float = 95.0
const BOSS_SCALE: Vector2 = Vector2(3.6, 3.6)

var max_health: int = 1500
var current_health: int = max_health
var is_dead: bool = false
var current_phase: int = 1
var player: Node2D = null

var slam_timer: float = 0.0
const SLAM_INTERVAL: float = 3.8
var is_slamming: bool = false
var has_summoned_minions: bool = false
var current_dir: String = "s"

var slime_orb_scene = preload("res://scene/slime_orb.tscn")
var minion_slime_scene = preload("res://scene/slime.tscn")
var knockback: Vector2 = Vector2.ZERO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var crown: Sprite2D = $Crown
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var dead_sound: AudioStreamPlayer2D = $DeadSound


func _ready():
	scale = BOSS_SCALE
	add_to_group("boss")


func enemy():
	pass


func apply_knockback(force: Vector2):
	# Slime King is huge and heavy: resists 65% of knockback
	knockback = force * 0.35


func update_direction(move_vec: Vector2) -> void:
	if move_vec.length_squared() < 0.1:
		return
	var deg := rad_to_deg(move_vec.angle())
	if deg >= -45.0 and deg < 45.0:
		current_dir = "e"
	elif deg >= 45.0 and deg < 135.0:
		current_dir = "s"
	elif deg >= -135.0 and deg < -45.0:
		current_dir = "n"
	else:
		current_dir = "w"


func _physics_process(delta: float):
	if is_dead:
		return
		
	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, delta * 450.0)
		move_and_slide()
		return
		
	if slam_timer > 0.0:
		slam_timer -= delta
		
	if player != null and is_instance_valid(player) and player.get("is_alive") and !is_slamming:
		var dir = (player.global_position - global_position).normalized()
		var speed = ENRAGED_SPEED if current_phase >= 2 else BASE_SPEED
		velocity = dir * speed
		update_direction(velocity)
		sprite.flip_h = false
		sprite.play("run_" + current_dir)
		move_and_slide()
		
		# Boss Special Attack Timers
		if slam_timer <= 0.0:
			perform_ground_slam()
	elif !is_slamming:
		velocity = Vector2.ZERO
		sprite.flip_h = false
		sprite.play("idle_" + current_dir)


func perform_ground_slam():
	is_slamming = true
	slam_timer = SLAM_INTERVAL if current_phase == 1 else (SLAM_INTERVAL * 0.7)
	
	# Jump stretch animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(BOSS_SCALE.x * 0.7, BOSS_SCALE.y * 1.3), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(BOSS_SCALE.x * 1.25, BOSS_SCALE.y * 0.65), 0.25).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	await tween.finished
	
	if is_dead:
		return
		
	# Ground slam impact!
	if player != null and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist < 120.0 and player.has_method("hurtByEnemy"):
			player.hurtByEnemy(self, 25)
			
	# Radial Slime Orbs shockwave
	var orb_count = 8 if current_phase >= 3 else (6 if current_phase == 2 else 4)
	for i in range(orb_count):
		var angle = (float(i) / float(orb_count)) * TAU
		var orb_dir = Vector2(cos(angle), sin(angle))
		var orb = slime_orb_scene.instantiate()
		orb.global_position = global_position + orb_dir * 35.0
		orb.direction = orb_dir
		if current_phase == 2:
			orb.orb_color = Color(1.0, 0.3, 0.2)
		elif current_phase == 3:
			orb.orb_color = Color(0.85, 0.25, 1.0)
		get_parent().add_child(orb)
		
	# Return to standard scale
	var recover_tween = create_tween()
	recover_tween.tween_property(self, "scale", BOSS_SCALE, 0.2)
	await recover_tween.finished
	is_slamming = false


func take_damage(damage: int):
	if is_dead:
		return
		
	if hit_sound != null:
		hit_sound.play()
		
	var is_crit = randf() < 0.20
	if is_crit:
		damage = int(round(damage * 1.5))
		
	current_health -= damage
	Helpers.spawn_damage_number(global_position + Vector2(0, -35), damage, Color(1.0, 0.9, 0.2), is_crit, "-")
	
	_check_phases()
	boss_health_updated.emit(current_health, current_phase)
	
	# Hurt Flash
	var orig_mod = modulate
	modulate = Color(2.5, 0.4, 0.4)
	await get_tree().create_timer(0.1).timeout
	modulate = orig_mod
	
	if current_health <= 0:
		death()


func _check_phases():
	# Phase 2 Transition (Under 1000 HP)
	if current_health <= 1000 and current_phase == 1:
		current_phase = 2
		modulate = Color(1.35, 0.35, 0.35)
		Helpers.spawn_damage_number(global_position + Vector2(0, -55), "🔥 CRIMSON RAGE! 🔥", Color(1.0, 0.3, 0.2), true)
		
	# Phase 3 Transition (Under 450 HP)
	if current_health <= 450 and current_phase == 2:
		current_phase = 3
		modulate = Color(1.1, 0.3, 1.25)
		Helpers.spawn_damage_number(global_position + Vector2(0, -55), "⚡ COSMIC NOVA! ⚡", Color(0.85, 0.35, 1.0), true)
		
		# Summon 2 minion slimes (Mutant bone slimes!)
		if !has_summoned_minions:
			has_summoned_minions = true
			for offset in [Vector2(-60, 0), Vector2(60, 0)]:
				var minion = minion_slime_scene.instantiate()
				minion.slime_type = 2
				minion.global_position = global_position + offset
				get_parent().add_child(minion)


func death():
	is_dead = true
	if dead_sound != null:
		dead_sound.play()
		
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = true
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.disabled = true
	if has_node("detection_area/CollisionShape2D"):
		$detection_area/CollisionShape2D.disabled = true
		
	boss_defeated.emit()
	PlayerStats.shooting_level(50)
	
	sprite.play("death_" + current_dir)
	
	# Massive slow-motion death wobble
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(BOSS_SCALE.x * 1.3, BOSS_SCALE.y * 0.15), 0.8).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	
	# Lavish drops
	drop_rewards()
	queue_free()


func drop_rewards():
	var health_pot = preload("res://scene/health_potion_collectable.tscn")
	var slime_drop = preload("res://scene/slime_collectable.tscn")
	
	for i in range(4):
		var p1 = health_pot.instantiate()
		p1.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_parent().add_child(p1)
		
	for i in range(6):
		var s = slime_drop.instantiate()
		s.global_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
		get_parent().add_child(s)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func _on_hitbox_area_entered(area: Area2D) -> void:
	var damage: int = 0
	if area.has_method("arrow_deal_damage"):
		damage = int(round(100.0 * float(PlayerStats.shooting) / float(PlayerStats.max_shooting_level)))
		take_damage(damage)
	elif area.has_method("sword_deal_damage"):
		damage = area.damage
		take_damage(damage)
