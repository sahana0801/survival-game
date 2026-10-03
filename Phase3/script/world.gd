extends Node2D

@onready var tutorial_message_1_shown = false

@onready var pause_menu = $PauseMenu/CanvasLayer


func _ready():
	PlayerStats.player_inventory = $Player/InventoryStacked
	PlayerStats.cp_inventory = $Player/CtrlInventoryStacked


func _process(_delta):
	if !tutorial_message_1_shown:
		PlayerStats.send_message("Arm yourself with the bow (1)!")
		tutorial_message_1_shown = true
	if Input.is_action_pressed("right_mouse") and PlayerStats.cp_inventory.visible and PlayerStats.c_inventory.visible:
		PlayerStats.check_item_selected(PlayerStats.c_inventory)
		PlayerStats.check_item_selected(PlayerStats.cp_inventory)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		#get_tree().quit()
		pause_menu.visible = true
		get_tree().paused = true
	if event.is_action_pressed("help"):
		$CanvasLayer/KeyboardLayoutPanel.visible = !$CanvasLayer/KeyboardLayoutPanel.visible
