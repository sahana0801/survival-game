class_name NightBossPortal extends Area2D

@export var target_scene: String = "res://scene/executioner_arena.tscn"

var player_in_range: bool = false
var is_active: bool = false

@onready var prompt_label: Label = $PromptLabel
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	# Connect to global Day/Night signals
	if not PlayerStats.NightStarted.is_connected(_on_night_started):
		PlayerStats.NightStarted.connect(_on_night_started)
	if not PlayerStats.DayStarted.is_connected(_on_day_started):
		PlayerStats.DayStarted.connect(_on_day_started)
		
	if prompt_label != null:
		prompt_label.visible = false
		prompt_label.text = "[E] Vào Cõi Tử Thần (Boss: Tử Thần Hành Quyết)"
		
	if anim_sprite != null:
		anim_sprite.play("idle")
		
	# Initial state based on current time
	if PlayerStats.is_night:
		_activate_portal(false)
	else:
		_deactivate_portal()


func _on_night_started() -> void:
	_activate_portal(true)


func _on_day_started() -> void:
	_deactivate_portal()


func _activate_portal(notify: bool = true) -> void:
	is_active = true
	visible = true
	monitoring = true
	monitorable = true
	
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if notify:
		PlayerStats.send_message("⚡ [ĐÊM TỐI] Cổng Tử Thần bí ẩn vừa xuất hiện ở Route 1!")


func _deactivate_portal() -> void:
	is_active = false
	player_in_range = false
	if prompt_label != null:
		prompt_label.visible = false
		
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void:
		visible = false
		monitoring = false
		monitorable = false
	)


func _process(_delta: float) -> void:
	if is_active and player_in_range and Input.is_action_just_pressed("harvest"):
		enter_portal()


func enter_portal() -> void:
	if SceneManager != null and SceneManager.has_method("transition_to_scene"):
		SceneManager.transition_to_scene(target_scene, Vector2(534, 505), "💀 Cõi Tử Thần Hành Quyết")
	else:
		var tree := get_tree()
		if tree != null:
			tree.change_scene_to_file(target_scene)


func _on_body_entered(body: Node2D) -> void:
	if is_active and body.has_method("player"):
		player_in_range = true
		if prompt_label != null:
			prompt_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		player_in_range = false
		if prompt_label != null:
			prompt_label.visible = false
