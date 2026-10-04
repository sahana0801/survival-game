extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var dev_button: Button = get_node_or_null("CanvasLayer/Panel/DevDayNightButton")
@onready var settings_panel: Panel = get_node_or_null("CanvasLayer/SettingsPanel")
@onready var dev_settings_button: Button = get_node_or_null("CanvasLayer/SettingsPanel/DevDayNightButton")
@onready var dev_status_label: Label = get_node_or_null("CanvasLayer/SettingsPanel/StatusLabel")
@onready var sound_button: Button = get_node_or_null("CanvasLayer/SettingsPanel/SoundButton")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if canvas_layer != null:
		canvas_layer.visibility_changed.connect(_on_canvas_visibility_changed)
	_update_dev_button_text()
	_update_sound_button_text()


func _input(event: InputEvent) -> void:
	var is_esc: bool = event.is_action_pressed("ui_cancel") or (
		event is InputEventKey and event.pressed and not event.echo and (
			event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE
		)
	)
	if not is_esc:
		return

	# 1. If an inventory window is currently open, let inventory close first
	var inv_windows := get_tree().get_nodes_in_group("inventory_window")
	for inv in inv_windows:
		if inv is Control and inv.visible:
			return

	# 2. If settings sub-panel is open inside pause menu, close settings sub-panel
	if settings_panel != null and settings_panel.visible:
		settings_panel.visible = false
		get_viewport().set_input_as_handled()
		return

	# 3. Toggle pause menu state
	toggle_menu()
	get_viewport().set_input_as_handled()


func toggle_menu() -> void:
	if canvas_layer != null and canvas_layer.visible:
		close_menu()
	else:
		open_menu()


func open_menu() -> void:
	if canvas_layer != null:
		canvas_layer.visible = true
	get_tree().paused = true
	_update_dev_button_text()
	_update_sound_button_text()
	if settings_panel != null:
		settings_panel.visible = false


func close_menu() -> void:
	get_tree().paused = false
	if canvas_layer != null:
		canvas_layer.visible = false
	if settings_panel != null:
		settings_panel.visible = false


func _on_canvas_visibility_changed() -> void:
	if canvas_layer != null and canvas_layer.visible:
		_update_dev_button_text()
		_update_sound_button_text()
		if settings_panel != null:
			settings_panel.visible = false


func _on_resume_button_pressed() -> void:
	close_menu()


func _on_settings_button_pressed() -> void:
	if settings_panel != null:
		settings_panel.visible = !settings_panel.visible
		_update_dev_button_text()
		_update_sound_button_text()


func _on_close_settings_button_pressed() -> void:
	if settings_panel != null:
		settings_panel.visible = false


func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	SceneManager.SwitchScene("Menu")


func _on_dev_day_night_button_pressed() -> void:
	PlayerStats.toggle_day_night()
	_update_dev_button_text()


func _update_dev_button_text() -> void:
	var is_night: bool = PlayerStats.is_night
	var btn_text: String = "☀️ Đổi Sang Ban Ngày (Dev)" if is_night else "🌙 Đổi Sang Ban Đêm (Dev)"
	if dev_button != null:
		dev_button.text = btn_text
	if dev_settings_button != null:
		dev_settings_button.text = btn_text
	if dev_status_label != null:
		dev_status_label.text = "Trạng thái: %s" % ("Ban Đêm 🌙" if is_night else "Ban Ngày ☀️")


func _on_sound_button_pressed() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	var is_muted := AudioServer.is_bus_mute(master_bus)
	AudioServer.set_bus_mute(master_bus, !is_muted)
	_update_sound_button_text()


func _update_sound_button_text() -> void:
	if sound_button == null:
		return
	var master_bus := AudioServer.get_bus_index("Master")
	var is_muted := AudioServer.is_bus_mute(master_bus)
	sound_button.text = "Âm Thanh: %s" % ("Tắt 🔇" if is_muted else "Bật 🔊")
