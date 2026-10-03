class_name Message extends CanvasLayer

@onready var messageText = $MarginContainer/messageText

func _ready():
	PlayerStats.sendMessage.connect(show_message)


func _on_timer_timeout():
	self.visible = false


func show_message(text: String):
	self.visible = true
	messageText.text = text
	$Timer.start()
