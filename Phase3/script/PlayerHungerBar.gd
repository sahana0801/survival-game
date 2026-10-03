extends TextureProgressBar

@export var player: Player


func _ready():
	player.hungerChanged.connect(update)
	update()


func update():
	value = int(player.current_hunger * 100 / player.max_hunger)
