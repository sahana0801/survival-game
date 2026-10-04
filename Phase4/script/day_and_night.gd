extends Node2D

enum state { DAY, NIGHT }
var current_state = state.DAY
var change_state = false

var length_of_day: float = 180.0
var length_of_night: float = 120.0

@onready var night_sounds: AudioStreamPlayer = $NightSounds
@onready var day_sounds: AudioStreamPlayer = $DaySounds
@onready var canvas_modulate: CanvasModulate = get_node_or_null("CanvasModulate")
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

const DAY_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const NIGHT_COLOR = Color(0.20, 0.22, 0.32, 1.0)


func _ready():
	if not PlayerStats.RequestToggleDayNight.is_connected(_on_request_toggle_day_night):
		PlayerStats.RequestToggleDayNight.connect(_on_request_toggle_day_night)

	if PlayerStats.is_night:
		current_state = state.NIGHT
		if canvas_modulate != null:
			canvas_modulate.color = NIGHT_COLOR
		timer.wait_time = length_of_night
		timer.start()
		if day_sounds != null:
			day_sounds.stop()
		if night_sounds != null:
			night_sounds.play()
		PlayerStats.NightStarted.emit()
	else:
		current_state = state.DAY
		if canvas_modulate != null:
			canvas_modulate.color = DAY_COLOR
		timer.wait_time = length_of_day
		timer.start()
		if night_sounds != null:
			night_sounds.stop()
		if day_sounds != null:
			day_sounds.play()
		PlayerStats.DayStarted.emit()


func _on_timer_timeout():
	match current_state:
		state.DAY:
			current_state = state.NIGHT
		state.NIGHT:
			current_state = state.DAY
	change_state = true


func _process(_delta):
	if change_state:
		change_state = false
		if current_state == state.DAY:
			change_to_day()
		else:
			change_to_night()


func change_to_day():
	anim_player.play("night_to_day")
	timer.wait_time = length_of_day
	timer.start()
	if night_sounds != null:
		night_sounds.stop()
	if day_sounds != null:
		day_sounds.play()
	PlayerStats.changeDay()
	PlayerStats.is_night = false
	PlayerStats.DayStarted.emit()
	PlayerStats.send_message("Mặt trời mọc... Những bóng ma ẩn mình vào bóng tối.")


func change_to_night():
	anim_player.play("day_to_night")
	timer.wait_time = length_of_night
	timer.start()
	if day_sounds != null:
		day_sounds.stop()
	if night_sounds != null:
		night_sounds.play()
	PlayerStats.is_night = true
	PlayerStats.NightStarted.emit()
	PlayerStats.send_message("Màn đêm buông xuống! Oán hồn bóng tối thức giấc...")


func _on_request_toggle_day_night() -> void:
	if PlayerStats.is_night:
		force_night()
	else:
		force_day()


func force_night() -> void:
	current_state = state.NIGHT
	change_state = false
	if anim_player != null:
		anim_player.stop()
	if canvas_modulate != null:
		canvas_modulate.color = NIGHT_COLOR
	timer.wait_time = length_of_night
	timer.start()
	if day_sounds != null:
		day_sounds.stop()
	if night_sounds != null:
		night_sounds.play()
	PlayerStats.is_night = true
	PlayerStats.NightStarted.emit()
	PlayerStats.send_message("⚡ [DEV MODE] Đã chuyển tức thì sang BAN ĐÊM (Cổng Boss & Quái đêm kích hoạt)!")


func force_day() -> void:
	current_state = state.DAY
	change_state = false
	if anim_player != null:
		anim_player.stop()
	if canvas_modulate != null:
		canvas_modulate.color = DAY_COLOR
	timer.wait_time = length_of_day
	timer.start()
	if night_sounds != null:
		night_sounds.stop()
	if day_sounds != null:
		day_sounds.play()
	PlayerStats.changeDay()
	PlayerStats.is_night = false
	PlayerStats.DayStarted.emit()
	PlayerStats.send_message("⚡ [DEV MODE] Đã chuyển tức thì sang BAN NGÀY (Mặt trời chiếu sáng)!")
