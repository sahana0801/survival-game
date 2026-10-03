extends TextureProgressBar

@export var player: Player

var ghost_bar: TextureProgressBar
var target_val: float = 100.0
var ghost_val: float = 100.0
var drain_delay_timer: float = 0.0


func _ready():
	# Create ghost bar dynamically behind this bar
	ghost_bar = TextureProgressBar.new()
	ghost_bar.texture_under = null
	ghost_bar.texture_progress = texture_progress
	# Warm glowing orange-red ghost color
	ghost_bar.tint_progress = Color(1.0, 0.35, 0.2, 0.95)
	ghost_bar.min_value = min_value
	ghost_bar.max_value = max_value
	ghost_bar.value = value
	ghost_bar.size = size
	ghost_bar.position = Vector2.ZERO
	ghost_bar.show_behind_parent = true
	add_child(ghost_bar)
	
	if player != null:
		player.healthChanged.connect(update)
		update()


func update():
	if player == null:
		return
	var new_val = float(player.current_health * 100.0 / player.max_health)
	
	if new_val < target_val:
		# Player took damage -> delay ghost bar drain
		drain_delay_timer = 0.35
	else:
		# Player healed -> snap ghost bar up
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
			ghost_val = move_toward(ghost_val, target_val, delta * 38.0)
			if ghost_bar != null:
				ghost_bar.value = ghost_val
