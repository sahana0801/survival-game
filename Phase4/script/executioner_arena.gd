extends Node2D

@onready var pause_menu: CanvasLayer = $PauseMenu/CanvasLayer
@onready var boss: UndeadExecutioner = $UndeadExecutioner
@onready var boss_bar: BossHealthBar = $CanvasLayer/BossHealthBar
@onready var return_portal: BossPortal = $ReturnPortal


func _ready() -> void:
	if has_node("Player/InventoryStacked"):
		PlayerStats.player_inventory = $Player/InventoryStacked
	if has_node("Player/CtrlInventoryStacked"):
		PlayerStats.cp_inventory = $Player/CtrlInventoryStacked
		
	if boss != null and boss_bar != null:
		boss.boss_health_updated.connect(boss_bar.update_health)
		boss.boss_defeated.connect(boss_bar.on_boss_defeated)
		boss.boss_defeated.connect(_on_boss_defeated)
		boss_bar.setup(boss.max_health, "TỬ THẦN HÀNH QUYẾT")
		
	if has_node("Player/Camera2D"):
		var cam: Camera2D = $Player/Camera2D
		cam.limit_left = 0
		cam.limit_top = 0
		cam.limit_right = 1788
		cam.limit_bottom = 952
		
	PlayerStats.send_message("⚡ BẠN ĐÃ BƯỚC VÀO CÕI TỬ THẦN! LƯỠI HÁI HÀNH QUYẾT ĐANG CHỜ ĐÓN!")


func _on_boss_defeated() -> void:
	PlayerStats.send_message("👑 CHIẾN THẮNG! Tử Thần Hành Quyết đã bị khuất phục! Hãy dùng cổng để trở về Route 1!")
	if return_portal != null:
		return_portal.visible = true


func _process(_delta: float) -> void:
	if Input.is_action_pressed("right_mouse"):
		if PlayerStats.cp_inventory != null and PlayerStats.c_inventory != null:
			if PlayerStats.cp_inventory.visible and PlayerStats.c_inventory.visible:
				PlayerStats.check_item_selected(PlayerStats.c_inventory)
				PlayerStats.check_item_selected(PlayerStats.cp_inventory)


func _input(event: InputEvent) -> void:
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
