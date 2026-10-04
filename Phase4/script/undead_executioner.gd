class_name UndeadExecutioner extends CharacterBody2D

signal boss_health_updated(current_hp: int, phase: int)
signal boss_defeated

@export var max_health: int = 500
var current_health: int = 500
var current_phase: int = 1
var is_dead: bool = false
var is_acting: bool = false

var move_speed: float = 100.0
var attack_damage: int = 22

var player: Node2D = null

# Cooldowns
var attack_cooldown: float = 0.0
var skill_cooldown: float = 4.0
var summon_cooldown: float = 8.0

# Preload minion
const MinionScene: PackedScene = preload("res://scene/executioner_minion.tscn")

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $HitBox


func _ready() -> void:
	current_health = max_health
	_update_phase()
	if anim_sprite != null:
		anim_sprite.play("idle")
		
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		
	boss_health_updated.emit(current_health, current_phase)


func _update_phase() -> void:
	var hp_ratio = float(current_health) / float(max_health)
	if hp_ratio > 0.65:
		current_phase = 1
		move_speed = 105.0
		attack_damage = 22
	elif hp_ratio > 0.30:
		current_phase = 2
		move_speed = 125.0
		attack_damage = 28
	else:
		current_phase = 3
		move_speed = 145.0
		attack_damage = 34


func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if attack_cooldown > 0.0:
		attack_cooldown -= delta
	if skill_cooldown > 0.0:
		skill_cooldown -= delta
	if summon_cooldown > 0.0:
		summon_cooldown -= delta
		
	if is_acting:
		velocity = velocity.move_toward(Vector2.ZERO, delta * 300.0)
		move_and_slide()
		return
		
	if player == null or !is_instance_valid(player) or !player.is_alive:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else:
			if anim_sprite != null and anim_sprite.animation != "idle":
				anim_sprite.play("idle")
			return
			
	var dist_sq = global_position.distance_squared_to(player.global_position)
	var dir = (player.global_position - global_position).normalized()
	
	if anim_sprite != null:
		anim_sprite.flip_h = dir.x < 0
		
	# Phase 3 or Phase 2 Summon
	if current_phase >= 2 and summon_cooldown <= 0.0:
		_perform_summon()
		return
		
	# Phase 2 & 3 Dark Scythe Thrust Skill
	if current_phase >= 2 and skill_cooldown <= 0.0 and dist_sq < 144400.0: # ~380 px
		_perform_skill()
		return
		
	# Basic Attack when in scythe range
	if dist_sq < 9025.0 and attack_cooldown <= 0.0: # 95 px
		_perform_attack()
		return
		
	# Chase player
	velocity = velocity.move_toward(dir * move_speed, delta * 350.0)
	if anim_sprite != null and anim_sprite.animation != "idle":
		anim_sprite.play("idle")
	move_and_slide()


func _perform_attack() -> void:
	is_acting = true
	attack_cooldown = 1.2 if current_phase == 1 else 0.8
	velocity = Vector2.ZERO
	
	if anim_sprite != null:
		anim_sprite.play("attack")
		
	# Hướng chém của Boss (theo hướng đang nhìn mặt)
	var facing_dir_x: float = -1.0 if (anim_sprite != null and anim_sprite.flip_h) else 1.0
	
	# Lướt nhẹ về phía player khi chém (với lực vừa phải để player kịp né)
	if player != null and is_instance_valid(player):
		var rush_dir = (player.global_position - global_position).normalized()
		velocity = rush_dir * 110.0
		
	var tree := get_tree()
	if tree != null:
		await tree.create_timer(0.4).timeout
	if not is_inside_tree() or is_dead:
		return
		
	# Chỉ trúng đòn nếu:
	# 1. Khoảng cách gần (bán kính 75px thay vì 105px 360 độ trước đây)
	# 2. Player đang đứng ở PHÍA TRƯỚC mặt chém của Boss (người chơi lướt ra sau lưng sẽ né được hoàn toàn)
	if player != null and is_instance_valid(player) and player.is_alive:
		var to_player = player.global_position - global_position
		var dist = to_player.length()
		var is_in_front: bool = (to_player.x * facing_dir_x) >= -10.0
		
		if dist <= 75.0 and is_in_front and player.has_method("hurtByEnemy"):
			player.hurtByEnemy(self, attack_damage)
			Helpers.spawn_damage_number(player.global_position, "⚡ TRẢM TỬ THẦN ⚡", Color(0.9, 0.2, 0.2), true)
			
	if tree != null:
		await anim_sprite.animation_finished
	if not is_inside_tree() or is_dead:
		return
		
	is_acting = false
	anim_sprite.play("idle")


func _perform_skill() -> void:
	is_acting = true
	skill_cooldown = 5.5 if current_phase == 2 else 4.0
	velocity = Vector2.ZERO
	
	if anim_sprite != null:
		anim_sprite.play("skill")
		
	# Đánh dấu vị trí Player tại thời điểm bắt đầu niệm (Telegraph)
	var target_pos: Vector2 = player.global_position if (player != null and is_instance_valid(player)) else global_position
	Helpers.spawn_damage_number(target_pos, "⚠️ [VÙNG GAI BÓNG TỐI]", Color(0.85, 0.3, 0.95), false)
		
	var tree := get_tree()
	if tree != null:
		await tree.create_timer(0.6).timeout
	if not is_inside_tree() or is_dead:
		return
		
	# Gai trồi lên tại vị trí target_pos:
	# Chỉ gây sát thương nếu Player vẫn còn đứng trong vùng gai (bán kính 60px quanh target_pos)
	if player != null and is_instance_valid(player) and player.is_alive:
		var dist_to_strike = player.global_position.distance_to(target_pos)
		if dist_to_strike <= 60.0:
			Helpers.spawn_damage_number(player.global_position, "☠ GAI BÓNG TỐI ☠", Color(0.7, 0.2, 0.9), true)
			if player.has_method("hurtByEnemy"):
				player.hurtByEnemy(self, attack_damage + 8)
		else:
			# Player đã di chuyển/né ra ngoài vị trí gai trồi!
			Helpers.spawn_damage_number(target_pos, "💨 HỤT!", Color(0.4, 0.9, 0.5), false)
			
	if tree != null:
		await anim_sprite.animation_finished
	if not is_inside_tree() or is_dead:
		return
		
	is_acting = false
	anim_sprite.play("idle")


func _perform_summon() -> void:
	is_acting = true
	summon_cooldown = 11.0 if current_phase == 2 else 8.0
	velocity = Vector2.ZERO
	
	if anim_sprite != null:
		anim_sprite.play("summon")
		
	var tree := get_tree()
	if tree != null:
		await tree.create_timer(0.4).timeout
	if not is_inside_tree() or is_dead:
		return
		
	# Triệu hồi 2-3 Minion Phantoms
	var spawn_count = 2 if current_phase == 2 else 3
	for i in range(spawn_count):
		var offset = Vector2(randf_range(-80, 80), randf_range(-60, 60))
		var minion = MinionScene.instantiate()
		minion.global_position = global_position + offset
		get_parent().add_child(minion)
		
	Helpers.spawn_damage_number(global_position, "✦ TRIỆU HỒI LINH HỒN ✦", Color(0.8, 0.4, 1.0), true)
	
	if tree != null:
		await anim_sprite.animation_finished
	if not is_inside_tree() or is_dead:
		return
		
	is_acting = false
	anim_sprite.play("idle")


func take_damage(damage: int, is_crit: bool = false) -> void:
	if is_dead:
		return
		
	current_health = max(0, current_health - damage)
	_update_phase()
	
	var num_color = Color(1.0, 0.6, 0.1) if is_crit else Color(0.9, 0.85, 0.2)
	Helpers.spawn_damage_number(global_position, damage, num_color, is_crit, "-")
	
	boss_health_updated.emit(current_health, current_phase)
	
	if current_health <= 0:
		death()
		return
		
	# Hurt spectral flash
	modulate = Color(2.2, 0.6, 0.6, 1.0)
	var tree := get_tree()
	if tree != null:
		await tree.create_timer(0.1).timeout
	if is_inside_tree() and not is_dead:
		modulate = Color(1.0, 1.0, 1.0, 1.0)


func death() -> void:
	if is_dead:
		return
	is_dead = true
	is_acting = true
	velocity = Vector2.ZERO
	
	if hitbox != null:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		
	PlayerStats.shooting_level(30) # Phần thưởng lớn khi hạ boss
	boss_defeated.emit()
	
	if anim_sprite != null:
		anim_sprite.play("death")
		var tree := get_tree()
		if tree != null:
			await anim_sprite.animation_finished
	if not is_inside_tree():
		return
		
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_dead:
		return
	if area.has_method("arrow_deal_damage"):
		if "is_consumed" in area and area.is_consumed:
			return
		if "is_consumed" in area:
			area.is_consumed = true
		var damage = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		var is_crit = area.is_crit if "is_crit" in area else false
		take_damage(damage, is_crit)
		var tier = area.arrow_tier_idx if "arrow_tier_idx" in area else 1
		Helpers.spawn_arrow_impact(area.global_position, tier)
		area.queue_free()
	elif area.has_method("sword_deal_damage"):
		if "hit_enemies" in area:
			if self in area.hit_enemies:
				return
			area.hit_enemies.append(self)
		var damage = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		var is_crit = area.is_crit if "is_crit" in area else false
		take_damage(damage, is_crit)


func enemy() -> void:
	pass
