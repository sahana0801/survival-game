extends CharacterBody2D

var health = 300
var current_health = health
@onready var healthBar = $healthBar
@onready var wander_controller = $WanderController
const SPEED = 50.0

var dir = Vector2.RIGHT
var start_position: Vector2
enum { IDLE, REACT, WALK, DIE, ATTACK, HIT, NEW_DIR }
var current_state = IDLE

var is_roaming = true
var is_attacking = false
var is_dead = false

var player = null

func _ready():
	randomize()
	start_position = position
	healthBar.value = current_health
	get_state()


func get_state():
	var r = randi_range(0, 2)
	match r:
		0:
			current_state = IDLE
		1:
			current_state = REACT
		2:
			current_state = WALK
		#3:
		#	current_state = NEW_DIR


var knockback: Vector2 = Vector2.ZERO


func apply_knockback(force: Vector2):
	knockback = force


func _process(delta):
	if knockback.length() > 5.0:
		position += knockback * delta
		knockback = knockback.move_toward(Vector2.ZERO, delta * 450.0)
		
	if player != null and player.is_alive:
		var oldpos = position
		position += (player.position - position) / SPEED
		current_state = ATTACK
		is_attacking = true
		var dist = player.position - position
		if dist.x < 10:
			$AnimatedSprite2D.play("attack")
		if position.x < oldpos.x:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	if !is_attacking and !is_dead:
		match current_state:
			IDLE:
				$AnimatedSprite2D.play("idle")
			WALK:
				#if dir.x == -1: # left
				#	$AnimatedSprite2D.flip_h = true
				#else:
				#	$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("walk")
				if player == null:
					var direction = global_position.direction_to(wander_controller.target_position)
					velocity = velocity.move_toward(direction * SPEED, delta)
					$AnimatedSprite2D.flip_h = velocity.x < 0
					#var dist = position - start_position
					#if dist.x > 100:
					#	position += (start_position - position) / SPEED
					#else:
					#	position += dir * SPEED * delta
					move_and_slide()
			REACT:
				$AnimatedSprite2D.play("react")
			DIE:
				$AnimatedSprite2D.play("dead")
			HIT:
				$AnimatedSprite2D.play("hit")
			NEW_DIR:	#not used any longer
				dir = Helpers.choose([Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT])
				$AnimatedSprite2D.play("walk")
				current_state = WALK


func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player = body
		current_state = REACT
		$AnimatedSprite2D.play("react")
		$skeletonLaughs.play()
		await get_tree().create_timer(1).timeout
		current_state = WALK


func _on_detection_area_body_exited(body):
	if body.has_method("player"):
		player = null
		is_attacking = false
		current_state = IDLE


func take_damage(damage: int):
	$skeletonHit.play()
	$AnimatedSprite2D.play("hit")
	PlayerStats.shooting_level()
	
	# 20% critical strike chance
	var is_crit = randf() < 0.20
	if is_crit:
		damage = int(round(damage * 1.5))
		
	current_health -= damage
	healthBar.value = current_health
	
	# 💥 Floating Damage Number
	Helpers.spawn_damage_number(global_position, damage, Color(1.0, 0.88, 0.2), is_crit, "-")
	
	if current_health <= 0 and !is_dead:
		death()


func death():
	PlayerStats.shooting_level(10) #Bonus for kill
	is_dead = true
	$skeletonDies.play()
	$AnimatedSprite2D.play("dead")
	
	healthBar.visible = false
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.disabled = true
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.disabled = true
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = true
	$DeathTimer.start()
	

func _on_hit_box_area_entered(area):
	var damage
	if area.has_method("arrow_deal_damage"):
		damage = 100 * PlayerStats.shooting / PlayerStats.max_shooting_level
		take_damage(damage)
	elif area.has_method("sword_deal_damage"):
		damage = area.damage
		take_damage(damage)


func _on_timer_timeout():
	$Timer.wait_time = Helpers.choose([0.5, 1.0, 1.5])
	wander_controller.start_wander_timer($Timer.wait_time)
	if !is_dead:
		get_state()
		$Timer.start()


func _on_death_timer_timeout():
	queue_free()
