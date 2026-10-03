class_name Skeleton extends CharacterBody2D

var health: int = 300
var current_health: int = health
@onready var healthBar: TextureProgressBar = $healthBar
@onready var wander_controller = $WanderController
const SPEED: float = 50.0

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


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, delta * 450.0)
		move_and_slide()
		return
		
	if player != null and is_instance_valid(player) and player.is_alive:
		current_state = ATTACK
		is_attacking = true
		var direction: Vector2 = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		$AnimatedSprite2D.flip_h = velocity.x < 0
		var dist: float = global_position.distance_to(player.global_position)
		if dist < 25.0:
			$AnimatedSprite2D.play("attack")
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
					velocity = velocity.move_toward(direction * SPEED, delta * 150.0)
					$AnimatedSprite2D.flip_h = velocity.x < 0
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
		current_state = REACT
		$AnimatedSprite2D.play("react")
		$skeletonLaughs.play()
		await get_tree().create_timer(1.0).timeout
		if !is_dead and player != null:
			current_state = WALK


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		is_attacking = false
		current_state = IDLE


func take_damage(damage: int) -> void:
	if is_dead:
		return
	$skeletonHit.play()
	$AnimatedSprite2D.play("hit")
	PlayerStats.shooting_level()
	
	# 20% critical strike chance
	var is_crit: bool = randf() < 0.20
	if is_crit:
		damage = int(round(damage * 1.5))
		
	current_health -= damage
	healthBar.value = current_health
	
	# Floating Damage Number
	Helpers.spawn_damage_number(global_position, damage, Color(1.0, 0.88, 0.2), is_crit, "-")
	
	if current_health <= 0 and !is_dead:
		death()


func death() -> void:
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
	var damage: int = 0
	if area.has_method("arrow_deal_damage"):
		damage = int(round(100.0 * float(PlayerStats.shooting) / float(PlayerStats.max_shooting_level)))
		take_damage(damage)
	elif area.has_method("sword_deal_damage"):
		damage = area.damage
		take_damage(damage)


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
