extends Node
class_name NSceneManager

@export var Scenes : Dictionary = {
	"Menu": "res://scene/main_menu.tscn",
	"Credits": "res://scene/credits.tscn",
	"World 1": "res://scene/world.tscn",
	"Route 1": "res://scene/route_1_world.tscn",
	"Executioner Arena": "res://scene/executioner_arena.tscn"
}

var m_CurrentSceneAlias : String = ""

# Persistent player data across scene transitions
var saved_inventory_data: Dictionary = {}
var saved_health: int = -1
var saved_weapon: int = -1

# Transition UI
var transition_layer: CanvasLayer = null
var fade_rect: ColorRect = null
var zone_label: Label = null
var is_transitioning: bool = false


func _ready() -> void:
	var mainScene : String = ProjectSettings.get_setting("application/run/main_scene")
	m_CurrentSceneAlias = Scenes.find_key(mainScene)
	_setup_transition_ui()


func _setup_transition_ui() -> void:
	transition_layer = CanvasLayer.new()
	transition_layer.layer = 128
	add_child(transition_layer)
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_layer.add_child(fade_rect)
	
	zone_label = Label.new()
	zone_label.set_anchors_preset(Control.PRESET_CENTER)
	zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	zone_label.modulate = Color(1, 1, 1, 0)
	zone_label.add_theme_font_size_override("font_size", 32)
	transition_layer.add_child(zone_label)


func transition_to_scene(scene_path: String, spawn_pos: Vector2 = Vector2.INF, zone_name: String = "") -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	# Save current player stats & inventory before leaving
	_save_player_state()
	
	# Block input during transition
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if zone_name != "":
		zone_label.text = zone_name
	
	# 1. Fade to Black
	var tween = create_tween().set_parallel(true)
	tween.tween_property(fade_rect, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if zone_name != "":
		tween.tween_property(zone_label, "modulate:a", 1.0, 0.35)
	await tween.finished
	
	# Small pause for dramatic effect
	await get_tree().create_timer(0.15).timeout
	
	# 2. Change Scene
	get_tree().change_scene_to_file(scene_path)
	
	# Wait for the new scene to be fully loaded into tree
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 3. Restore Player State & Position
	var current_scene = get_tree().current_scene
	if current_scene != null:
		var player = current_scene.get_node_or_null("Player")
		if player != null:
			if spawn_pos != Vector2.INF:
				player.global_position = spawn_pos
			_restore_player_state(player)
	
	# 4. Fade back in
	var tween_in = create_tween().set_parallel(true)
	tween_in.tween_property(fade_rect, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if zone_name != "":
		tween_in.tween_property(zone_label, "modulate:a", 0.0, 0.3)
	await tween_in.finished
	
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false


func _save_player_state() -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	var player = current_scene.get_node_or_null("Player")
	if player != null:
		saved_health = player.current_health
		saved_weapon = player.current_weapon
		var inv = player.get_node_or_null("InventoryStacked")
		if inv != null and inv.has_method("serialize"):
			saved_inventory_data = inv.serialize()


func _restore_player_state(player: Node2D) -> void:
	if player == null:
		return
	if saved_health > 0:
		player.current_health = saved_health
		if player.has_signal("healthChanged"):
			player.healthChanged.emit()
	if saved_weapon >= 0:
		player.equip_weapon(saved_weapon)
	
	if not saved_inventory_data.is_empty():
		var inv = player.get_node_or_null("InventoryStacked")
		if inv != null and inv.has_method("deserialize"):
			inv.deserialize(saved_inventory_data)


func SwitchScene(sceneAlias : String) -> void:
	if Scenes.has(sceneAlias):
		transition_to_scene(Scenes[sceneAlias])


func RestartScene() -> void:
	get_tree().reload_current_scene()


func QuitGame() -> void:
	get_tree().quit()


func AddScene(sceneAlias : String, scenePath : String) -> void:
	Scenes[sceneAlias] = scenePath


func RemoveScene(sceneAlias : String) -> void:
	Scenes.erase(sceneAlias)


func GetSceneCount() -> int:
	return Scenes.size()


func GetCurrentSceneAlias() -> String:
	return m_CurrentSceneAlias
