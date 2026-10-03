class_name HotbarUI
extends Control

@export var player: Player

const KIT_PATH := "res://addons/pixel_ui_fantasy/"
const THEME_PATH := "res://addons/pixel_ui_fantasy/themes/parchment.tres"

var theme_res: Theme
var hud_font: Font = preload("res://font/hud_font.ttf")

var panel_container: PanelContainer
var hbox: HBoxContainer
var slot_nodes: Array[PanelContainer] = []
var active_weapon_idx: int = 0

# 4 Slots: Slot 1: Sword, Slot 2: Bow, Slot 3 & 4: Future Skills/Empty
var slot_defs := [
	["sword", "icons/sword.png", "1"],
	["bow", "art/bow.png", "2"],
	["slot3", "", "3"],
	["slot4", "", "4"]
]


func _ready() -> void:
	theme_res = load(THEME_PATH)
	if theme_res and theme_res.default_font:
		if not hud_font in theme_res.default_font.fallbacks:
			theme_res.default_font.fallbacks.append(hud_font)
	theme = theme_res

	_build_hotbar()

	if player != null:
		player.weaponChanged.connect(_on_weapon_changed)
	
	if PlayerStats != null:
		PlayerStats.characterChanged.connect(_on_character_changed)
		PlayerStats.ShootingChanged.connect(_update_weapon_icons)
	
	_update_weapon_icons()
	update_active_weapon(0)
	call_deferred("_connect_player")


func _update_weapon_icons() -> void:
	if PlayerStats == null:
		return
	if slot_nodes.size() > 0:
		var icon_rect = slot_nodes[0].get_node_or_null("Icon") as TextureRect
		if icon_rect != null:
			var path = PlayerStats.get_sword_texture_path()
			if ResourceLoader.exists(path):
				icon_rect.texture = load(path)
	if slot_nodes.size() > 1:
		var icon_rect = slot_nodes[1].get_node_or_null("Icon") as TextureRect
		if icon_rect != null:
			var path = PlayerStats.get_bow_texture_path()
			if ResourceLoader.exists(path):
				icon_rect.texture = load(path)


func _connect_player() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
		if player == null:
			player = get_node_or_null("../../Player")
	
	if player != null:
		if not player.weaponChanged.is_connected(_on_weapon_changed):
			player.weaponChanged.connect(_on_weapon_changed)
	
	update_active_weapon(active_weapon_idx)


func _on_character_changed(_new_char: int) -> void:
	update_active_weapon(active_weapon_idx)


func _build_hotbar() -> void:
	# Clear previous children
	for child in get_children():
		child.queue_free()

	panel_container = PanelContainer.new()
	panel_container.theme_type_variation = &"Panel"
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel_container)

	hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 2)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_container.add_child(hbox)

	slot_nodes.clear()
	for i in slot_defs.size():
		var def = slot_defs[i]
		var s := _create_hotbar_slot(i, def[0], def[1], def[2])
		hbox.add_child(s)
		slot_nodes.append(s)


func _create_hotbar_slot(index: int, _slot_id: String, icon_path: String, hotkey_str: String) -> PanelContainer:
	var s := PanelContainer.new()
	s.theme_type_variation = &"InsetPanel"
	s.custom_minimum_size = Vector2(24, 24)
	s.mouse_filter = Control.MOUSE_FILTER_PASS
	s.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Icon
	var icon_rect := TextureRect.new()
	icon_rect.name = "Icon"
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	elif icon_path != "" and ResourceLoader.exists(KIT_PATH + icon_path):
		icon_rect.texture = load(KIT_PATH + icon_path)
	s.add_child(icon_rect)

	# Hotkey number in top-left corner
	var key_lbl := Label.new()
	key_lbl.name = "Key"
	key_lbl.text = hotkey_str
	key_lbl.add_theme_font_override("font", hud_font)
	key_lbl.add_theme_font_size_override("font_size", 9)
	key_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	key_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	key_lbl.add_theme_constant_override("shadow_offset_x", 1)
	key_lbl.add_theme_constant_override("shadow_offset_y", 1)
	key_lbl.position = Vector2(2, 0)
	key_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s.add_child(key_lbl)

	s.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_activate_slot(index)
	)
	return s


func _activate_slot(index: int) -> void:
	if player == null:
		_connect_player()
	if player == null:
		return

	match index:
		0: # Slot 1: Sword
			if PlayerStats.active_character == PlayerStats.CharacterType.ARCHER:
				PlayerStats.send_message("🏹 Cung Thủ chỉ chuyên dùng Cung! Hãy đổi sang Hiệp Sĩ để dùng Kiếm.")
				return
			player.equip_weapon(2)
		1: # Slot 2: Bow
			if PlayerStats.active_character == PlayerStats.CharacterType.KNIGHT:
				PlayerStats.send_message("⚔️ Hiệp Sĩ chỉ chuyên dùng Kiếm! Hãy đổi sang Cung Thủ để dùng Cung.")
				return
			player.equip_weapon(1)
		2: # Slot 3
			pass
		3: # Slot 4
			pass


func _on_weapon_changed(weapon_index: int):
	active_weapon_idx = weapon_index
	update_active_weapon(weapon_index)


func update_active_weapon(weapon_index: int):
	active_weapon_idx = weapon_index
	var is_archer = (PlayerStats.active_character == PlayerStats.CharacterType.ARCHER) if PlayerStats else false

	for i in slot_nodes.size():
		var s = slot_nodes[i]
		var icon_rect = s.get_node_or_null("Icon") as TextureRect

		if (i == 0 and weapon_index == 2) or (i == 1 and weapon_index == 1):
			s.theme_type_variation = &"ActiveSkillSlot"
		else:
			s.theme_type_variation = &"InsetPanel"

		# Dim weapon not usable by current character class
		if icon_rect != null:
			if (i == 0 and is_archer) or (i == 1 and not is_archer):
				icon_rect.modulate = Color(0.4, 0.4, 0.4, 0.6)
			else:
				icon_rect.modulate = Color.WHITE


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_activate_slot(0)
			KEY_2:
				_activate_slot(1)
			KEY_3:
				_activate_slot(2)
			KEY_4:
				_activate_slot(3)
