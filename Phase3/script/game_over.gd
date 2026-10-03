extends Panel

@export var player: Player
var done = false

func _ready():
	player.playerDied.connect(update)
	#update()


func update():
	if !done:
		PlayerStats.end_time = Time.get_unix_time_from_system()
		var time_played = int(PlayerStats.end_time - PlayerStats.start_time)
		var hours = time_played / 3600
		time_played = time_played % 3600
		var minutes = time_played / 60
		time_played = time_played % 60
		var seconds = time_played
		var min_str
		if minutes < 10:
			min_str = "0" + str(minutes)
		else:
			min_str = str(minutes)
		var sec_str
		if seconds < 10:
			sec_str = "0" + str(seconds)
		else:
			sec_str = str(seconds)
		var timestring = str(hours) + ":" + min_str + ":" + sec_str 
		$StatisticsLabel.text = "You played for " + timestring + " and died on day " + str(PlayerStats.day) + "."
		self.visible = true
		done = true


func _input(_event):
	pass # Replace with function body.


func _on_main_menu_button_pressed():
	#get_tree().change_scene_to_file("res://scene/main_menu.tscn")
	SceneManager.SwitchScene("Menu")


func _on_restart_button_pressed():
	SceneManager.SwitchScene("World 1")
