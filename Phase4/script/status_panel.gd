class_name StatusPanel extends Control

@export var player: Player:
	set(val):
		player = val
		_propagate_player()

@onready var health_bar: TextureProgressBar = find_child("PlayerHealthBar", true, false)
@onready var thirst_bar: TextureProgressBar = find_child("PlayerThirstBar", true, false)
@onready var bow_text: RichTextLabel = find_child("ShootingLevelText", true, false)
@onready var day_text: RichTextLabel = find_child("DayText", true, false)
@onready var player_title: Label = find_child("PlayerTitle", true, false)
@onready var helmet_icon: TextureRect = find_child("HelmetIcon", true, false)
@onready var sword_icon: TextureRect = find_child("SwordIcon", true, false)


func _ready() -> void:
	if player == null:
		player = get_node_or_null("../../Player")
	_propagate_player()
	
	if PlayerStats != null:
		PlayerStats.characterChanged.connect(_on_character_changed)
		PlayerStats.ShootingChanged.connect(_on_weapon_tier_changed)
		_update_character_ui(PlayerStats.active_character)


func _on_weapon_tier_changed() -> void:
	_update_character_ui(PlayerStats.active_character)


func _on_character_changed(char_type: int) -> void:
	_update_character_ui(char_type)


func _update_character_ui(char_type: int) -> void:
	if char_type == PlayerStats.CharacterType.KNIGHT:
		if player_title != null:
			player_title.text = "Hiệp Sĩ"
		if helmet_icon != null:
			helmet_icon.texture = load("res://addons/pixel_ui_fantasy/icons/helmet.png")
		if sword_icon != null:
			var path = PlayerStats.get_sword_texture_path()
			sword_icon.texture = load(path) if ResourceLoader.exists(path) else load("res://addons/pixel_ui_fantasy/icons/sword.png")
	else:
		if player_title != null:
			player_title.text = "Cung Thủ"
		if helmet_icon != null:
			var path = PlayerStats.get_bow_texture_path()
			helmet_icon.texture = load(path) if ResourceLoader.exists(path) else load("res://art/bow.png")
		if sword_icon != null:
			var path = PlayerStats.get_bow_texture_path()
			sword_icon.texture = load(path) if ResourceLoader.exists(path) else load("res://art/bow.png")


func _propagate_player() -> void:
	if not is_inside_tree() or player == null:
		return
	if health_bar != null:
		if health_bar.has_method("set_player"):
			health_bar.set_player(player)
		else:
			health_bar.player = player
	if thirst_bar != null:
		if thirst_bar.has_method("set_player"):
			thirst_bar.set_player(player)
		else:
			thirst_bar.player = player
	if bow_text != null:
		bow_text.player = player
		if bow_text.has_method("update"):
			bow_text.update()
	if day_text != null:
		day_text.player = player
		if day_text.has_method("update"):
			day_text.update()
