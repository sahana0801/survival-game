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
		boss_bar.setup(boss.max_health, "VUA SLIME CỔ ĐẠI")
	if has_node("Player/Camera2D"):
		var cam: Camera2D = $Player/Camera2D
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 1788
		cam.limit_bottom = 908

	PlayerStats.send_message("⚡ NGUY HIỂM! Bạn đã bước vào Hang Ổ Slime Cổ Đại!")


func _on_boss_defeated():
	PlayerStats.send_message("👑 CHIẾN THẮNG! Vua Slime đã bị đánh bại! Hãy dùng cổng dịch chuyển để quay về!")
	if return_portal != null:
		return_portal.visible = true


func _process(_delta):
	if Input.is_action_pressed("right_mouse") and PlayerStats.cp_inventory.visible and PlayerStats.c_inventory != null and PlayerStats.c_inventory.visible:
		PlayerStats.check_item_selected(PlayerStats.c_inventory)
		PlayerStats.check_item_selected(PlayerStats.cp_inventory)


func _input(event):
	var is_esc: bool = event.is_action_pressed("ui_cancel") or (
		event is InputEventKey and event.pressed and not event.echo and (
			event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE
		)
	)
	if is_esc:
		var pm := get_node_or_null("PauseMenu")
		if pm != null and pm.has_method("toggle_menu"):
			pm.toggle_menu()
			get_viewport().set_input_as_handled()
		elif pause_menu != null:
			pause_menu.visible = !pause_menu.visible
			get_tree().paused = pause_menu.visible
			get_viewport().set_input_as_handled()
	if event.is_action_pressed("help"):
		if has_node("CanvasLayer/KeyboardLayoutPanel"):
			$CanvasLayer/KeyboardLayoutPanel.visible = !$CanvasLayer/KeyboardLayoutPanel.visible
