extends RichTextLabel

@export var player: Player


func _ready():
	PlayerStats.ShootingChanged.connect(update)
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update():
	text = "Bow Level %s" % PlayerStats.shooting
