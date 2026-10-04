@tool
class_name RPGInventoryUI
extends CtrlInventoryStacked

@export var window_title: String = "🎒 Túi Đồ"
@export var is_chest: bool = false

var window_bg: NinePatchRect
var title_bar: HBoxContainer
var title_label: Label
var close_btn: Button
var hud_font: Font = preload("res://font/hud_font.ttf")

var style_inset: StyleBoxTexture
var style_focus: StyleBoxTexture
var style_bg: StyleBoxTexture
var style_fill: StyleBoxTexture


func _ready():
	super._ready()
	_apply_fantasy_skin()


func _apply_fantasy_skin():
	# 1. Custom Size
	custom_minimum_size = Vector2(180, 150)
	size = Vector2(180, 150)

	# 2. Window Background (WindowPanel 9-slice)
	if window_bg == null:
		window_bg = NinePatchRect.new()
		window_bg.texture = load("res://addons/pixel_ui_fantasy/themes/parchment/window.png")
		window_bg.patch_margin_left = 6
		window_bg.patch_margin_top = 19
		window_bg.patch_margin_right = 6
		window_bg.patch_margin_bottom = 6
		window_bg.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
		window_bg.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
		window_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		window_bg.show_behind_parent = true
		window_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(window_bg)

	# 3. Title Bar (inside the top 19px of window.png)
	if title_bar == null:
		title_bar = HBoxContainer.new()
		title_bar.position = Vector2(8, 2)
		title_bar.size = Vector2(size.x - 16, 15)
		title_bar.add_theme_constant_override("separation", 4)
		add_child(title_bar)

		title_label = Label.new()
		title_label.text = window_title
		title_label.add_theme_font_override("font", hud_font)
		title_label.add_theme_font_size_override("font_size", 10)
		title_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.72, 1.0))
		title_label.add_theme_color_override("font_shadow_color", Color(0.12, 0.08, 0.05, 0.9))
		title_label.add_theme_constant_override("shadow_offset_x", 1)
		title_label.add_theme_constant_override("shadow_offset_y", 1)
		title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title_bar.add_child(title_label)

		close_btn = Button.new()
		close_btn.text = "✕"
		close_btn.flat = true
		close_btn.custom_minimum_size = Vector2(16, 14)
		close_btn.add_theme_font_override("font", hud_font)
		close_btn.add_theme_font_size_override("font_size", 9)
		close_btn.add_theme_color_override("font_color", Color(0.95, 0.85, 0.65))
		close_btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.3))
		close_btn.pressed.connect(_on_close_pressed)
		title_bar.add_child(close_btn)

	# 4. Position and pad the inner VBoxContainer
	if _vbox_container:
		_vbox_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_vbox_container.offset_left = 8
		_vbox_container.offset_top = 21
		_vbox_container.offset_right = -8
		_vbox_container.offset_bottom = -8
		_vbox_container.add_theme_constant_override("separation", 3)

	# 5. Style Capacity Progress Bar
	if _progress_bar:
		_progress_bar.custom_minimum_size.y = 11
		
		style_bg = StyleBoxTexture.new()
		style_bg.texture = load("res://addons/pixel_ui_fantasy/themes/parchment/progress_bg.png")
		style_bg.texture_margin_left = 4
		style_bg.texture_margin_top = 2
		style_bg.texture_margin_right = 4
		style_bg.texture_margin_bottom = 2
		_progress_bar.add_theme_stylebox_override("background", style_bg)

		style_fill = StyleBoxTexture.new()
		style_fill.texture = load("res://addons/pixel_ui_fantasy/bars/bar_gold.png")
		style_fill.texture_margin_left = 5
		style_fill.texture_margin_top = 2
		style_fill.texture_margin_right = 5
		style_fill.texture_margin_bottom = 2
		_progress_bar.add_theme_stylebox_override("fill", style_fill)

	if _label:
		_label.add_theme_font_override("font", hud_font)
		_label.add_theme_font_size_override("font_size", 9)
		_label.add_theme_color_override("font_color", Color(0.20, 0.14, 0.08, 1.0))
		_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.95, 0.8, 0.5))
		_label.add_theme_constant_override("shadow_offset_x", 1)
		_label.add_theme_constant_override("shadow_offset_y", 1)

	# 6. Style ItemList
	if _item_list:
		style_inset = StyleBoxTexture.new()
		style_inset.texture = load("res://addons/pixel_ui_fantasy/themes/parchment/panel_inset.png")
		style_inset.texture_margin_left = 5
		style_inset.texture_margin_top = 5
		style_inset.texture_margin_right = 5
		style_inset.texture_margin_bottom = 5
		style_inset.content_margin_left = 4
		style_inset.content_margin_top = 4
		style_inset.content_margin_right = 4
		style_inset.content_margin_bottom = 4
		_item_list.add_theme_stylebox_override("panel", style_inset)

		style_focus = StyleBoxTexture.new()
		style_focus.texture = load("res://addons/pixel_ui_fantasy/themes/parchment/focus.png")
		style_focus.texture_margin_left = 4
		style_focus.texture_margin_top = 4
		style_focus.texture_margin_right = 4
		style_focus.texture_margin_bottom = 4
		_item_list.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		_item_list.add_theme_stylebox_override("selected", style_focus)
		_item_list.add_theme_stylebox_override("selected_focus", style_focus)

		_item_list.add_theme_font_override("font", hud_font)
		_item_list.add_theme_font_size_override("font_size", 10)
		_item_list.add_theme_color_override("font_color", Color(0.92, 0.88, 0.80))
		_item_list.add_theme_color_override("font_selected_color", Color(1.0, 0.95, 0.7))

		_item_list.max_columns = 1
		_item_list.same_column_width = true
		_item_list.fixed_icon_size = Vector2i(18, 18)


func _on_close_pressed():
	visible = false
	if is_chest and PlayerStats and PlayerStats.c_inventory == self:
		PlayerStats.c_inventory = null


func _refresh():
	super._refresh()
	if _label and inventory:
		_label.text = "Sức chứa: %d / %d" % [inventory.occupied_space, inventory.capacity]
