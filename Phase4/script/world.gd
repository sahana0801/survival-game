extends Node2D

@onready var tutorial_message_1_shown = false

@onready var pause_menu = $PauseMenu/CanvasLayer


func _ready():
	PlayerStats.player_inventory = $Player/InventoryStacked
	PlayerStats.cp_inventory = $Player/CtrlInventoryStacked
	
	if has_node("SlimeKing") and has_node("CanvasLayer/BossHealthBar"):
		var boss = $SlimeKing
		var boss_bar = $CanvasLayer/BossHealthBar
		boss.boss_health_updated.connect(boss_bar.update_health)
		boss.boss_defeated.connect(boss_bar.on_boss_defeated)
		boss_bar.setup(boss.max_health)


func _process(_delta):
	if !tutorial_message_1_shown:
		PlayerStats.send_message("Equip Bow (1) or Sword (2)! Toggle Skin (T)! Explore the map & enter the Ancient Portal (B)!")
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
