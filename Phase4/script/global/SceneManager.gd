extends Node
class_name NSceneManager

@export var Scenes : Dictionary = {
	"Menu": "res://scene/main_menu.tscn",
	"Credits": "res://scene/credits.tscn",
	"World 1": "res://scene/world.tscn",
	"Route 1": "res://scene/route_1_world.tscn",
	"Executioner Arena": "res://scene/executioner_arena.tscn"
}

var m_CurrentSceneAlias : String = ""

# Persistent player data across scene transitions
var saved_inventory_data: Dictionary = {}
var saved_health: int = -1
var saved_weapon: int = -1

# Transition UI
var transition_layer: CanvasLayer = null
var fade_rect: ColorRect = null
var zone_label: Label = null
var is_transitioning: bool = false

# Photo Mode & HUD Toggle
var hud_layer: CanvasLayer = null
var hud_btn: Button = null
var hud_toast: Label = null
var is_hud_hidden: bool = false
var toast_tween: Tween = null


func _ready() -> void:
	var mainScene : String = ProjectSettings.get_setting("application/run/main_scene")
	m_CurrentSceneAlias = Scenes.find_key(mainScene)
	_setup_transition_ui()
	_setup_hud_toggle_ui()


func _setup_transition_ui() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 128
	add_child(transition_layer)
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.add_child(fade_rect)
	
	zone_label = Label.new()
	zone_label.set_anchors_preset(Control.PRESET_CENTER)
	zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	zone_label.modulate = Color(1, 1, 1, 0)
	zone_label.add_theme_font_size_override("font_size", 32)
	transition_layer.add_child(zone_label)


func _setup_hud_toggle_ui() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 110
	add_child(hud_layer)
	
	hud_btn = Button.new()
	hud_btn.text = "📷 Ẩn HUD (H)"
	hud_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	hud_btn.offset_left = -175.0
	hud_btn.offset_top = 20.0
	hud_btn.offset_right = -20.0
	hud_btn.offset_bottom = 58.0
	hud_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hud_btn.tooltip_text = "Ẩn/Hiện toàn bộ giao diện để chụp ảnh màn hình (Phím tắt: H hoặc F2)"
	
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.12, 0.14, 0.18, 0.85)
	style_normal.border_color = Color(0.85, 0.72, 0.4, 0.9)
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(6)
	style_normal.content_margin_left = 10
	style_normal.content_margin_right = 10
	style_normal.content_margin_top = 4
	style_normal.content_margin_bottom = 4
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.22, 0.25, 0.32, 0.95)
	style_hover.border_color = Color(1.0, 0.88, 0.5, 1.0)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Color(0.08, 0.09, 0.12, 0.95)
	style_pressed.border_color = Color(0.7, 0.55, 0.25, 1.0)
	
	hud_btn.add_theme_stylebox_override("normal", style_normal)
	hud_btn.add_theme_stylebox_override("hover", style_hover)
	hud_btn.add_theme_stylebox_override("pressed", style_pressed)
	hud_btn.add_theme_color_override("font_color", Color(0.95, 0.92, 0.82))
	hud_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.9))
	hud_btn.add_theme_font_size_override("font_size", 13)
	
	if ResourceLoader.exists("res://font/hud_font.ttf"):
		hud_btn.add_theme_font_override("font", load("res://font/hud_font.ttf"))
		
	hud_btn.pressed.connect(toggle_hud)
	hud_btn.mouse_entered.connect(_on_hud_btn_mouse_entered)
	hud_btn.mouse_exited.connect(_on_hud_btn_mouse_exited)
	hud_layer.add_child(hud_btn)
	
	hud_toast = Label.new()
	hud_toast.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hud_toast.offset_left = -300.0
	hud_toast.offset_top = 24.0
	hud_toast.offset_right = 300.0
	hud_toast.offset_bottom = 64.0
	hud_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud_toast.modulate.a = 0.0
	hud_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var toast_style = StyleBoxFlat.new()
	toast_style.bg_color = Color(0.06, 0.08, 0.1, 0.9)
	toast_style.border_color = Color(0.85, 0.72, 0.4, 0.85)
	toast_style.set_border_width_all(1)
	toast_style.set_corner_radius_all(6)
	toast_style.content_margin_left = 16
	toast_style.content_margin_right = 16
	toast_style.content_margin_top = 6
	toast_style.content_margin_bottom = 6
	hud_toast.add_theme_stylebox_override("normal", toast_style)
	hud_toast.add_theme_color_override("font_color", Color(0.96, 0.94, 0.88))
	hud_toast.add_theme_font_size_override("font_size", 14)
	if ResourceLoader.exists("res://font/hud_font.ttf"):
		hud_toast.add_theme_font_override("font", load("res://font/hud_font.ttf"))
	hud_layer.add_child(hud_toast)


func _on_hud_btn_mouse_entered() -> void:
	if is_hud_hidden and hud_btn != null:
		var tw = create_tween()
		tw.tween_property(hud_btn, "modulate:a", 0.9, 0.15)


func _on_hud_btn_mouse_exited() -> void:
	if is_hud_hidden and hud_btn != null:
		var tw = create_tween()
		tw.tween_property(hud_btn, "modulate:a", 0.0, 0.15)


func toggle_hud() -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	var player = current_scene.get_node_or_null("Player")
	if player == null and not current_scene.has_node("Player"):
		return
		
	is_hud_hidden = !is_hud_hidden
	
	# 1. Toggle CanvasLayers in current scene
	for child in current_scene.get_children():
		if child is CanvasLayer:
			var cname = child.name.to_lower()
			if not "pause" in cname and not "transition" in cname:
				child.visible = !is_hud_hidden

	# 2. Toggle in-world interaction badges & speech bubbles for clean screenshot
	for badge in current_scene.find_children("*PromptBadge*", "Control", true, false):
		badge.visible = !is_hud_hidden
	for bubble in current_scene.find_children("*SpeechBubble*", "Control", true, false):
		bubble.visible = !is_hud_hidden

	# 3. Update button state
	if hud_btn != null:
		if is_hud_hidden:
			hud_btn.text = "👁️ Hiện HUD (H)"
			var tw = create_tween()
			tw.tween_property(hud_btn, "modulate:a", 0.0, 0.2)
			show_hud_toast("📷 Đã ẩn HUD · Nhấn H hoặc rê chuột góc trên-phải để hiện lại", 2.2)
		else:
			hud_btn.text = "📷 Ẩn HUD (H)"
			var tw = create_tween()
			tw.tween_property(hud_btn, "modulate:a", 1.0, 0.2)
			show_hud_toast("👁️ Đã hiện lại toàn bộ HUD", 1.2)


func show_hud_toast(msg: String, duration: float = 1.5) -> void:
	if hud_toast == null:
		return
	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()
		
	hud_toast.text = msg
	toast_tween = create_tween()
	toast_tween.tween_property(hud_toast, "modulate:a", 1.0, 0.15)
	toast_tween.tween_interval(duration)
	toast_tween.tween_property(hud_toast, "modulate:a", 0.0, 0.35)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H or event.keycode == KEY_F2 or (is_hud_hidden and event.keycode == KEY_F1):
			var current_scene = get_tree().current_scene
			if current_scene != null and current_scene.get_node_or_null("Player") != null:
				toggle_hud()
				get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var current_scene = get_tree().current_scene
	if current_scene != null and hud_layer != null:
		var has_player = current_scene.get_node_or_null("Player") != null
		hud_layer.visible = has_player


func transition_to_scene(scene_path: String, spawn_pos: Vector2 = Vector2.INF, zone_name: String = "") -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	# Save current player stats & inventory before leaving
	_save_player_state()
	
	# Block input during transition
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if zone_name != "":
		zone_label.text = zone_name
	
	# 1. Fade to Black
	var tween = create_tween().set_parallel(true)
	tween.tween_property(fade_rect, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if zone_name != "":
		tween.tween_property(zone_label, "modulate:a", 1.0, 0.35)
	await tween.finished
	
	# Small pause for dramatic effect
	await get_tree().create_timer(0.15).timeout
	
	# 2. Change Scene
	get_tree().change_scene_to_file(scene_path)
	
	# Wait for the new scene to be fully loaded into tree
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 3. Restore Player State & Position
	var current_scene = get_tree().current_scene
	if current_scene != null:
		var player = current_scene.get_node_or_null("Player")
		if player != null:
			if spawn_pos != Vector2.INF:
				player.global_position = spawn_pos
			_restore_player_state(player)
	
	# 4. Fade back in
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(fade_rect, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if zone_name != "":
		tween_in.tween_property(zone_label, "modulate:a", 0.0, 0.3)
	await tween_in.finished
	
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	is_hud_hidden = false
	if hud_btn != null:
		hud_btn.text = "📷 Ẩn HUD (H)"
		hud_btn.modulate.a = 1.0


func _save_player_state() -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	var player = current_scene.get_node_or_null("Player")
	if player != null:
		saved_health = player.current_health
		saved_weapon = player.current_weapon
		var inv = player.get_node_or_null("InventoryStacked")
		if inv != null and inv.has_method("serialize"):
			saved_inventory_data = inv.serialize()


func _restore_player_state(player: Node2D) -> void:
	if player == null:
		return
	if saved_health > 0:
		player.current_health = saved_health
		if player.has_signal("healthChanged"):
			player.healthChanged.emit()
	if saved_weapon >= 0:
		player.equip_weapon(saved_weapon)
	
	if not saved_inventory_data.is_empty():
		var inv = player.get_node_or_null("InventoryStacked")
		if inv != null and inv.has_method("deserialize"):
			inv.deserialize(saved_inventory_data)


func SwitchScene(sceneAlias : String) -> void:
	if Scenes.has(sceneAlias):
		transition_to_scene(Scenes[sceneAlias])


func RestartScene() -> void:
	get_tree().reload_current_scene()


func QuitGame() -> void:
	get_tree().quit()


func AddScene(sceneAlias : String, scenePath : String) -> void:
	Scenes[sceneAlias] = scenePath


func RemoveScene(sceneAlias : String) -> void:
	Scenes.erase(sceneAlias)


func GetSceneCount() -> int:
	return Scenes.size()


func GetCurrentSceneAlias() -> String:
	return m_CurrentSceneAlias
