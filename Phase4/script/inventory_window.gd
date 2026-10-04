class_name RPGInventoryWindow
extends Control

@export var player: Player

const KIT_PATH := "res://addons/pixel_ui_fantasy/"
const THEME_PATH := "res://addons/pixel_ui_fantasy/themes/parchment.tres"
const SLOT_COUNT := 18

var theme_res: Theme
var hud_font: Font = preload("res://font/hud_font.ttf")

# UI Nodes
var window_panel: PanelContainer
var tab_container: TabContainer
var bag_grid: GridContainer
var gear_box: VBoxContainer
var weight_label: Label
var weight_bar: ProgressBar
var use_btn: Button
var drop_btn: Button
var info_btn: Button
var close_btn: Button

# State
var slots: Array[PanelContainer] = []
var selected_slot_index: int = -1
var selected_item = null


func _ready() -> void:
	theme_res = load(THEME_PATH)
	if theme_res and theme_res.default_font:
		if not hud_font in theme_res.default_font.fallbacks:
			theme_res.default_font.fallbacks.append(hud_font)
	theme = theme_res

	_build_ui()
	visible = false

	# Connect to PlayerStats and Inventory
	if PlayerStats != null:
		PlayerStats.sendMessage.connect(func(_msg): pass)
		PlayerStats.characterChanged.connect(func(_char): _build_gear_tab())
		PlayerStats.ShootingChanged.connect(_build_gear_tab)
	call_deferred("_connect_inventory")


func _connect_inventory() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as Player
		if player == null:
			player = get_node_or_null("../../Player")

	var inv = _get_inv()
	if inv != null:
		if not inv.contents_changed.is_connected(refresh_slots):
			inv.contents_changed.connect(refresh_slots)
		if inv.has_signal("occupied_space_changed"):
			if not inv.occupied_space_changed.is_connected(refresh_slots):
				inv.occupied_space_changed.connect(refresh_slots)
	refresh_slots()


func _get_inv():
	if PlayerStats and PlayerStats.player_inventory != null:
		return PlayerStats.player_inventory
	if player and player.has_node("InventoryStacked"):
		return player.get_node("InventoryStacked")
	return null


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		accept_event()


func _build_ui() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(256, 175)
	size = Vector2(256, 175)

	# 1. Main Window Panel
	window_panel = PanelContainer.new()
	window_panel.theme_type_variation = &"WindowPanel"
	window_panel.custom_minimum_size = Vector2(256, 175)
	window_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	window_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	window_panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton:
			accept_event()
	)
	add_child(window_panel)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 3)
	window_panel.add_child(main_vbox)

	# 2. Window Header Bar
	var title_row := HBoxContainer.new()
	title_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(title_row)

	var title_label := Label.new()
	title_label.text = "Inventory"
	title_label.theme_type_variation = &"Title"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_label)

	close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.flat = true
	close_btn.custom_minimum_size = Vector2(16, 14)
	close_btn.add_theme_font_override("font", hud_font)
	close_btn.add_theme_font_size_override("font_size", 10)
	close_btn.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
	close_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.3))
	close_btn.pressed.connect(func(): visible = false)
	title_row.add_child(close_btn)

	# 3. Tab Container (Bag / Gear)
	tab_container = TabContainer.new()
	tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(tab_container)

	# --- TAB 1: BAG ---
	var bag_container := MarginContainer.new()
	bag_container.name = "Bag"
	bag_container.add_theme_constant_override("margin_left", 3)
	bag_container.add_theme_constant_override("margin_top", 3)
	bag_container.add_theme_constant_override("margin_right", 3)
	bag_container.add_theme_constant_override("margin_bottom", 3)
	tab_container.add_child(bag_container)

	bag_grid = GridContainer.new()
	bag_grid.columns = 9
	bag_grid.add_theme_constant_override("h_separation", 2)
	bag_grid.add_theme_constant_override("v_separation", 2)
	bag_container.add_child(bag_grid)

	slots.clear()
	for i in SLOT_COUNT:
		var s := _create_slot(i)
		bag_grid.add_child(s)
		slots.append(s)

	# --- TAB 2: GEAR ---
	gear_box = VBoxContainer.new()
	gear_box.name = "Gear"
	gear_box.add_theme_constant_override("separation", 2)
	tab_container.add_child(gear_box)
	_build_gear_tab()

	# 4. Ornamental Divider
	var divider := HSeparator.new()
	main_vbox.add_child(divider)

	# 5. Weight Row
	var weight_row := HBoxContainer.new()
	weight_row.add_theme_constant_override("separation", 4)
	main_vbox.add_child(weight_row)

	var pouch_icon := TextureRect.new()
	pouch_icon.texture = load(KIT_PATH + "icons/chest.png")
	pouch_icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	weight_row.add_child(pouch_icon)

	weight_label = Label.new()
	weight_label.text = "Weight 0/200"
	weight_label.add_theme_font_override("font", hud_font)
	weight_label.add_theme_font_size_override("font_size", 9)
	weight_label.add_theme_color_override("font_color", Color(0.22, 0.14, 0.08, 1.0))
	weight_row.add_child(weight_label)

	weight_bar = ProgressBar.new()
	weight_bar.theme_type_variation = &"GreenBar"
	weight_bar.show_percentage = false
	weight_bar.custom_minimum_size = Vector2(60, 8)
	weight_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weight_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	weight_row.add_child(weight_bar)

	# 6. Action Buttons Row (Use / Drop / Info)
	var actions_row := HBoxContainer.new()
	actions_row.add_theme_constant_override("separation", 4)
	main_vbox.add_child(actions_row)

	use_btn = Button.new()
	use_btn.text = "Use"
	use_btn.icon = load(KIT_PATH + "icons/check.png")
	use_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	use_btn.pressed.connect(_on_use_pressed)
	actions_row.add_child(use_btn)

	drop_btn = Button.new()
	drop_btn.text = "Drop"
	drop_btn.icon = load(KIT_PATH + "icons/cross.png")
	drop_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drop_btn.pressed.connect(_on_drop_pressed)
	actions_row.add_child(drop_btn)

	info_btn = Button.new()
	info_btn.text = "Info"
	info_btn.icon = load(KIT_PATH + "icons/quest.png")
	info_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_btn.pressed.connect(_on_info_pressed)
	actions_row.add_child(info_btn)


func _create_slot(index: int) -> PanelContainer:
	var s := RPGInventorySlot.new()
	s.slot_index = index
	s.window = self
	s.theme_type_variation = &"InsetPanel"
	s.custom_minimum_size = Vector2(24, 24)
	s.mouse_filter = Control.MOUSE_FILTER_PASS

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
	s.add_child(icon_rect)

	var count_lbl := Label.new()
	count_lbl.name = "Count"
	count_lbl.add_theme_font_override("font", hud_font)
	count_lbl.add_theme_font_size_override("font_size", 9)
	count_lbl.add_theme_color_override("font_color", Color.WHITE)
	count_lbl.add_theme_color_override("font_shadow_color", Color.BLACK)
	count_lbl.add_theme_constant_override("shadow_offset_x", 1)
	count_lbl.add_theme_constant_override("shadow_offset_y", 1)
	count_lbl.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	count_lbl.position = Vector2(10, 8)
	count_lbl.visible = false
	s.add_child(count_lbl)

	s.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				_quick_use_slot(index)
			else:
				_select_slot(index)
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_quick_use_slot(index)
	)
	return s


func _build_gear_tab() -> void:
	for child in gear_box.get_children():
		child.queue_free()

	var is_archer = (PlayerStats.active_character == PlayerStats.CharacterType.ARCHER) if PlayerStats else false
	var weapon_name = "Cung Gỗ" if is_archer else "Kiếm Sắt"
	var icon_path = PlayerStats.get_bow_texture_path() if is_archer else PlayerStats.get_sword_texture_path()
	var tier_name = PlayerStats.get_weapon_tier_name() if PlayerStats else "Tier 1"
	var min_d = PlayerStats.get_weapon_min_damage() if PlayerStats else 12
	var max_d = PlayerStats.get_weapon_max_damage() if PlayerStats else 18
	var crit_pct = int(PlayerStats.get_weapon_crit_chance() * 100) if PlayerStats else 5
	var stat_text = "Cấp %s (%d~%d DMG, %d%% Crit)" % [tier_name, min_d, max_d, crit_pct]

	var r := HBoxContainer.new()
	r.add_theme_constant_override("separation", 4)
	gear_box.add_child(r)

	var s := PanelContainer.new()
	s.theme_type_variation = &"CommonSlot"
	s.custom_minimum_size = Vector2(24, 24)
	var icon_tex: Texture2D = null
	if ResourceLoader.exists(icon_path):
		icon_tex = load(icon_path)
	elif not is_archer and ResourceLoader.exists(KIT_PATH + "icons/sword.png"):
		icon_tex = load(KIT_PATH + "icons/sword.png")
	elif is_archer and ResourceLoader.exists("res://art/bow.png"):
		icon_tex = load("res://art/bow.png")

	if icon_tex != null:
		var tr := TextureRect.new()
		tr.texture = icon_tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tr.offset_left = 3
		tr.offset_top = 3
		tr.offset_right = -3
		tr.offset_bottom = -3
		s.add_child(tr)
	r.add_child(s)

	var name_lbl := Label.new()
	name_lbl.text = weapon_name
	name_lbl.add_theme_font_override("font", hud_font)
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.add_theme_color_override("font_color", Color(0.22, 0.14, 0.08, 1.0))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.add_child(name_lbl)

	var stat_lbl := Label.new()
	stat_lbl.text = stat_text
	stat_lbl.add_theme_font_override("font", hud_font)
	stat_lbl.add_theme_font_size_override("font_size", 9)
	stat_lbl.add_theme_color_override("font_color", Color(0.12, 0.45, 0.15, 1.0))
	r.add_child(stat_lbl)


func _select_slot(index: int) -> void:
	selected_slot_index = index
	_update_slot_highlights()

	var inv = _get_inv()
	if inv == null:
		selected_item = null
		return

	var items = inv.get_items()
	if index < items.size():
		selected_item = items[index]
	else:
		selected_item = null


func _update_slot_highlights() -> void:
	for i in slots.size():
		var s = slots[i]
		if i == selected_slot_index and selected_item != null:
			s.theme_type_variation = &"ActiveSkillSlot"
		else:
			var inv = _get_inv()
			var items = inv.get_items() if inv != null else []
			if i < items.size():
				s.theme_type_variation = _get_rarity_style(items[i])
			else:
				s.theme_type_variation = &"InsetPanel"


func _get_item_id(item) -> String:
	if item == null:
		return ""
	if "prototype_id" in item and item.prototype_id != "":
		return str(item.prototype_id)
	if item.has_method("get_id"):
		return str(item.get_id())
	return ""


func _get_rarity_style(item) -> StringName:
	var id = _get_item_id(item)
	match id:
		"sword", "bow":
			return &"RareSlot"
		"health_potion", "water_potion":
			return &"UncommonSlot"
		"gem", "slime":
			return &"EpicSlot"
		_:
			return &"CommonSlot"


func _get_item_stack_size(item) -> int:
	if item == null or not is_instance_valid(item):
		return 1
	var s = item.get_property("stack_size", 1)
	if s == null:
		return 1
	return max(1, int(s))


func refresh_slots() -> void:
	var inv = _get_inv()
	if inv == null or slots.is_empty():
		return

	var items = inv.get_items()
	for i in slots.size():
		var s = slots[i]
		var icon_rect = s.get_node_or_null("Icon") as TextureRect
		var count_lbl = s.get_node_or_null("Count") as Label
		if icon_rect == null or count_lbl == null:
			continue

		if i < items.size():
			var item = items[i]
			if item == null or not is_instance_valid(item):
				icon_rect.texture = null
				icon_rect.visible = false
				count_lbl.visible = false
				s.theme_type_variation = &"InsetPanel"
				s.tooltip_text = ""
				continue

			var tex: Texture2D = item.get_texture()
			if tex == null:
				var path = item.get_property("image")
				if path and ResourceLoader.exists(path):
					tex = load(path)
			icon_rect.texture = tex
			icon_rect.visible = (tex != null)

			var stack: int = _get_item_stack_size(item)

			if stack > 1:
				count_lbl.text = str(stack)
				count_lbl.visible = true
			else:
				count_lbl.visible = false

			if i == selected_slot_index:
				s.theme_type_variation = &"ActiveSkillSlot"
			else:
				s.theme_type_variation = _get_rarity_style(item)
			s.tooltip_text = "%s (x%d)" % [item.get_title(), stack]
		else:
			icon_rect.texture = null
			icon_rect.visible = false
			count_lbl.visible = false
			s.theme_type_variation = &"InsetPanel"
			s.tooltip_text = ""

	# Update weight bar
	var cap = float(inv.capacity) if "capacity" in inv else 50.0
	var occ = float(inv.occupied_space) if "occupied_space" in inv else float(items.size())
	weight_label.text = "Weight %d/%d" % [int(occ), int(cap)]
	weight_bar.max_value = cap
	weight_bar.value = occ


func _quick_use_slot(index: int) -> void:
	_select_slot(index)
	_on_use_pressed()


func _on_use_pressed() -> void:
	if selected_item == null or player == null or not is_instance_valid(selected_item):
		return

	var category = selected_item.get_property("category", "")
	if category != "consumable":
		PlayerStats.send_message("❌ Vật phẩm này không thể sử dụng trực tiếp!")
		return

	var inv = _get_inv()
	var id: String = _get_item_id(selected_item)
	var name_str: String = selected_item.get_title() if selected_item.has_method("get_title") else id

	match id:
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
		_:
			PlayerStats.send_message("Đã sử dụng: %s" % name_str)

	if selected_item != null and (not is_instance_valid(selected_item) or (inv != null and not inv.has_item(selected_item))):
		selected_slot_index = -1
		selected_item = null

	refresh_slots()


func _on_drop_pressed() -> void:
	if selected_item == null or player == null or not is_instance_valid(selected_item):
		return

	var inv = _get_inv()
	if inv == null:
		return

	var id: String = _get_item_id(selected_item)
	var name_str: String = selected_item.get_title() if selected_item.has_method("get_title") else id

	if player.remove_item(id, 1):
		PlayerStats.send_message("Đã vứt 1 %s xuống đất" % name_str)

	if selected_item != null and (not is_instance_valid(selected_item) or not inv.has_item(selected_item)):
		selected_slot_index = -1
		selected_item = null

	refresh_slots()


func _on_info_pressed() -> void:
	if selected_item == null or not is_instance_valid(selected_item):
		PlayerStats.send_message("Chưa chọn vật phẩm nào!")
		return

	var id: String = _get_item_id(selected_item)
	var name_str: String = selected_item.get_title() if selected_item.has_method("get_title") else id
	var stack: int = _get_item_stack_size(selected_item)

	var desc := ""
	match id:
		"apple": desc = "Hồi 15 Máu & 25 Điểm Sinh Tồn."
		"water_potion": desc = "Bình ma thuật màu xanh hồi phục 30 Điểm Mana (MP)."
		"health_potion": desc = "Bình máu đỏ hồi phục 40 Điểm Máu."
		"sword": desc = "Vũ khí cận chiến sắc bén (Sát thương tăng theo Cấp Vũ Khí)."
		"bow": desc = "Vũ khí tầm xa linh hoạt."
		"stick": desc = "Cành cây dùng làm củi lửa trại hoặc nâng cấp."
		"slime": desc = "Chất nhờn ma thuật rơi từ quái vật Slime."
		_: desc = "Vật phẩm sinh tồn quý giá."

	PlayerStats.send_message("ℹ️ [%s x%d]: %s" % [name_str, stack, desc])


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory") or (event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_I or event.keycode == KEY_TAB)):
		visible = !visible
		if visible:
			refresh_slots()
			_build_gear_tab()
		get_viewport().set_input_as_handled()
	elif visible and (event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE)):
		visible = false
		get_viewport().set_input_as_handled()
