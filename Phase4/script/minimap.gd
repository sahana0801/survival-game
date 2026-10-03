class_name MiniMap extends Control

@export var player: Player

# Tactical Map Configuration
var map_pixel_radius: float = 86.0
var world_view_radius: float = 460.0
var scale_factor: float = 0.187

@onready var sub_viewport_container: SubViewportContainer = $SubViewportContainer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport
@onready var minimap_camera: Camera2D = $SubViewportContainer/SubViewport/Camera2D
@onready var overlay: Control = $Overlay
@onready var coord_label: Label = $CoordLabel

# Tactical Objectives (matching CS/Valorant style A and B markers in reference)
var objective_a: Dictionary = {
	"label": "A",
	"name": "Swamp Waters",
	"world_pos": Vector2(-350.0, 480.0)
}

var objective_b: Dictionary = {
	"label": "B",
	"name": "Ancient Portal",
	"world_pos": Vector2(650.0, 200.0)
}


func _ready():
	scale_factor = map_pixel_radius / world_view_radius
	
	if minimap_camera != null:
		minimap_camera.zoom = Vector2(scale_factor, scale_factor)
	
	# Connect to world 2d after tree initializes
	await get_tree().process_frame
	_setup_viewport_world()


func _setup_viewport_world():
	if sub_viewport != null:
		var main_vp = get_viewport()
		if main_vp != null:
			sub_viewport.world_2d = main_vp.find_world_2d()


func _process(_delta: float):
	if player != null and is_instance_valid(player):
		if minimap_camera != null:
			minimap_camera.global_position = player.global_position
			
		if coord_label != null:
			coord_label.text = "X: %d  Y: %d" % [int(player.global_position.x), int(player.global_position.y)]
	
	if overlay != null:
		overlay.queue_redraw()


func draw_overlay(target: Control):
	var center = target.size * 0.5
	var font = get_theme_default_font()
	
	if player == null or !is_instance_valid(player):
		return
		
	var player_pos = player.global_position
	var mouse_pos = player.get_global_mouse_position()
	var look_dir = (mouse_pos - player_pos).normalized()
	if look_dir == Vector2.ZERO:
		look_dir = Vector2.DOWN
	
	# 1. Tactical Vision Cone (FOV Wedge)
	# Translucent chartreuse/light green illumination matching reference image
	var fov_radius = 42.0
	var half_angle = deg_to_rad(32.0)
	var cone_points = PackedVector2Array()
	cone_points.append(center)
	
	var num_arc_steps = 10
	for i in range(num_arc_steps + 1):
		var frac = float(i) / float(num_arc_steps)
		var angle = lerp(-half_angle, half_angle, frac)
		var p = center + look_dir.rotated(angle) * fov_radius
		cone_points.append(p)
		
	# Fill vision cone
	var cone_color = Color(0.72, 0.88, 0.40, 0.38)
	target.draw_colored_polygon(cone_points, cone_color)
	
	# Outer border of vision cone
	var cone_border_color = Color(0.85, 0.98, 0.50, 0.65)
	target.draw_polyline(cone_points, cone_border_color, 1.2)
	
	# 2. Regular Enemies Blips
	var tree = get_tree()
	if tree != null:
		var enemies = tree.get_nodes_in_group("enemy")
		for enemy in enemies:
			if !is_instance_valid(enemy) or enemy == player:
				continue
			if enemy.get("is_dead") == true:
				continue
			if enemy is ShadowWraith and !enemy.is_active_at_night:
				continue
			if enemy is SlimeKing:
				continue
				
			var offset = enemy.global_position - player_pos
			var dist = offset.length()
			
			if dist <= world_view_radius:
				var blip_pos = center + offset * scale_factor
				if (blip_pos - center).length() < (map_pixel_radius - 4.0):
					var col = Color(1.0, 0.28, 0.25, 0.95)
					var blip_size = 2.8
					if enemy is SwampFrog:
						col = Color(0.35, 0.95, 0.45, 0.95)
					elif enemy is ShadowWraith:
						col = Color(0.85, 0.40, 1.0, 0.95)
						blip_size = 3.2
					target.draw_circle(blip_pos, blip_size, col)
		
		# Boss Blip (if present, e.g. in Boss Arena)
		var bosses = tree.get_nodes_in_group("boss")
		for boss in bosses:
			if !is_instance_valid(boss) or boss.get("is_dead") == true:
				continue
			var offset = boss.global_position - player_pos
			var dist = offset.length()
			var boss_pos: Vector2
			var is_edge = false
			
			if dist <= world_view_radius:
				boss_pos = center + offset * scale_factor
				if (boss_pos - center).length() > (map_pixel_radius - 12.0):
					boss_pos = center + offset.normalized() * (map_pixel_radius - 12.0)
					is_edge = true
			else:
				boss_pos = center + offset.normalized() * (map_pixel_radius - 12.0)
				is_edge = true
				
			var pulse = (sin(Time.get_ticks_msec() * 0.008) + 1.0) * 0.5
			target.draw_circle(boss_pos, 7.0 + pulse * 2.5, Color(1.0, 0.2, 0.2, 0.4))
			target.draw_circle(boss_pos, 5.0, Color(1.0, 0.82, 0.2, 1.0))
			target.draw_circle(boss_pos, 2.5, Color(0.9, 0.1, 0.1, 1.0))
			if font != null:
				target.draw_string(font, boss_pos + Vector2(-12, -8), "BOSS", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(1.0, 0.85, 0.2, 1.0))

	# 3. Draw Tactical Objectives [A] and [B] (only if in overworld, or if relevant)
	var objectives = [objective_a, objective_b]
	for obj in objectives:
		_draw_tactical_objective(target, center, player_pos, obj, font)
	
	# 4. Player Blip (Crisp cyan dot with white center)
	target.draw_circle(center, 7.0, Color(0.25, 0.85, 1.0, 0.45))
	target.draw_circle(center, 4.5, Color(0.35, 0.95, 1.0, 1.0))
	target.draw_circle(center, 2.0, Color(1.0, 1.0, 1.0, 1.0))


func _draw_tactical_objective(target: Control, center: Vector2, player_pos: Vector2, obj: Dictionary, font: Font):
	var w_pos = obj["world_pos"] as Vector2
	var offset = w_pos - player_pos
	var dist = offset.length()
	
	var marker_pos: Vector2
	var max_r = map_pixel_radius - 14.0
	
	if dist * scale_factor <= max_r:
		marker_pos = center + offset * scale_factor
	else:
		marker_pos = center + offset.normalized() * max_r
		
	# Draw square badge (Tactical CS/Valorant style)
	var badge_size = Vector2(17.0, 17.0)
	var badge_rect = Rect2(marker_pos - badge_size * 0.5, badge_size)
	
	# Badge shadow & background
	target.draw_rect(badge_rect, Color(0.24, 0.08, 0.08, 0.92))
	# Reddish-orange outline
	target.draw_rect(badge_rect, Color(0.88, 0.32, 0.18, 0.95), false, 1.5)
	
	# Bold yellow/gold letter
	if font != null:
		var letter = obj["label"]
		target.draw_string(font, marker_pos + Vector2(-4.5, 5.0), letter, HORIZONTAL_ALIGNMENT_CENTER, -1, 13, Color(1.0, 0.82, 0.0, 1.0))
