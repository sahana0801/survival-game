extends StaticBody2D

enum state { DAY, NIGHT }
var current_state = state.DAY
var change_state = false

var length_of_day = 120
var length_of_night = 60

@onready var night_sounds = $NightSounds
@onready var day_sounds = $DaySounds


func _ready():
	if current_state == state.DAY:
		$ColorRect.color.a = 0
		day_sounds.play()
	else:
		$ColorRect.color.a = 225
		night_sounds.play()


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


func change_to_night():
	$AnimationPlayer.play("day_to_night")
	$Timer.wait_time = length_of_night
	$Timer.start()
	night_sounds.play()
