extends TextureRect

@onready var menu_music = $MenuMusic


func _on_new_game_button_pressed():
	SceneManager.SwitchScene("World 1")


func _on_exit_button_pressed():
	SceneManager.QuitGame()


func _on_credits_button_pressed():
	SceneManager.SwitchScene("Credits")
