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

# 4 Slots: Slot 1 = Weapon (Sword for Knight, Bow for Archer), Slots 2-4 = Item slots (pre-bound with starter items)
var slot_defs := [
	["weapon", "", "1"],
	["slot2", "", "2"],
	["slot3", "", "3"],
	["slot4", "", "4"]
]
var hotbar_items: Array = ["weapon", "", "", ""]


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
	if PlayerStats == null or slot_nodes.is_empty():
		return
	var icon_rect = slot_nodes[0].get_node_or_null("Icon") as TextureRect
	if icon_rect != null:
		var is_archer = (PlayerStats.active_character == PlayerStats.CharacterType.ARCHER)
		var path = PlayerStats.get_bow_texture_path() if is_archer else PlayerStats.get_sword_texture_path()
		if ResourceLoader.exists(path):
			icon_rect.texture = load(path)
		elif is_archer and ResourceLoader.exists("res://art/bow.png"):
			icon_rect.texture = load("res://art/bow.png")
		elif not is_archer and ResourceLoader.exists(KIT_PATH + "icons/sword.png"):
			icon_rect.texture = load(KIT_PATH + "icons/sword.png")


func _connect_player() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
		if player == null:
			player = get_node_or_null("../../Player")
	
	if player != null:
		if not player.weaponChanged.is_connected(_on_weapon_changed):
			player.weaponChanged.connect(_on_weapon_changed)
		active_weapon_idx = player.current_weapon
		
		var inv = player.inventory_stacked
		if inv != null:
			if not inv.contents_changed.is_connected(refresh_all_item_slots):
				inv.contents_changed.connect(refresh_all_item_slots)
			if inv.has_signal("occupied_space_changed"):
				if not inv.occupied_space_changed.is_connected(refresh_all_item_slots):
					inv.occupied_space_changed.connect(refresh_all_item_slots)
	
	_update_weapon_icons()
	update_active_weapon(active_weapon_idx)
	refresh_all_item_slots()


func _on_character_changed(_new_char: int) -> void:
	_update_weapon_icons()
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
	var s := HotbarSlotUI.new()
	s.slot_index = index
	s.hotbar = self
	s.theme_type_variation = &"InsetPanel"
	s.custom_minimum_size = Vector2(24, 24)
	s.mouse_filter = Control.MOUSE_FILTER_PASS
	s.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Icon
	var icon_rect := TextureRect.new()
	icon_rect.name = "Icon"
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_rect.offset_left = 3
	icon_rect.offset_top = 3
	icon_rect.offset_right = -3
	icon_rect.offset_bottom = -3
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	elif icon_path != "" and ResourceLoader.exists(KIT_PATH + icon_path):
		icon_rect.texture = load(KIT_PATH + icon_path)
	s.add_child(icon_rect)

	# 2. Overlay Control for unconstrained positioning of Key and Count labels
	var overlay := Control.new()
	overlay.name = "Overlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	s.add_child(overlay)

	# 3. Hotkey number in top-left corner
	var key_lbl := Label.new()
	key_lbl.name = "Key"
	key_lbl.text = hotkey_str
	key_lbl.add_theme_font_override("font", hud_font)
	key_lbl.add_theme_font_size_override("font_size", 9)
	key_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.75, 1.0))
	key_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	key_lbl.add_theme_constant_override("shadow_offset_x", 1)
	key_lbl.add_theme_constant_override("shadow_offset_y", 1)
	key_lbl.set_anchors_preset(Control.PRESET_TOP_LEFT)
	key_lbl.offset_left = 2
	key_lbl.offset_top = 0
	key_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(key_lbl)

	# 4. Count label in bottom-right corner for stackable items
	var count_lbl := Label.new()
	count_lbl.name = "Count"
	count_lbl.add_theme_font_override("font", hud_font)
	count_lbl.add_theme_font_size_override("font_size", 8)
	count_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	count_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1.0))
	count_lbl.add_theme_constant_override("shadow_offset_x", 1)
	count_lbl.add_theme_constant_override("shadow_offset_y", 1)
	count_lbl.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	count_lbl.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	count_lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	count_lbl.offset_left = -16
	count_lbl.offset_top = -10
	count_lbl.offset_right = -2
	count_lbl.offset_bottom = -1
	count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	count_lbl.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	count_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_lbl.visible = false
	overlay.add_child(count_lbl)

	s.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_activate_slot(index)
			elif event.button_index == MOUSE_BUTTON_RIGHT and index > 0:
				unbind_slot(index)
	)
	return s


func bind_item_to_slot(index: int, item_id: String) -> void:
	if index <= 0 or index >= hotbar_items.size():
		return
	hotbar_items[index] = item_id
	_update_hotbar_slot_display(index)


func unbind_slot(index: int) -> void:
	if index <= 0 or index >= hotbar_items.size():
		return
	var old_id = hotbar_items[index]
	hotbar_items[index] = ""
	_update_hotbar_slot_display(index)
	if old_id != "":
		PlayerStats.send_message("🗑️ Đã xóa gán phím [%d]" % (index + 1))


func _activate_slot(index: int) -> void:
	if player == null:
		_connect_player()
	if player == null:
		return

	if index == 0:
		var is_archer = (PlayerStats.active_character == PlayerStats.CharacterType.ARCHER) if PlayerStats else false
		if is_archer:
			player.equip_weapon(Player.Weapon.BOW)
		else:
			player.equip_weapon(Player.Weapon.SWORD)
	else:
		_activate_item_slot(index)


func _activate_item_slot(index: int) -> void:
	if index < 0 or index >= hotbar_items.size():
		return
	var item_id = hotbar_items[index]
	if item_id == null or item_id == "" or item_id == "weapon":
		return

	if player == null:
		_connect_player()
	if player == null:
		return

	var inv = player.inventory_stacked
	var has_item_in_inv: bool = (inv != null and inv.has_item_by_id(item_id))

	if not has_item_in_inv:
		var item_name = _get_item_name_from_protoset(item_id)
		PlayerStats.send_message("❌ Đã hết %s trong túi đồ!" % item_name)
		_update_hotbar_slot_display(index)
		return

	match item_id:
		"apple":
			player.eat()
			PlayerStats.send_message("🍎 Đã ăn Táo (+15 Máu, +25 Điểm Sinh Tồn)!")
		"water_potion":
			if player.current_mana >= player.max_mana:
				PlayerStats.send_message("💧 Mana đã đầy, không cần dùng!")
			else:
				player.use_mana_potion()
				PlayerStats.send_message("✨ Đã dùng Bình Mana (+30 MP)!")
		"health_potion":
			if player.current_health >= player.max_health:
				PlayerStats.send_message("❤️ Máu đã đầy, không thể uống thêm!")
			else:
				player.drink_health_potion()
				PlayerStats.send_message("❤️ Đã uống Bình Máu (+40 Máu)!")

	_update_hotbar_slot_display(index)


func _update_hotbar_slot_display(index: int) -> void:
	if index <= 0 or index >= slot_nodes.size():
		return
	var s = slot_nodes[index]
	var icon_rect = s.find_child("Icon", false, false) as TextureRect
	var count_lbl = s.find_child("Count", false, false) as Label
	var item_id = hotbar_items[index]

	if item_id == null or item_id == "" or item_id == "weapon":
		if icon_rect:
			icon_rect.texture = null
		if count_lbl:
			count_lbl.visible = false
		s.tooltip_text = ""
		return

	var inv = player.inventory_stacked if player else null
	var count: int = 0
	var tex: Texture2D = null
	var item_name: String = ""

	if inv != null:
		var item = inv.get_item_by_id(item_id)
		if item != null and is_instance_valid(item):
			tex = item.get_texture()
			item_name = item.get_title()
			var stack = item.get_property("stack_size", 1)
			count = int(stack) if stack != null else 1

	if tex == null:
		tex = _get_item_texture_from_protoset(item_id)
	if item_name == "":
		item_name = _get_item_name_from_protoset(item_id)

	if icon_rect != null:
		icon_rect.texture = tex
		if count <= 0:
			icon_rect.modulate = Color(0.4, 0.4, 0.4, 0.5)
		else:
			icon_rect.modulate = Color.WHITE

	if count_lbl != null:
		if count > 0:
			count_lbl.text = str(count)
			count_lbl.visible = (count > 1)
			count_lbl.modulate = Color.WHITE
		else:
			count_lbl.text = "0"
			count_lbl.visible = true
			count_lbl.modulate = Color(0.9, 0.3, 0.3, 0.9)

	s.tooltip_text = "%s (x%d)" % [item_name, count]


func refresh_all_item_slots() -> void:
	for i in range(1, slot_nodes.size()):
		_update_hotbar_slot_display(i)


func _get_item_texture_from_protoset(item_id: String) -> Texture2D:
	var protoset = _get_protoset()
	if protoset != null:
		var path = protoset.get_item_property(item_id, "image", "")
		if path != "" and ResourceLoader.exists(path):
			return load(path)
	return null


func _get_item_name_from_protoset(item_id: String) -> String:
	var protoset = _get_protoset()
	if protoset != null:
		return str(protoset.get_item_property(item_id, "name", item_id))
	return item_id


func _get_protoset():
	if player != null and player.inventory_stacked != null:
		return player.inventory_stacked.item_protoset
	return load("res://inventory/inventory_stacked.tres")


func _on_weapon_changed(weapon_index: int):
	active_weapon_idx = weapon_index
	update_active_weapon(weapon_index)


func update_active_weapon(weapon_index: int):
	active_weapon_idx = weapon_index
	var is_archer = (PlayerStats.active_character == PlayerStats.CharacterType.ARCHER) if PlayerStats else false
	var is_equipped: bool = false
	if is_archer and weapon_index == Player.Weapon.BOW:
		is_equipped = true
	elif not is_archer and weapon_index == Player.Weapon.SWORD:
		is_equipped = true

	if slot_nodes.size() > 0:
		slot_nodes[0].theme_type_variation = &"ActiveSkillSlot" if is_equipped else &"InsetPanel"
		var icon_rect = slot_nodes[0].get_node_or_null("Icon") as TextureRect
		if icon_rect != null:
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
