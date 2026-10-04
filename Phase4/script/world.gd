extends Node2D

var tutorial_message_1_shown: bool = false
@onready var pause_menu: CanvasLayer = $PauseMenu/CanvasLayer


func _ready() -> void:
	if has_node("Player/InventoryStacked"):
		PlayerStats.player_inventory = $Player/InventoryStacked
	if has_node("Player/CtrlInventoryStacked"):
		PlayerStats.cp_inventory = $Player/CtrlInventoryStacked
	
	if has_node("SlimeKing") and has_node("CanvasLayer/BossHealthBar"):
		var boss: SlimeKing = $SlimeKing
		var boss_bar: BossHealthBar = $CanvasLayer/BossHealthBar
		boss.boss_health_updated.connect(boss_bar.update_health)
		boss.boss_defeated.connect(boss_bar.on_boss_defeated)
		boss_bar.setup(boss.max_health)
		
	call_deferred("_show_initial_tutorial")


func _show_initial_tutorial() -> void:
	if not tutorial_message_1_shown:
		PlayerStats.send_message("Trang bị Cung (1) hoặc Kiếm (2)! Đổi Ngoại Hình (T)! Khám phá bản đồ & Cổng Cổ Đại!")
		tutorial_message_1_shown = true


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
