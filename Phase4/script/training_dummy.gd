extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox

var original_scale: Vector2 = Vector2.ONE
var is_wobbling: bool = false

func _ready() -> void:
	original_scale = sprite.scale
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("sword_deal_damage") or area.has_method("arrow_deal_damage"):
		take_hit(area.global_position)

func take_hit(attacker_pos: Vector2) -> void:
	if is_wobbling:
		return
	is_wobbling = true
	
	# Determine wobble direction
	var dir = sign(global_position.x - attacker_pos.x)
	if dir == 0:
		dir = 1
		
	var tween = create_tween()
	tween.tween_property(sprite, "rotation_degrees", dir * 15.0, 0.08)
	tween.tween_property(sprite, "rotation_degrees", -dir * 10.0, 0.08)
	tween.tween_property(sprite, "rotation_degrees", dir * 5.0, 0.06)
	tween.tween_property(sprite, "rotation_degrees", 0.0, 0.06)
	tween.tween_callback(func(): is_wobbling = false)
