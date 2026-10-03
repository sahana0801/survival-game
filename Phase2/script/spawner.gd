extends Marker2D

# ==============================================================================
# BUG 4: "SLIME FLOOD" (The Infinite Multiplication Glitch)
# AI Story: AI quên giới hạn max_slimes và đặt timer spawn quá ngắn (0.8s)
# Result: Slimes sinh sôi nảy nở không ngừng, tràn ngập khắp hòn đảo! 🟢🟢🟢
# BONUS: Phím 'B' cho phép diễn giả trigger đẻ thêm 5 con cùng lúc để biểu diễn!
# ==============================================================================

var slime_scene = preload("res://scene/slime.tscn")
var player: CharacterBody2D = null

var max_slimes = 9999  # 🐛 BUG: Không có giới hạn!
var current_slimes = 0


func _ready():
	await get_tree().create_timer(0.5).timeout
	player = get_node_or_null("../Player")
	
	# Spawn ban đầu 3 con xung quanh người chơi
	for i in range(3):
		spawn_slime()
		
	$Timer.wait_time = 1.0
	$Timer.start()


func _unhandled_input(event):
	# Phím 'B': Diễn giả có thể chủ động bấm để spawn thêm bầy slime trước mắt khán giả!
	if event.is_action_pressed("spawn_more"):
		for i in range(5):
			spawn_slime()


func _on_timer_timeout():
	spawn_slime()
	$Timer.wait_time = randf_range(0.8, 1.4)
	$Timer.start()


func spawn_slime():
	var new_slime = slime_scene.instantiate()
	
	# Spawn xung quanh người chơi trong phạm vi 150 - 350 pixel
	var spawn_pos = global_position
	if player != null:
		var angle = randf() * TAU
		var distance = randf_range(150.0, 350.0)
		spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
		
	new_slime.global_position = spawn_pos
	get_parent().add_child(new_slime)
	current_slimes += 1
