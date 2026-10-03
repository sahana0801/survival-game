class_name FloatingText extends Marker2D

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 240.0
var lifetime: float = 0.65
var elapsed: float = 0.0

@onready var label: Label = $Label


func _ready():
	velocity = Vector2(randf_range(-35.0, 35.0), randf_range(-105.0, -135.0))


func setup(value, color: Color = Color.WHITE, is_crit: bool = false, prefix: String = "", suffix: String = ""):
	if label == null:
		await ready
	
	var text_str = prefix + str(value) + suffix
	label.text = text_str
	label.modulate = color
	
	if is_crit:
		scale = Vector2(1.35, 1.35)
		label.text = "CHÍ MẠNG! " + text_str
		label.modulate = Color(1.0, 0.35, 0.1) # Bright Fiery Orange-Red
		velocity.y = -155.0
	else:
		scale = Vector2(1.0, 1.0)


func _process(delta):
	elapsed += delta
	velocity.y += gravity * delta
	position += velocity * delta
	
	# Scale animation bounce
	if elapsed < 0.15:
		scale = scale.move_toward(Vector2.ONE * 1.15, delta * 3.0)
	else:
		scale = scale.move_toward(Vector2.ONE, delta * 2.0)
		
	# Fade out near end of lifetime
	if elapsed > (lifetime * 0.45):
		var fade_t = (elapsed - lifetime * 0.45) / (lifetime * 0.55)
		modulate.a = clamp(1.0 - fade_t, 0.0, 1.0)
		
	if elapsed >= lifetime:
		queue_free()
