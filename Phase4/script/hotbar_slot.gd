class_name HotbarSlot extends PanelContainer

@export var hotkey_text: String = "1"
@export var active_border_color: Color = Color(1.0, 0.85, 0.25, 1.0)

var is_active: bool = false
var normal_style: StyleBoxFlat
var active_style: StyleBoxFlat

@onready var icon_rect: TextureRect = $MarginContainer/IconRect
@onready var hotkey_label: Label = $HotkeyLabel


func _ready():
	_create_styles()
	if hotkey_label != null:
		hotkey_label.text = hotkey_text
	set_active(false)


func _create_styles():
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.1, 0.12, 0.16, 0.88)
	normal_style.border_color = Color(0.28, 0.34, 0.42, 0.6)
	normal_style.set_border_width_all(1)
	normal_style.set_corner_radius_all(6)
	
	active_style = StyleBoxFlat.new()
	active_style.bg_color = Color(0.16, 0.22, 0.32, 0.95)
	active_style.border_color = active_border_color
	active_style.set_border_width_all(2)
	active_style.set_corner_radius_all(6)
	active_style.shadow_color = Color(active_border_color.r, active_border_color.g, active_border_color.b, 0.4)
	active_style.shadow_size = 4


func set_active(active: bool):
	is_active = active
	if normal_style == null:
		_create_styles()
	
	if is_active:
		add_theme_stylebox_override("panel", active_style)
		scale = Vector2(1.06, 1.06)
	else:
		add_theme_stylebox_override("panel", normal_style)
		scale = Vector2(1.0, 1.0)
