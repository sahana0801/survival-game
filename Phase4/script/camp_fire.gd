class_name Campfire extends StaticBody2D

var is_burning: bool = false
var is_placed: bool = false
var player: CharacterBody2D = null
var tutorial_message_2_shown: bool = false


func _ready() -> void:
	set_process(false)
	$AnimatedSprite2D.play("not_burning")


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire") and player != null:
		toggle_fire()


func toggle_fire() -> void:
	is_burning = !is_burning
	if is_burning:
		$AnimatedSprite2D.play("burning")
	else:
		$AnimatedSprite2D.play("not_burning")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player = body
		set_process(true)
		if !tutorial_message_2_shown:
			PlayerStats.send_message("You can ignite the campfire by pressing \"F\"")
			tutorial_message_2_shown = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		set_process(false)
