class_name Player extends CharacterBody2D

# ==============================================================================
# PHASE 1: Basic Player Movement & Animation
# Created for: AI Game Dev Evolution Demo
# Goal: Showcase initial character controller (clean 8-direction movement & animation)
# ==============================================================================

const SPEED = 100.0

var player_state: String = "idle"


func _physics_process(_delta):
	handle_input()
	move_and_slide()


func handle_input():
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction == Vector2.ZERO:
		player_state = "idle"
	else:
		player_state = "walking"
		
	velocity = direction * SPEED
	play_anim(direction)


func play_anim(dir: Vector2):
	if player_state == "idle":
		$AnimatedSprite2D.play("idle")
		return
	
	# 8-Directional walking animations
	if dir.x > 0.3 and dir.y < -0.3:
		$AnimatedSprite2D.play("ne-walk")
	elif dir.x > 0.3 and dir.y > 0.3:
		$AnimatedSprite2D.play("se-walk")
	elif dir.x < -0.3 and dir.y > 0.3:
		$AnimatedSprite2D.play("sw-walk")
	elif dir.x < -0.3 and dir.y < -0.3:
		$AnimatedSprite2D.play("nw-walk")
	elif dir.y < 0:
		$AnimatedSprite2D.play("n-walk")
	elif dir.y > 0:
		$AnimatedSprite2D.play("s-walk")
	elif dir.x < 0:
		$AnimatedSprite2D.play("w-walk")
	elif dir.x > 0:
		$AnimatedSprite2D.play("e-walk")
