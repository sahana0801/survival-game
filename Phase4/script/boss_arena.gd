extends Node2D

@onready var pause_menu = $PauseMenu/CanvasLayer
@onready var boss: SlimeKing = $SlimeKing
@onready var boss_bar: BossHealthBar = $CanvasLayer/BossHealthBar
@onready var return_portal = $ReturnPortal


func _ready():
	PlayerStats.player_inventory = $Player/InventoryStacked
	PlayerStats.cp_inventory = $Player/CtrlInventoryStacked
	
	if boss != null and boss_bar != null:
		boss.boss_health_updated.connect(boss_bar.update_health)
		boss.boss_defeated.connect(boss_bar.on_boss_defeated)
		boss.boss_defeated.connect(_on_boss_defeated)
		boss_bar.setup(boss.max_health, "ANCIENT SLIME MONARCH")
	
	PlayerStats.send_message("⚡ DANGER! You have entered the Ancient Slime Lair!")


func _on_boss_defeated():
	PlayerStats.send_message("👑 VICTORY! The Slime Monarch is defeated! Use the portal to return!")
	if return_portal != null:
		return_portal.visible = true


func _process(_delta):
	if Input.is_action_pressed("right_mouse") and PlayerStats.cp_inventory.visible and PlayerStats.c_inventory != null and PlayerStats.c_inventory.visible:
		PlayerStats.check_item_selected(PlayerStats.c_inventory)
		PlayerStats.check_item_selected(PlayerStats.cp_inventory)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pause_menu.visible = true
		get_tree().paused = true
	if event.is_action_pressed("help"):
		$CanvasLayer/KeyboardLayoutPanel.visible = !$CanvasLayer/KeyboardLayoutPanel.visible
