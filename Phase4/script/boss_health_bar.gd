class_name BossHealthBar extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var phase_label: Label = $VBoxContainer/PhaseLabel
@onready var health_bar: ProgressBar = $VBoxContainer/BarContainer/HealthBar
@onready var ghost_bar: ProgressBar = $VBoxContainer/BarContainer/GhostBar
@onready var victory_panel: PanelContainer = $VictoryPanel
@onready var vic_title: Label = get_node_or_null("VictoryPanel/VBox/VicTitle")
@onready var vic_sub: Label = get_node_or_null("VictoryPanel/VBox/VicSub")

var target_val: float = 1500.0
var ghost_val: float = 1500.0
var drain_delay_timer: float = 0.0
var current_boss_name: String = "VUA SLIME CỔ ĐẠI"


func _ready():
	visible = false
	if victory_panel != null:
		victory_panel.visible = false


func setup(max_hp: int, boss_name: String = "VUA SLIME CỔ ĐẠI"):
	current_boss_name = boss_name
	visible = true
	if title_label != null:
		title_label.text = "👑 " + boss_name + " 👑"
	if phase_label != null:
		phase_label.text = "GIAI ĐOẠN 1 / 3"
	if health_bar != null:
		health_bar.max_value = max_hp
		health_bar.value = max_hp
	if ghost_bar != null:
		ghost_bar.max_value = max_hp
		ghost_bar.value = max_hp
	target_val = max_hp
	ghost_val = max_hp
	_update_victory_labels()
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)


func _update_victory_labels():
	if vic_title == null:
		vic_title = get_node_or_null("VictoryPanel/VBox/VicTitle")
	if vic_sub == null:
		vic_sub = get_node_or_null("VictoryPanel/VBox/VicSub")
		
	if vic_title != null:
		vic_title.text = "🏆 CHIẾN THẮNG! %s ĐÃ BỊ ĐÁNH BẠI! 🏆" % current_boss_name.to_upper()
	if vic_sub != null:
		if "TỬ THẦN" in current_boss_name.to_upper() or "EXECUTIONER" in current_boss_name.to_upper():
			vic_sub.text = "Linh hồn u tối đã tan biến. Cổng trở về Route 1 đã mở!"
		else:
			vic_sub.text = "Vương quốc đã an toàn. Phần thưởng huyền thoại đang đón chờ!"


func update_health(current_hp: int, phase: int):
	if current_hp < target_val:
		drain_delay_timer = 0.35
		
	target_val = float(current_hp)
	health_bar.value = target_val
	
	var name_upper := current_boss_name.to_upper()
	if "SLIME" in name_upper:
		match phase:
			1:
				phase_label.text = "GIAI ĐOẠN 1 / 3 — SLIME HOÀNG GIA"
				phase_label.modulate = Color(0.9, 0.95, 1.0)
			2:
				phase_label.text = "🔥 GIAI ĐOẠN 2 / 3 — NỔI GIẬN CUỒNG NỘ 🔥"
				phase_label.modulate = Color(1.0, 0.35, 0.25)
			3:
				phase_label.text = "⚡ GIAI ĐOẠN 3 / 3 — TUYỆT VỌNG VŨ TRỤ ⚡"
				phase_label.modulate = Color(0.85, 0.35, 1.0)
	elif "TỬ THẦN" in name_upper or "EXECUTIONER" in name_upper:
		match phase:
			1:
				phase_label.text = "GIAI ĐOẠN 1 / 3 — LƯỠI HÁI HÀNH QUYẾT"
				phase_label.modulate = Color(0.9, 0.95, 1.0)
			2:
				phase_label.text = "☠ GIAI ĐOẠN 2 / 3 — GAI BÓNG TỐI & OÁN HỒN ☠"
				phase_label.modulate = Color(0.85, 0.3, 0.95)
			3:
				phase_label.text = "⚡ GIAI ĐOẠN 3 / 3 — CUỒNG NỘ HẮC ÁM ⚡"
				phase_label.modulate = Color(1.0, 0.2, 0.3)
	else:
		phase_label.text = "GIAI ĐOẠN %d / 3" % phase


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
	phase_label.text = "ĐÃ BỊ HẠ GỤC"
	_update_victory_labels()
			
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
