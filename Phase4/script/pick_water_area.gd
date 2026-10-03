extends Area2D

var player: CharacterBody2D = null
var tutorial_message_3_shown: bool = false


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("harvest") and player != null:
		PlayerStats.WaterCollected.emit()


func _on_body_entered(body: Node2D) -> void:
	if body is Player or body.has_method("player"):
		player = body
		set_process(true)
		if !tutorial_message_3_shown:
			PlayerStats.send_message("Nhấn \"E\" để múc nước uống")
			tutorial_message_3_shown = true


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		set_process(false)
