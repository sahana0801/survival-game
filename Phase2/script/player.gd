class_name Player extends CharacterBody2D

# ==============================================================================
# PHASE 2: Player Controller with Combat & Bugs
# Features: 8-Direction Movement + Bow Equipping + Arrow Shooting
# BUGS:
# - Bug 2: Arrow bay ngược (nhờ arrow.gd)
# - Bug 3: Player Bất Tử (Slimes đánh tơi bời nhưng HP không bao giờ giảm!)
# ==============================================================================

signal healthChanged

const SPEED = 100.0

var player_state: String = "idle"
var is_alive: bool = true
var is_hurt: bool = false

var bow_equiped: bool = false
var bow_cooldown: bool = true
var arrow_scene = preload("res://scene/arrow.tscn")

var max_health: int = 100
var current_health: int = max_health

@onready var hurtBox = $hurtBox
@onready var marker2d = $Marker2D
@onready var anim = $AnimatedSprite2D


func _physics_process(_delta):
	if is_alive:
		handle_input()
		move_and_slide()
		
		# Slime collision damage check
		if !is_hurt and hurtBox != null:
			for area in hurtBox.get_overlapping_areas():
				if area.name == "hitbox" or area.get_parent().has_method("enemy"):
					hurtByEnemy(area)


func handle_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction == Vector2.ZERO:
		player_state = "idle"
	else:
		player_state = "walking"
		
	velocity = direction * SPEED
	
	# Bow Aiming Marker points towards mouse cursor
	var mouse_pos = get_global_mouse_position()
	marker2d.look_at(mouse_pos)
	
	# Toggle bow with key '1'
	if Input.is_action_just_pressed("bow"):
		bow_equiped = !bow_equiped
		
	# Shoot arrow on Left Click
	if Input.is_action_just_pressed("left_mouse") and bow_equiped and bow_cooldown:
		shoot_arrow()
		
	play_anim(direction)


func shoot_arrow():
	bow_cooldown = false
	var arrow = arrow_scene.instantiate()
	arrow.rotation = marker2d.rotation
	arrow.global_position = marker2d.global_position
	get_parent().add_child(arrow)
	
	# Recoil animation / cooldown
	await get_tree().create_timer(0.3).timeout
	bow_cooldown = true


func play_anim(dir: Vector2):
	var mouse_rel = get_global_mouse_position() - global_position
	
	if !bow_equiped:
		if player_state == "idle":
			anim.play("idle")
			return
		
		# 8-Directional walking
		if dir.x > 0.3 and dir.y < -0.3:
			anim.play("ne-walk")
		elif dir.x > 0.3 and dir.y > 0.3:
			anim.play("se-walk")
		elif dir.x < -0.3 and dir.y > 0.3:
			anim.play("sw-walk")
		elif dir.x < -0.3 and dir.y < -0.3:
			anim.play("nw-walk")
		elif dir.y < 0:
			anim.play("n-walk")
		elif dir.y > 0:
			anim.play("s-walk")
		elif dir.x < 0:
			anim.play("w-walk")
		elif dir.x > 0:
			anim.play("e-walk")
	else:
		# Bow equipped: Play attack/aiming animation facing the mouse cursor!
		if mouse_rel.x >= -25 and mouse_rel.x <= 25 and mouse_rel.y < 0:
			anim.play("n-attack")
		elif mouse_rel.y >= -25 and mouse_rel.y <= 25 and mouse_rel.x > 0:
			anim.play("e-attack")
		elif mouse_rel.x >= -25 and mouse_rel.x <= 25 and mouse_rel.y > 0:
			anim.play("s-attack")
		elif mouse_rel.y >= -25 and mouse_rel.y <= 25 and mouse_rel.x < 0:
			anim.play("w-attack")
		elif mouse_rel.x >= 25 and mouse_rel.y <= -25:
			anim.play("ne-attack")
		elif mouse_rel.x >= 25 and mouse_rel.y >= 25:
			anim.play("se-attack")
		elif mouse_rel.x <= -25 and mouse_rel.y >= 25:
			anim.play("sw-attack")
		elif mouse_rel.x <= -25 and mouse_rel.y <= -25:
			anim.play("nw-attack")


# ==============================================================================
# 🐛 BUG 3: "PLAYER BẤT TỬ" (God Mode Glitch)
# AI Story: AI viết hàm nhận sát thương rất hoành tráng (chớp đỏ, hiệu ứng),
#           nhưng LÃNG QUÊN dòng code: `current_health -= damage`!
# Result: Slimes cắn tới tấp, người chơi nhấp nháy đỏ nhưng HP luôn ở mức 100%!
# ==============================================================================
func hurtByEnemy(_area):
	if is_hurt:
		return
	is_hurt = true
	
	# 🐛 BUG: AI quên dòng này!
	# current_health -= 15
	
	healthChanged.emit()
	
	# Flash red visual feedback
	anim.modulate = Color(1.0, 0.2, 0.2)
	await get_tree().create_timer(0.2).timeout
	anim.modulate = Color(1.0, 1.0, 1.0)
	await get_tree().create_timer(0.3).timeout
	is_hurt = false


func player():
	pass
