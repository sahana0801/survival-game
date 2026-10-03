class_name BossHealthBar extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var phase_label: Label = $VBoxContainer/PhaseLabel
@onready var health_bar: ProgressBar = $VBoxContainer/BarContainer/HealthBar
@onready var ghost_bar: ProgressBar = $VBoxContainer/BarContainer/GhostBar
@onready var victory_panel: PanelContainer = $VictoryPanel

var target_val: float = 1500.0
var ghost_val: float = 1500.0
var drain_delay_timer: float = 0.0


func _ready():
	visible = false
	if victory_panel != null:
		victory_panel.visible = false


func setup(max_hp: int, boss_name: String = "ANCIENT SLIME KING"):
	visible = true
	title_label.text = "👑 " + boss_name + " 👑"
	phase_label.text = "PHASE 1 / 3"
	health_bar.max_value = max_hp
	health_bar.value = max_hp
	ghost_bar.max_value = max_hp
	ghost_bar.value = max_hp
	target_val = max_hp
	ghost_val = max_hp
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)


func update_health(current_hp: int, phase: int):
	if current_hp < target_val:
		drain_delay_timer = 0.35
		
	target_val = float(current_hp)
	health_bar.value = target_val
	
	match phase:
		1:
			phase_label.text = "PHASE 1 / 3 — SLIME MONARCH"
			phase_label.modulate = Color(0.9, 0.95, 1.0)
		2:
			phase_label.text = "🔥 PHASE 2 / 3 — CRIMSON RAGE 🔥"
			phase_label.modulate = Color(1.0, 0.35, 0.25)
		3:
			phase_label.text = "⚡ PHASE 3 / 3 — COSMIC DESPERATION ⚡"
			phase_label.modulate = Color(0.85, 0.35, 1.0)


func _process(delta: float):
	if !visible:
		return
		
	if drain_delay_timer > 0.0:
		drain_delay_timer -= delta
	else:
		if ghost_val > target_val:
			ghost_val = move_toward(ghost_val, target_val, delta * 350.0)
			ghost_bar.value = ghost_val


func on_boss_defeated():
	phase_label.text = "DEFEATED"
	if victory_panel != null:
		victory_panel.visible = true
		victory_panel.scale = Vector2(0.5, 0.5)
		var tween = create_tween()
		tween.tween_property(victory_panel, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)
		await get_tree().create_timer(4.5).timeout
		var fade_tween = create_tween()
		fade_tween.tween_property(self, "modulate:a", 0.0, 1.5)
		await fade_tween.finished
		visible = false
