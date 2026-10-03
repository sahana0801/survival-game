extends Panel

@export var player: Player
var done: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player != null:
		player.playerDied.connect(update)


func update() -> void:
	if !done:
		PlayerStats.end_time = Time.get_unix_time_from_system()
		var time_played: int = int(PlayerStats.end_time - PlayerStats.start_time)
		var hours: int = time_played / 3600
		time_played = time_played % 3600
		var minutes: int = time_played / 60
		time_played = time_played % 60
		var seconds: int = time_played
		var min_str: String = ("0" + str(minutes)) if minutes < 10 else str(minutes)
		var sec_str: String = ("0" + str(seconds)) if seconds < 10 else str(seconds)
		var timestring: String = str(hours) + ":" + min_str + ":" + sec_str 
		$StatisticsLabel.text = "Bạn đã chơi được " + timestring + " và hy sinh vào ngày " + str(PlayerStats.day) + "."
		self.visible = true
		done = true


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.SwitchScene("Menu")


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.SwitchScene("World 1")
