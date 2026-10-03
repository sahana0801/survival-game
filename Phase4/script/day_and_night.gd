extends Node2D

enum state { DAY, NIGHT }
var current_state = state.DAY
var change_state = false

var length_of_day = 240.0
var length_of_night = 60.0

@onready var night_sounds = $NightSounds
@onready var day_sounds = $DaySounds
@onready var canvas_modulate = get_node_or_null("CanvasModulate")

const DAY_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const NIGHT_COLOR = Color(0.20, 0.22, 0.32, 1.0)


func _ready():
	if current_state == state.DAY:
		if canvas_modulate != null:
			canvas_modulate.color = DAY_COLOR
		$Timer.wait_time = length_of_day
		$Timer.start()
		day_sounds.play()
		PlayerStats.is_night = false
		PlayerStats.DayStarted.emit()
	else:
		if canvas_modulate != null:
			canvas_modulate.color = NIGHT_COLOR
		$Timer.wait_time = length_of_night
		$Timer.start()
		night_sounds.play()
		PlayerStats.is_night = true
		PlayerStats.NightStarted.emit()


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
	$AnimationPlayer.play("night_to_day")
	$Timer.wait_time = length_of_day
	$Timer.start()
	day_sounds.play()
	PlayerStats.changeDay()
	PlayerStats.is_night = false
	PlayerStats.DayStarted.emit()
	PlayerStats.send_message("Mặt trời mọc... Những bóng ma ẩn mình vào bóng tối.")


func change_to_night():
	$AnimationPlayer.play("day_to_night")
	$Timer.wait_time = length_of_night
	$Timer.start()
	night_sounds.play()
	PlayerStats.is_night = true
	PlayerStats.NightStarted.emit()
	PlayerStats.send_message("Màn đêm buông xuống! Oán hồn bóng tối thức giấc...")
