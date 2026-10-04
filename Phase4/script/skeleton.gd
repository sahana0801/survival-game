class_name Skeleton extends CharacterBody2D

# === CHỈNH KÍCH THƯỚC VÀ CHỈ SỐ SKELETON TẠI ĐÂY ===
@export_group("Chỉ Số & Kích Thước")
@export var skeleton_scale: float = 2.0: # Kích thước (2.0 = to bằng người chơi, 2.5 = khổng lồ)
	set(val):
		skeleton_scale = val
		if is_node_ready() and has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.scale = Vector2(val, val)

@export var move_speed: float = 100.0 # Tốc độ di chuyển (chạy theo player & đi tuần)
@export var max_health: int = 300 # Máu tối đa
@export var attack_damage: int = 15 # Sát thương mỗi đòn đâm giáo

signal skeleton_died

@onready var health: int = max_health
@onready var current_health: int = health
@onready var healthBar: TextureProgressBar = $healthBar
@onready var wander_controller = $WanderController

var dir: Vector2 = Vector2.RIGHT
var start_position: Vector2 = Vector2.ZERO
enum { IDLE, REACT, WALK, DIE, ATTACK, HIT, NEW_DIR }
var current_state = IDLE

var is_roaming: bool = true
var is_attacking: bool = false
var is_dead: bool = false

var player: CharacterBody2D = null
var knockback: Vector2 = Vector2.ZERO


func _ready() -> void:
	randomize()
	start_position = position
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.scale = Vector2(skeleton_scale, skeleton_scale)
	healthBar.max_value = max_health
	healthBar.value = current_health
	get_state()


func get_state() -> void:
	var r: int = randi_range(0, 2)
	match r:
		0:
			current_state = IDLE
		1:
			current_state = REACT
		2:
			current_state = WALK


func apply_knockback(force: Vector2) -> void:
	knockback = force


var attack_cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, delta * 450.0)
		move_and_slide()
		return
		
	if player != null and is_instance_valid(player) and player.is_alive:
		current_state = ATTACK
		is_attacking = true
		var direction: Vector2 = global_position.direction_to(player.global_position)
		velocity = direction * move_speed
		var is_facing_left: bool = velocity.x < 0
		$AnimatedSprite2D.flip_h = is_facing_left
		if has_node("hitbox"):
			$hitbox.scale.x = -1.0 if is_facing_left else 1.0
		var dist: float = global_position.distance_to(player.global_position)
		if dist < 65.0:
			$AnimatedSprite2D.play("attack")
			if attack_cooldown <= 0.0 and player.has_method("hurtByEnemy"):
				player.hurtByEnemy(self, attack_damage)
				attack_cooldown = 0.8
		else:
			$AnimatedSprite2D.play("walk")
		move_and_slide()
	else:
		is_attacking = false
		match current_state:
			IDLE:
				velocity = Vector2.ZERO
				$AnimatedSprite2D.play("idle")
			WALK:
				$AnimatedSprite2D.play("walk")
				if wander_controller != null and is_instance_valid(wander_controller):
					var direction: Vector2 = global_position.direction_to(wander_controller.target_position)
					velocity = velocity.move_toward(direction * move_speed, delta * 150.0)
					var is_facing_left: bool = velocity.x < 0
					$AnimatedSprite2D.flip_h = is_facing_left
					if has_node("hitbox"):
						$hitbox.scale.x = -1.0 if is_facing_left else 1.0
					move_and_slide()
			REACT:
				$AnimatedSprite2D.play("react")
			DIE:
				$AnimatedSprite2D.play("dead")
			HIT:
				$AnimatedSprite2D.play("hit")


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player = body
		current_state = ATTACK
		if has_node("skeletonLaughs"):
			$skeletonLaughs.play()


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		is_attacking = false
		current_state = IDLE


func take_damage(damage: int, is_crit: bool = false) -> void:
	if is_dead:
		return
	$skeletonHit.play()
	$AnimatedSprite2D.play("hit")
	PlayerStats.shooting_level()
		
	current_health -= damage
	healthBar.value = current_health
	
	# Floating Damage Number (Vàng cam nổi bật khi Crit)
	var num_color = Color(1.0, 0.6, 0.1) if is_crit else Color(1.0, 0.88, 0.2)
	Helpers.spawn_damage_number(global_position, damage, num_color, is_crit, "-")
	
	if current_health <= 0 and !is_dead:
		death()


func death() -> void:
	skeleton_died.emit()
	PlayerStats.shooting_level(10) # Bonus for kill
	is_dead = true
	velocity = Vector2.ZERO
	$skeletonDies.play()
	$AnimatedSprite2D.play("dead")
	
	healthBar.visible = false
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.set_deferred("disabled", true)
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.set_deferred("disabled", true)
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.set_deferred("disabled", true)
	$DeathTimer.start()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.has_method("arrow_deal_damage") or area.has_method("sword_deal_damage"):
		var damage = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		var is_crit = area.is_crit if "is_crit" in area else false
		take_damage(damage, is_crit)


func _on_timer_timeout() -> void:
	$Timer.wait_time = Helpers.choose([0.5, 1.0, 1.5])
	wander_controller.start_wander_timer($Timer.wait_time)
	if !is_dead:
		get_state()
		$Timer.start()


func _on_death_timer_timeout() -> void:
	queue_free()


func enemy() -> void:
	pass
