class_name BossPortal extends Area2D

@export var target_scene: String = "res://scene/boss_arena.tscn"

var player_in_range: bool = false
var pulse_time: float = 0.0

@onready var prompt_label: Label = $PromptLabel


func _ready():
	if prompt_label != null:
		prompt_label.visible = false
		if target_scene.contains("world"):
			prompt_label.text = "[E] Return to Surface"
		else:
			prompt_label.text = "[E] Enter Slime King's Lair"


func _process(delta: float):
	pulse_time += delta * 2.5
	queue_redraw()
	
	if player_in_range and Input.is_action_just_pressed("harvest"):
		enter_portal()


func _draw():
	var pulse = (sin(pulse_time) + 1.0) * 0.5
	var outer_r = 26.0 + pulse * 3.0
	
	# Draw glowing runic circle
	draw_circle(Vector2.ZERO, outer_r, Color(0.55, 0.15, 0.85, 0.25))
	draw_arc(Vector2.ZERO, outer_r, 0, TAU, 32, Color(0.85, 0.45, 1.0, 0.9), 2.0)
	draw_arc(Vector2.ZERO, 16.0, 0, TAU, 24, Color(1.0, 0.85, 0.3, 0.8), 1.5)
	
	# Star runes
	for i in range(4):
		var angle = (float(i) / 4.0) * TAU + pulse_time * 0.2
		var p = Vector2(cos(angle), sin(angle)) * 16.0
		draw_circle(p, 2.5, Color(1.0, 0.85, 0.3))


func enter_portal():
	var tree = get_tree()
	if tree != null:
		tree.change_scene_to_file(target_scene)


func _on_body_entered(body: Node2D):
	if body.has_method("player"):
		player_in_range = true
		if prompt_label != null:
			prompt_label.visible = true


func _on_body_exited(body: Node2D):
	if body.has_method("player"):
		player_in_range = false
		if prompt_label != null:
			prompt_label.visible = false
