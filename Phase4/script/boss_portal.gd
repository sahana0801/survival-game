class_name BossPortal extends Area2D

@export var target_scene: String = "res://scene/boss_arena.tscn"

var player_in_range: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var anim_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")


func _ready() -> void:
	if anim_sprite != null:
		anim_sprite.play("idle")
		
	if prompt_label != null:
		prompt_label.visible = false
		if target_scene.contains("route_1"):
			prompt_label.text = "[E] Trở về Route 1"
		elif target_scene.contains("world"):
			prompt_label.text = "[E] Trở về Làng"
		elif target_scene.contains("executioner_arena"):
			prompt_label.text = "[E] Vào Cõi Tử Thần (Boss)"
		elif target_scene.contains("boss_arena"):
			prompt_label.text = "[E] Vào Hang Ổ Vua Slime"
		else:
			prompt_label.text = "[E] Dịch chuyển"


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("harvest"):
		enter_portal()


func enter_portal() -> void:
	if SceneManager != null and SceneManager.has_method("transition_to_scene"):
		var z_name := "🌿 Tuyến Đường 1"
		var spawn_pos := Vector2.INF
		if target_scene.contains("boss_arena"):
			z_name = "👑 Hang Ổ Vua Slime"
		elif target_scene.contains("executioner_arena"):
			z_name = "💀 Cõi Tử Thần Hành Quyết"
			spawn_pos = Vector2(534, 505)
		elif target_scene.contains("route_1"):
			z_name = "🌿 Tuyến Đường 1"
			spawn_pos = Vector2(245, 60)
		elif target_scene.contains("world"):
			z_name = "🏡 Làng Khởi Đầu"
		SceneManager.transition_to_scene(target_scene, spawn_pos, z_name)
	else:
		var tree := get_tree()
		if tree != null:
			tree.change_scene_to_file(target_scene)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = true
		if prompt_label != null:
			prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false
		if prompt_label != null:
			prompt_label.visible = false
