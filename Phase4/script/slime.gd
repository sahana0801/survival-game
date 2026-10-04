class_name Slime extends CharacterBody2D

const SPEED: float = 80.0

enum { IDLE, WANDER, ATTACKING }
var state = IDLE

@export_range(1, 3) var slime_type: int = 1

var max_health: int = 100
var current_health: int = max_health

var is_dead: bool = false
var player: CharacterBody2D = null
var player_in_collect_range: bool = false
var current_dir: String = "s"

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var slime = $slime_collectable
@onready var healthBar: TextureProgressBar = $healthBar
@onready var hit_sound: AudioStreamPlayer2D = $HitSound
@onready var dead_sound: AudioStreamPlayer2D = $DeadSound
@onready var inv_pick: AudioStreamPlayer2D = $InventoryPick
@onready var wander_controller = $WanderController
@onready var wander_range: int = wander_controller.wander_range

var knockback: Vector2 = Vector2.ZERO


func _ready() -> void:
	if slime_type == 2:
		var f2 = load("res://art/character/Slime/slime2_frames.tres")
		if f2 != null:
			anim_sprite.sprite_frames = f2
	elif slime_type == 3:
		var f3 = load("res://art/character/Slime/slime3_frames.tres")
		if f3 != null:
			anim_sprite.sprite_frames = f3
			
	healthBar.value = current_health
	$slime_collectable/collect_area.visible = false
	random_state()


func random_state() -> void:
	if wander_controller.get_time_left() == 0:
		state = Helpers.choose([IDLE, WANDER])
		wander_controller.start_wander_timer(Helpers.choose([1, 1.5, 2]))


func _process(_delta: float) -> void:
	playercollect()


func apply_knockback(force: Vector2) -> void:
	knockback = force


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


func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	if knockback.length() > 5.0:
		velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, delta * 450.0)
		move_and_slide()
		return

	if player != null and is_instance_valid(player):
		state = ATTACKING
		var direction: Vector2 = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		update_direction(velocity)
		anim_sprite.flip_h = false
		anim_sprite.play("run_" + current_dir)
		move_and_slide()
	else:
		random_state()
		match state:
			IDLE:
				velocity = Vector2.ZERO
				anim_sprite.flip_h = false
				anim_sprite.play("idle_" + current_dir)
			WANDER:
				var direction: Vector2 = global_position.direction_to(wander_controller.target_position)
				velocity = velocity.move_toward(direction * SPEED, delta * 200.0)
				update_direction(velocity)
				anim_sprite.flip_h = false
				anim_sprite.play("walk_" + current_dir)
				move_and_slide()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("arrow_deal_damage") or area.has_method("sword_deal_damage"):
		var damage = area.damage if "damage" in area else PlayerStats.get_weapon_damage()
		var is_crit = area.is_crit if "is_crit" in area else false
		take_damage(damage, is_crit)


func take_damage(damage: int, is_crit: bool = false) -> void:
	if is_dead:
		return
	hit_sound.play()
	PlayerStats.shooting_level()
		
	current_health -= damage
	healthBar.value = current_health
	
	# Floating Damage Number (Vàng cam nổi bật khi Crit)
	var num_color = Color(1.0, 0.6, 0.1) if is_crit else Color(1.0, 0.88, 0.2)
	Helpers.spawn_damage_number(global_position, damage, num_color, is_crit, "-")
	
	# Hit flash
	var tween := create_tween()
	tween.tween_property(anim_sprite, "modulate", Color(2.5, 0.4, 0.4, 1.0), 0.08)
	tween.tween_property(anim_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
	
	if current_health <= 0:
		death()


func death() -> void:
	dead_sound.play()
	PlayerStats.shooting_level(5) # Bonus for kill
	is_dead = true
	velocity = Vector2.ZERO
	anim_sprite.flip_h = false
	anim_sprite.play("death_" + current_dir)
	healthBar.visible = false
	$hitbox/CollisionShape2D.set_deferred("disabled", true)
	$detection_area/CollisionShape2D.set_deferred("disabled", true)
	var tree = get_tree()
	if tree != null:
		await tree.create_timer(1.0).timeout
	if not is_inside_tree():
		return
	
	anim_sprite.visible = false
	drop_slime()


func drop_slime() -> void:
	if not is_inside_tree():
		return
	slime.visible = true
	$slime_collectable/collect_area.visible = true


func playercollect() -> void:
	if Input.is_action_just_pressed("harvest") and player_in_collect_range and $slime_collectable/collect_area.visible:
		PlayerStats.SlimeCollected.emit()
		var tree = get_tree()
		if tree != null:
			await tree.create_timer(0.3).timeout
		if not is_inside_tree():
			return
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player_in_collect_range = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player_in_collect_range = false


func enemy() -> void:
	pass
