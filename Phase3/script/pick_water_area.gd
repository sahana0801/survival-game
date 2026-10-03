extends Area2D

@export var player: Player
@export var item: InvItem

@onready var tutorial_message_3_shown = false


func _process(_delta):
	pick_water()


func pick_water():
	if Input.is_action_just_pressed("harvest") and player != null:
		PlayerStats.WaterCollected.emit()


func _on_body_entered(body):
	if body.has_method("player"):
		player = body
		if !tutorial_message_3_shown:
			PlayerStats.send_message("You can get some water with \"E\"")
			tutorial_message_3_shown = true


func _on_body_exited(body):
	if body.has_method("player"):
		player = null
