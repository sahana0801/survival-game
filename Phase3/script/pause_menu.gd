extends Control


func _on_resume_button_pressed():
	get_tree().paused = false
	$CanvasLayer.visible = false


func _on_settings_button_pressed():
	#SceneManager.SwitchScene("Settings")
	pass # Replace with function body.


func _on_exit_button_pressed():
	get_tree().paused = false
	SceneManager.SwitchScene("Menu")
