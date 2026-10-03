extends CharacterBody2D

const SPEED = 30.0

enum {
	IDLE,
	NEW_DIR,
	MOVE
}

var current_state = IDLE

var dir = Vector2.RIGHT
@export var start_position: Vector2

var is_roaming = true
var is_chatting = false

var player = null
var player_in_chat_zone = false

func _ready():
	randomize()
	start_position = position


func _process(delta):
	if current_state != MOVE: 
		$AnimatedSprite2D.play("idle")
	elif current_state == MOVE and !is_chatting:
		if dir.x == -1:
			$AnimatedSprite2D.play("walk_w")
		if dir.x == 1:
			$AnimatedSprite2D.play("walk_e")
		if dir.y == -1:
			$AnimatedSprite2D.play("walk_n")
		if dir.y == 1:
			$AnimatedSprite2D.play("walk_s")
			
	if is_roaming:
		match current_state:
			IDLE:
				pass
			NEW_DIR:
				dir = Helpers.choose([Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT])
			MOVE:
				move(delta)

	if Input.is_action_just_pressed("chat"):
		print("chatting with player")
		$Dialogue.start()
		is_roaming = false
		is_chatting = true
		$AnimatedSprite2D.play("idle")


func move(_delta):
	if !is_chatting:
		#position += dir * SPEED * delta
		velocity = dir * SPEED
		move_and_slide()
		#move_and_collide(Vector2(1.0, 1.0) * delta)


func _on_chat_detection_area_body_entered(body):
	if body.has_method("player"):
		player = body
		player_in_chat_zone = true


func _on_chat_detection_area_body_exited(body):
	if body.has_method("player"):
		player = null
		player_in_chat_zone = false


func _on_timer_timeout():
	$Timer.wait_time = Helpers.choose([0.5, 1.0, 1.5])
	current_state = Helpers.choose([IDLE, NEW_DIR, MOVE])


func set_start_position(pos: Vector2):
	position = pos


func _on_dialogue_dialogue_finished():
	is_chatting = false
	is_roaming = true
