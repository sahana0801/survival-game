extends RichTextLabel

@export var player: Player


func _ready():
	PlayerStats.DayChanged.connect(update)
	update()


func update():
	text = "Ngày " + str(PlayerStats.day)
