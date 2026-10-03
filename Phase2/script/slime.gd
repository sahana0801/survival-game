class_name Slime extends CharacterBody2D

# ==============================================================================
# BUG 1: "SLIME XUYÊN TƯỜNG" (Ghost Slimes / No Collision Physics)
# AI Story: AI quên gọi move_and_slide(), cập nhật trực tiếp `position += ...`
# Result: Slime lướt xuyên qua mọi chướng ngại vật (vách đá, cây cối, mặt nước)
#         như bóng ma để đuổi theo người chơi! 👻
# ==============================================================================

const SPEED: float = 70.0

enum { IDLE, WANDER, ATTACKING }
var state = IDLE

var max_health: int = 50
var current_health: int = max_health
var is_dead: bool = false
var player: CharacterBody2D = null

var wander_target: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0

@onready var healthBar = $healthBar
@onready var anim = $AnimatedSprite2D


func _ready():
	healthBar.value = current_health
	wander_target = global_position


func _physics_process(delta):
	if is_dead:
		return
		
	if player != null:
		state = ATTACKING
		# 🐛 BUG 1: Cập nhật trực tiếp `position` thay vì dùng move_and_slide()
		# Khiến slime bay xuyên tường, xuyên đá, xuyên cây như ma!
		var dir = (player.global_position - global_position).normalized()
		position += dir * SPEED * delta
		
		anim.flip_h = dir.x < 0
		anim.play("move")
	else:
		# Simple autonomous wander
		wander_timer -= delta
		if wander_timer <= 0:
			wander_timer = randf_range(1.5, 3.5)
			if randf() > 0.4:
				state = WANDER
				wander_target = global_position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
			else:
				state = IDLE
				
		if state == WANDER:
			var dir = (wander_target - global_position).normalized()
			position += dir * (SPEED * 0.5) * delta
			anim.flip_h = dir.x < 0
			anim.play("move")
			if global_position.distance_to(wander_target) < 10:
				state = IDLE
		else:
			anim.play("idle")


func _on_detection_area_body_entered(body):
	if body is Player or body.has_method("player"):
		player = body


func _on_detection_area_body_exited(body):
	if body == player:
		player = null


func _on_hitbox_area_entered(area):
	# Arrow hit detection
	if area.name.to_lower().contains("arrow") or area.has_method("arrow_deal_damage"):
		take_damage(25)


func take_damage(damage: int):
	current_health -= damage
	healthBar.value = current_health
	if current_health <= 0 and !is_dead:
		death()


func death():
	is_dead = true
	anim.play("death")
	healthBar.visible = false
	await get_tree().create_timer(0.6).timeout
	queue_free()


func enemy():
	pass
