extends RichTextLabel

@export var player: Player


func _ready():
	if not PlayerStats.ShootingChanged.is_connected(update):
		PlayerStats.ShootingChanged.connect(update)
	update()


func update():
	text = "Tier %d" % PlayerStats.weapon_level
