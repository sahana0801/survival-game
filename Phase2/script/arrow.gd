extends Area2D

# ==============================================================================
# BUG 2: "ARROW BẮN NGƯỢC" (Reverse Flight Archery)
# AI Story: AI bị nhầm dấu vector hướng, dùng `-Vector2.RIGHT` thay vì `Vector2.RIGHT`
# Result: Mũi tên bay ngược 180 độ về phía sau người bắn! 😂
# ==============================================================================

var speed: float = 350.0

func _ready():
	set_as_top_level(true)

func _process(delta):
	# 🐛 BUG: Trừ vector thay vì cộng -> bay giật lùi về phía sau!
	position -= (Vector2.RIGHT * speed).rotated(rotation) * delta

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(25)
		queue_free()
