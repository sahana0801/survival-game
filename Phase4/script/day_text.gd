extends RichTextLabel

@export var player: Player


func _ready():
	if not PlayerStats.DayChanged.is_connected(update):
		PlayerStats.DayChanged.connect(update)
	update()


func update():
	text = "Ngày " + str(PlayerStats.day)
