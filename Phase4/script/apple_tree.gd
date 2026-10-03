class_name AppleTree extends Node2D

enum state { NO_APPLES, APPLES }
var current_state = state.NO_APPLES
var player_in_area = false

var apple = preload("res://scene/apple_collectable.tscn")

@export var item: InvItem
var player = null

#@onready var tutorial_message_3_shown = false

func _ready():
	if current_state == state.NO_APPLES:
		$growth_timer.start()


func _process(_delta):
	match current_state:
		state.NO_APPLES:
			$AnimatedSprite2D.play("no_apples")
		state.APPLES:
			$AnimatedSprite2D.play("apples")
			if player_in_area:
				if Input.is_action_just_pressed("harvest"):
					current_state = state.NO_APPLES
					drop_apple()


func _on_pickable_area_body_entered(body):
	if body.has_method("player"):
		player_in_area = true
		player = body
		if !PlayerStats.tutorial_message_3_shown:
			PlayerStats.send_message("You might want to pick some apples with \"E\" (when they are ready)")
			PlayerStats.tutorial_message_3_shown = true


func _on_pickable_area_body_exited(body):
	if body.has_method("player"):
		player_in_area = false
		player = null


func _on_growth_timer_timeout():
	if current_state == state.NO_APPLES:
		current_state = state.APPLES


func drop_apple():
	#await get_tree().create_timer(0.3).timeout
	var apple_instance = apple.instantiate()
	apple_instance.rotation = rotation
	apple_instance.position = $Marker2D.position
	add_child(apple_instance)
	#player.collect(item)
	PlayerStats.AppleCollected.emit()
	await get_tree().create_timer(3).timeout
	$growth_timer.start()
