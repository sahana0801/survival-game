extends TextureProgressBar


@export var player: Player


func _ready():
	player.thirstChanged.connect(update)
	update()


func update():
	value = int(player.current_thirst * 100 / player.max_thirst)
