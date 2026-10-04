class_name SwampFrog extends CharacterBody2D

const SPEED: float = 70.0
const JUMP_SPEED: float = 140.0

enum State { IDLE, WANDER, CHASE, ATTACK }
var current_state = State.IDLE

var max_health: int = 130
var current_health: int = max_health
var is_dead: bool = false
var player: Node2D = null

var spit_cooldown: float = 0.0
const SPIT_INTERVAL: float = 2.5

var poison_spit_scene = preload("res://scene/poison_spit.tscn")
var knockback: Vector2 = Vector2.ZERO

@onready var wander_controller = $WanderController
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: TextureProgressBar = $healthBar


func _ready():
	randomize()
	if health_bar != null:
		health_bar.max_value = max_health
		health_bar.value = current_health
	# Toxic greenish tint
	modulate = Color(0.85, 1.15, 0.85)


func enemy():
	pass


func apply_knockback(force: Vector2):
	knockback = force


func _physics_process(delta: float):
	if is_dead:
		return
		
	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, delta * 520.0)
		move_and_slide()
		return
		
	if spit_cooldown > 0.0:
		spit_cooldown -= delta

	if player != null and is_instance_valid(player) and player.get("is_alive"):
		current_state = State.CHASE
		var dir = (player.global_position - global_position).normalized()
		velocity = dir * JUMP_SPEED
		sprite.flip_h = dir.x < 0
		sprite.play("jump")
		move_and_slide()
		
		# Spit poison glob when in medium range
		var dist_sq = global_position.distance_squared_to(player.global_position)
		if dist_sq < 48400.0 and spit_cooldown <= 0.0: # 220 px
			spit_poison(dir)
	else:
		match current_state:
			State.IDLE:
				velocity = Vector2.ZERO
				sprite.play("idle")
			State.WANDER:
				if wander_controller != null:
					var direction = global_position.direction_to(wander_controller.target_position)
					velocity = velocity.move_toward(direction * SPEED, delta)
					sprite.flip_h = velocity.x < 0
					sprite.play("jump")
					move_and_slide()
				else:
					current_state = State.IDLE


func spit_poison(dir: Vector2):
	spit_cooldown = SPIT_INTERVAL
	var spit = poison_spit_scene.instantiate()
	spit.global_position = global_position + dir * 10.0
	spit.direction = dir
	get_parent().add_child(spit)


func take_damage(damage: int, is_crit: bool = false):
	if is_dead:
		return
		
	current_health -= damage
	if health_bar != null:
		health_bar.value = current_health
		
	var num_color = Color(1.0, 0.6, 0.1) if is_crit else Color(1.0, 0.88, 0.2)
	Helpers.spawn_damage_number(global_position, damage, num_color, is_crit, "-")
	
	# Hurt flash
	modulate = Color(1.8, 0.4, 0.4)
	var tree = get_tree()
	if tree != null:
		await tree.create_timer(0.12).timeout
	if not is_inside_tree():
		return
	modulate = Color(0.85, 1.15, 0.85)
	
	if current_health <= 0:
		death()


func death():
	is_dead = true
	if health_bar != null:
		health_bar.visible = false
	if has_node("HitBox/CollisionShape2D"):
		$HitBox/CollisionShape2D.disabled = true
	if has_node("DetectionArea/CollisionShape2D"):
		$DetectionArea/CollisionShape2D.disabled = true
	if has_node("hitbox/CollisionShape2D"):
		$hitbox/CollisionShape2D.disabled = true
		
	PlayerStats.shooting_level(8)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await tween.finished
	if not is_inside_tree():
		return
	queue_free()


func _on_detection_area_body_entered(body: Node2D):
	if body.has_method("player"):
		player = body


func _on_detection_area_body_exited(body: Node2D):
	if body == player:
		player = null
		current_state = State.IDLE


func _on_hit_box_area_entered(area: Area2D):
	if area.has_method("arrow_deal_damage") or area.has_method("sword_deal_damage"):
		var damage = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		var is_crit = area.is_crit if "is_crit" in area else false
		take_damage(damage, is_crit)


func _on_timer_timeout():
	if player == null and !is_dead:
		current_state = Helpers.choose([State.IDLE, State.WANDER])
		if wander_controller != null:
			wander_controller.start_wander_timer(Helpers.choose([1.0, 1.5, 2.5]))
		$Timer.wait_time = Helpers.choose([1.5, 2.0, 3.0])
		$Timer.start()
