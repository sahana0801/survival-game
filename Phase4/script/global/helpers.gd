extends Node

const FloatingTextScene = preload("res://scene/floating_text.tscn")


func choose(array: Array):
	array.shuffle()
	return array.front()


func spawn_damage_number(global_pos: Vector2, value, color: Color = Color.WHITE, is_crit: bool = false, prefix: String = "", suffix: String = ""):
	var tree = get_tree()
	if tree == null:
		return
	var current_scene = tree.current_scene
	if current_scene == null:
		return
		
	var text_node = FloatingTextScene.instantiate()
	text_node.global_position = global_pos + Vector2(0, -12)
	current_scene.add_child(text_node)
	text_node.setup(value, color, is_crit, prefix, suffix)


func spawn_arrow_impact(global_pos: Vector2, arrow_tier: int = 1) -> void:
	var tree = get_tree()
	if tree == null:
		return
	var current_scene = tree.current_scene
	if current_scene == null:
		return
	arrow_tier = clampi(arrow_tier, 1, 4)
	var sheet_path = "res://art/weapons/impacts/impact_tier_%d.png" % arrow_tier
	if not ResourceLoader.exists(sheet_path):
		return
	var tex: Texture2D = load(sheet_path)
	var frame_count: int = 7 if arrow_tier == 3 else 6
	
	var anim_sprite := AnimatedSprite2D.new()
	var frames := SpriteFrames.new()
	frames.add_animation("impact")
	frames.set_animation_speed("impact", 22.0)
	frames.set_animation_loop("impact", false)
	
	for i in range(frame_count):
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * 64, 0, 64, 64)
		frames.add_frame("impact", atlas)
		
	anim_sprite.sprite_frames = frames
	anim_sprite.animation = &"impact"
	anim_sprite.global_position = global_pos
	anim_sprite.scale = Vector2(0.9, 0.9)
	anim_sprite.z_index = 15
	current_scene.add_child(anim_sprite)
	anim_sprite.play("impact")
	anim_sprite.animation_finished.connect(func(): anim_sprite.queue_free())
