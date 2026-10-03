extends TextureProgressBar

@export var player: CharacterBody2D


func _ready():
	await get_tree().create_timer(0.1).timeout
	if player == null:
		player = get_node_or_null("../../Player")
	if player != null and player.has_signal("healthChanged"):
		player.healthChanged.connect(update_bar)
		update_bar()


func update_bar():
	if player != null:
		value = int(player.current_health * 100 / player.max_health)
