extends CharacterBody2D

enum { IDLE, SLEEP, WANDER }	#JUMP_L, JUMP_R, JUMP_UP, JUMP_DOWN
var state = IDLE
#var jumps_l = 0
#var jumps_r = 0
#var jump_cnt_x = 0
#var jump_cnt_y = 0

@export var move_speed : float = 50.0
#@export var move_dir : Vector2

#var start_pos : Vector2
#var target_pos : Vector2

const SPEED = 30

@onready var wander_controller = $WanderController

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#start_pos = global_position
	#target_pos = start_pos + move_dir


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	play_anim(delta)


func timer_random():
	$Timer.wait_time = Helpers.choose([1, 1.5, 2, 3])
	$Timer.start()
	wander_controller.start_wander_timer($Timer.wait_time)


func _on_timer_timeout():
	state = Helpers.choose([IDLE, SLEEP, WANDER])	#JUMP_L, JUMP_R, JUMP_UP, JUMP_DOWN
	
	
	
	#if state == JUMP_L:
	#	jump_cnt_x -= 1
	#	if jump_cnt_x < -3:
	#		state = JUMP_R
	#elif state == JUMP_R:
	#	jump_cnt_x += 1
	#	if jump_cnt_x > 3:
	#		state = JUMP_L
	#		jump_cnt_x -= 1
	#elif state == JUMP_UP:
	#	jump_cnt_y -= 1
	#	if jump_cnt_y < -3:
	#		state = JUMP_DOWN
	#elif state == JUMP_DOWN:
	#	jump_cnt_y += 1
	#	if jump_cnt_y > 3:
	#		state = JUMP_UP
	#		jump_cnt_y -= 1
	#print("Frog x, y: %d - %d" % [jump_cnt_x, jump_cnt_y])
	timer_random()


func play_anim(delta):
	match state:
		IDLE:
			$AnimatedSprite2D.play("idle")
		SLEEP:
			$AnimatedSprite2D.play("sleep")
		WANDER:
			var direction = global_position.direction_to(wander_controller.target_position)
			velocity = velocity.move_toward(direction * move_speed, delta)
			$AnimatedSprite2D.flip_h = velocity.x > 0
			$AnimatedSprite2D.play("jump")
			
			move_and_slide()
		#JUMP_L:
		#	$AnimatedSprite2D.flip_h = false
		#	$AnimatedSprite2D.play("jump")
			#position.x -= 2 * SPEED * delta
		#JUMP_R:
		#	$AnimatedSprite2D.flip_h = true
		#	$AnimatedSprite2D.play("jump")
		#	#position.x += 2 * SPEED * delta
		#JUMP_DOWN:
		#	$AnimatedSprite2D.play("jump")
		#	#position.y += 2 * SPEED * delta
		#JUMP_UP:
		#	$AnimatedSprite2D.play("jump")
		#	#position.y -= 2 * SPEED * delta
	
	
