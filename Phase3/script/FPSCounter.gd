extends Label

@onready var fps_panel = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var fps = Engine.get_frames_per_second()
	text = "FPS: " + str(fps)


func _input(_event):
	if Input.is_action_just_pressed("fps"):
		fps_panel.visible = !fps_panel.visible
