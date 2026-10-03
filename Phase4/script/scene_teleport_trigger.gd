extends Area2D
class_name SceneTeleportTrigger

@export_file("*.tscn") var target_scene: String = ""
@export var target_spawn_pos: Vector2 = Vector2.ZERO
@export var zone_name: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		if target_scene != "" and SceneManager != null:
			SceneManager.transition_to_scene(target_scene, target_spawn_pos, zone_name)
