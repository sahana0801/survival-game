extends TextureProgressBar

@export var player: Player

var ghost_bar: TextureProgressBar
var target_val: float = 100.0
var ghost_val: float = 100.0
var drain_delay_timer: float = 0.0


func _ready():
	ghost_bar = TextureProgressBar.new()
	ghost_bar.nine_patch_stretch = nine_patch_stretch
	ghost_bar.stretch_margin_left = stretch_margin_left
	ghost_bar.stretch_margin_top = stretch_margin_top
	ghost_bar.stretch_margin_right = stretch_margin_right
	ghost_bar.stretch_margin_bottom = stretch_margin_bottom
	ghost_bar.texture_under = texture_under
	ghost_bar.texture_progress = texture_progress
	# Cyan-blue glowing ghost color
	ghost_bar.tint_progress = Color(0.4, 0.8, 1.0, 0.9)
	ghost_bar.min_value = min_value
	ghost_bar.max_value = max_value
	ghost_bar.value = value
	ghost_bar.size = size
	ghost_bar.custom_minimum_size = custom_minimum_size
	ghost_bar.position = Vector2.ZERO
	ghost_bar.show_behind_parent = true
	add_child(ghost_bar)
	texture_under = null

	if player != null:
		if player.has_signal("manaChanged") and not player.manaChanged.is_connected(update):
			player.manaChanged.connect(update)
		elif not player.thirstChanged.is_connected(update):
			player.thirstChanged.connect(update)
		update()


func set_player(p: Player) -> void:
	if player != null:
		if player.has_signal("manaChanged") and player.manaChanged.is_connected(update):
			player.manaChanged.disconnect(update)
		if player.thirstChanged.is_connected(update):
			player.thirstChanged.disconnect(update)
	player = p
	if player != null and is_inside_tree():
		if player.has_signal("manaChanged") and not player.manaChanged.is_connected(update):
			player.manaChanged.connect(update)
		elif not player.thirstChanged.is_connected(update):
			player.thirstChanged.connect(update)
		update()


func update():
	if player == null or player.max_mana <= 0:
		return
	var new_val = float(player.current_mana * 100.0 / player.max_mana)
	if new_val < target_val:
		drain_delay_timer = 0.35
	else:
		ghost_val = new_val
		if ghost_bar != null:
			ghost_bar.value = new_val
	target_val = new_val
	value = target_val


func _process(delta):
	if drain_delay_timer > 0.0:
		drain_delay_timer -= delta
	else:
		if ghost_val > target_val:
			ghost_val = move_toward(ghost_val, target_val, delta * 35.0)
			if ghost_bar != null:
				ghost_bar.value = ghost_val
