class_name Player extends CharacterBody2D

# Constants
const WALK_SPEED: float = 150.0
const SPRINT_SPEED: float = 240.0
const SPEED: float = 150.0
var is_sprinting: bool = false

# Signals
signal healthChanged
signal hungerChanged
signal manaChanged
signal thirstChanged
signal playerDied
signal weaponChanged(weapon_index: int)
@warning_ignore("unused_signal")
signal skinChanged(skin_name: String)

enum Weapon { NONE = 0, BOW = 1, SWORD = 2 }
var current_weapon = Weapon.NONE

var player_state: String = "idle"
var is_hurt: bool = false
var is_alive: bool = true
var bow_equiped: bool = false
var bow_cooldown: bool = true
var sword_cooldown: bool = true
var is_slashing: bool = false

var arrow: PackedScene = preload("res://scene/arrow.tscn")
var sword_slash_scene: PackedScene = preload("res://scene/sword_slash.tscn")
var character_type: int = PlayerStats.CharacterType.KNIGHT
var knight_frames: SpriteFrames = null
var archer_frames: SpriteFrames = null
var bow_sprite: Sprite2D = null
var current_skin: int = 0
var mouse_loc_from_player: Vector2 = Vector2.ZERO

var max_health: int = 100
var current_health: int = 100
var max_hunger: int = 100
var current_hunger: int = 100
var max_mana: int = 100
var current_mana: int = 100

# Tương thích ngược với các script cũ còn tham chiếu thirst
var max_thirst: int:
	get: return max_mana
	set(val): max_mana = val
var current_thirst: int:
	get: return current_mana
	set(val): current_mana = val
@onready var hurtBox: Area2D = $hurtBox
@onready var hurtTimer: Timer = $hurtBox/hurtTimer

#Inventory
@onready var inventory_stacked = $InventoryStacked
@onready var ctrl_inventory_stacked = $CtrlInventoryStacked

# Audio
@onready var arrow_audio = $ArrowAudio
@onready var player_dying = $PlayerDying
@onready var pick_item = $PickItem

# Camera & Game Feel
@onready var camera = $Camera2D
var target_zoom: Vector2 = Vector2(2.6, 2.6)
const MIN_ZOOM: float = 1.6
const MAX_ZOOM: float = 4.0
const ZOOM_STEP: float = 0.25
var shake_intensity: float = 0.0
var shake_timer: float = 0.0


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom.x = clamp(target_zoom.x + ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
			target_zoom.y = clamp(target_zoom.y + ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom.x = clamp(target_zoom.x - ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
			target_zoom.y = clamp(target_zoom.y - ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if is_alive and not _is_mouse_over_ui():
				perform_attack()


func _is_mouse_over_ui() -> bool:
	var hovered = get_viewport().gui_get_hovered_control()
	if hovered != null and hovered.is_visible_in_tree():
		return true
	var mouse_screen_pos = get_viewport().get_mouse_position()
	for grp in ["inventory_window", "pause_menu"]:
		var node = get_tree().get_first_node_in_group(grp) as Control
		if node != null and node.is_visible_in_tree():
			if node.get_global_rect().has_point(mouse_screen_pos):
				return true
	return false


func perform_attack() -> void:
	if not is_alive:
		return
	var mouse_pos = get_global_mouse_position()
	
	# Bow Shoot
	if current_weapon == Weapon.BOW and bow_cooldown:
		arrow_audio.play()
		bow_cooldown = false
		
		# Giật lùi cung (Juicy recoil feedback)
		if bow_sprite != null and is_instance_valid(bow_sprite):
			var tw = create_tween()
			bow_sprite.position = Vector2(8, 0)
			tw.tween_property(bow_sprite, "position", Vector2(14, 0), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# 🎯 PINPOINT LASER ARCHERY: Bắn thẳng tắp 100% theo hướng chuột
		var aim_dir = (mouse_pos - global_position).normalized()
		var arrow_instance = arrow.instantiate()
		arrow_instance.global_position = global_position + aim_dir * 14.0
		arrow_instance.rotation = aim_dir.angle()
		get_parent().add_child(arrow_instance)
		
		await get_tree().create_timer(0.30).timeout
		bow_cooldown = true
		
	# Melee Sword Slash (Chém kiếm cận chiến)
	elif current_weapon == Weapon.SWORD and sword_cooldown:
		sword_cooldown = false
		is_slashing = true
		
		# Âm thanh vung kiếm sắc bén (Crisp sword swing whoosh)
		arrow_audio.pitch_scale = randf_range(1.12, 1.28)
		arrow_audio.play()
		
		var aim_dir = (mouse_pos - global_position).normalized()
		var slash = sword_slash_scene.instantiate()
		slash.global_position = global_position + aim_dir * 14.0
		slash.rotation = aim_dir.angle()
		get_parent().add_child(slash)
		
		await get_tree().create_timer(0.20).timeout
		arrow_audio.pitch_scale = 1.0
		is_slashing = false
		await get_tree().create_timer(0.06).timeout
		sword_cooldown = true


func _process(delta):
	if camera != null:
		camera.zoom = camera.zoom.lerp(target_zoom, delta * 8.0)
		if shake_timer > 0:
			shake_timer -= delta
			camera.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		else:
			camera.offset = Vector2.ZERO


func screen_shake(intensity: float = 3.0, duration: float = 0.15):
	shake_intensity = intensity
	shake_timer = duration


func _physics_process(_delta):
	if is_alive:
		handleInput()
		move_and_slide()
	
		if !is_hurt:
			for area in hurtBox.get_overlapping_areas():
				if area.name == "hitbox":
					hurtByEnemy(area)


func _ready():
	_setup_sword_idle_animations()
	_setup_archer_assets()
	# Connect all items that can be picked up
	PlayerStats.StickCollected.connect(collect_stick)
	PlayerStats.AppleCollected.connect(collect_apple)
	PlayerStats.WaterCollected.connect(collect_water)
	PlayerStats.SlimeCollected.connect(collect_slime)
	PlayerStats.HealthPotionCollected.connect(collect_health_potion)
	if not PlayerStats.ShootingChanged.is_connected(_on_weapon_tier_changed):
		PlayerStats.ShootingChanged.connect(_on_weapon_tier_changed)
	if has_node("thirstTimer"):
		$thirstTimer.wait_time = 1.0
		$thirstTimer.start()
	call_deferred("_setup_starter_inventory")
	call_deferred("apply_character_type", PlayerStats.active_character)


func _setup_sword_idle_animations() -> void:
	var spr: AnimatedSprite2D = $AnimatedSprite2D
	if spr == null or spr.sprite_frames == null:
		return
	var tex = load("res://art/fantasy/Art/Characters/Main Character/Character_Idle_Sword.png") as Texture2D
	if tex == null:
		return
	var frames: SpriteFrames = spr.sprite_frames
	# Row 0: West, Row 1: East, Row 2: North, Row 3: South
	var row_map := {
		0: "w-idle-sword",
		1: "e-idle-sword",
		2: "n-idle-sword",
		3: "s-idle-sword"
	}
	for row in row_map:
		var anim_name: String = row_map[row]
		if not frames.has_animation(anim_name):
			frames.add_animation(anim_name)
			frames.set_animation_speed(anim_name, 5.0)
			frames.set_animation_loop(anim_name, true)
			for col in range(4):
				var atlas := AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(col * 40, row * 48, 40, 48)
				frames.add_frame(anim_name, atlas)


func collect_stick():
	#print("Stick collected")
	collect_item("stick")


func collect_slime():
	#print("Slime collected")
	collect_item("slime")


func collect_water():
	#print("Water collected")
	collect_item("water_potion")


func collect_apple():
	#print("Apple collected")
	collect_item("apple")


func collect_health_potion():
	#print("Health potion collected")
	collect_item("health_potion")


func collect_item(item_name: String):
	var newitem = get_item(item_name)
	if inventory_stacked.can_add_item(newitem):
		inventory_stacked.add_item_automerge(newitem)
		pick_item.play()


func get_item(item_name: String) -> InventoryItem:
	var newitem = InventoryItem.new()
	newitem.protoset = inventory_stacked.item_protoset
	newitem.prototype_id = item_name
	return newitem


func _setup_archer_assets() -> void:
	if knight_frames == null and $AnimatedSprite2D != null:
		knight_frames = $AnimatedSprite2D.sprite_frames

	var girl_path = "res://art/SimpleCharacter/Girl-Sheet.png"
	var girl_tex: Texture2D = null
	if ResourceLoader.exists(girl_path):
		girl_tex = load(girl_path)
	if girl_tex == null:
		var abs_path = ProjectSettings.globalize_path(girl_path)
		if FileAccess.file_exists(girl_path):
			var img = Image.load_from_file(abs_path)
			if img != null:
				girl_tex = ImageTexture.create_from_image(img)

	if girl_tex != null:
		archer_frames = SpriteFrames.new()
		var make_f = func(idx: int) -> AtlasTexture:
			var at = AtlasTexture.new()
			at.atlas = girl_tex
			at.region = Rect2(idx * 24, 0, 24, 24)
			return at

		var add_a = func(anim_name: StringName, start_idx: int, count: int, fps: float, loop: bool):
			if not archer_frames.has_animation(anim_name):
				archer_frames.add_animation(anim_name)
			archer_frames.set_animation_speed(anim_name, fps)
			archer_frames.set_animation_loop(anim_name, loop)
			for i in range(count):
				archer_frames.add_frame(anim_name, make_f.call(start_idx + i))

		# Idles
		add_a.call(&"idle", 0, 4, 5.0, true)
		add_a.call(&"s-idle", 0, 4, 5.0, true)
		add_a.call(&"s-idle-sword", 0, 4, 5.0, true)
		add_a.call(&"w-idle", 4, 4, 5.0, true)
		add_a.call(&"w-idle-sword", 4, 4, 5.0, true)
		add_a.call(&"e-idle", 8, 4, 5.0, true)
		add_a.call(&"e-idle-sword", 8, 4, 5.0, true)
		add_a.call(&"n-idle", 12, 4, 5.0, true)
		add_a.call(&"n-idle-sword", 12, 4, 5.0, true)

		# Walks
		add_a.call(&"s-walk", 16, 6, 8.0, true)
		add_a.call(&"sw-walk", 16, 6, 8.0, true)
		add_a.call(&"se-walk", 16, 6, 8.0, true)
		add_a.call(&"w-walk", 22, 6, 8.0, true)
		add_a.call(&"nw-walk", 22, 6, 8.0, true)
		add_a.call(&"e-walk", 28, 6, 8.0, true)
		add_a.call(&"ne-walk", 28, 6, 8.0, true)
		add_a.call(&"n-walk", 34, 6, 8.0, true)

		# Die & Death
		add_a.call(&"die", 40, 4, 6.0, false)
		add_a.call(&"death", 40, 4, 6.0, false)

		# Attacks
		add_a.call(&"s-attack", 16, 6, 12.0, false)
		add_a.call(&"sw-attack", 16, 6, 12.0, false)
		add_a.call(&"se-attack", 16, 6, 12.0, false)
		add_a.call(&"w-attack", 22, 6, 12.0, false)
		add_a.call(&"nw-attack", 22, 6, 12.0, false)
		add_a.call(&"e-attack", 28, 6, 12.0, false)
		add_a.call(&"ne-attack", 28, 6, 12.0, false)
		add_a.call(&"n-attack", 34, 6, 12.0, false)

	# 3. Setup in-hand BowSprite under Marker2D (Tier-based Bow)
	if has_node("Marker2D"):
		bow_sprite = $Marker2D.get_node_or_null("BowSprite") as Sprite2D
		if bow_sprite == null:
			bow_sprite = Sprite2D.new()
			bow_sprite.name = "BowSprite"
			$Marker2D.add_child(bow_sprite)
		bow_sprite.rotation = deg_to_rad(-45.0)
		bow_sprite.position = Vector2(14, 0)
		bow_sprite.scale = Vector2(0.85, 0.85)
		bow_sprite.visible = false
		_update_bow_visual()


func _update_bow_visual() -> void:
	if bow_sprite == null:
		return
	if character_type == PlayerStats.CharacterType.ARCHER and current_weapon == Weapon.BOW:
		bow_sprite.visible = true
		var tex_path = PlayerStats.get_bow_texture_path()
		if ResourceLoader.exists(tex_path):
			bow_sprite.texture = load(tex_path)
	else:
		bow_sprite.visible = false


func _on_weapon_tier_changed() -> void:
	_update_bow_visual()


func apply_character_type(char_type: int) -> void:
	character_type = char_type
	PlayerStats.set_active_character(char_type)

	var spr: AnimatedSprite2D = $AnimatedSprite2D
	if char_type == PlayerStats.CharacterType.KNIGHT:
		if spr != null and knight_frames != null:
			spr.sprite_frames = knight_frames
			spr.scale = Vector2(2.0, 2.0)
			spr.offset = Vector2(0, -16)
		current_weapon = Weapon.SWORD
		bow_equiped = false
	else:
		if spr != null and archer_frames != null:
			spr.sprite_frames = archer_frames
			spr.scale = Vector2(2.4, 2.4)
			spr.offset = Vector2(0, -10)
		current_weapon = Weapon.BOW
		bow_equiped = true

	_update_bow_visual()
	weaponChanged.emit(current_weapon)


func equip_weapon(weapon_type: int):
	if character_type == PlayerStats.CharacterType.KNIGHT:
		if weapon_type == Weapon.BOW:
			PlayerStats.send_message("⚔️ Hiệp Sĩ chỉ chuyên dùng Kiếm! Hãy đổi sang Cung Thủ để dùng Cung.")
			return
		current_weapon = Weapon.SWORD if current_weapon != Weapon.SWORD else Weapon.NONE
	else: # ARCHER
		if weapon_type == Weapon.SWORD:
			PlayerStats.send_message("🏹 Cung Thủ chỉ chuyên dùng Cung! Hãy đổi sang Hiệp Sĩ để dùng Kiếm.")
			return
		current_weapon = Weapon.BOW if current_weapon != Weapon.BOW else Weapon.NONE

	bow_equiped = (current_weapon == Weapon.BOW)
	_update_bow_visual()
	weaponChanged.emit(current_weapon)


func _setup_starter_inventory() -> void:
	if inventory_stacked != null and inventory_stacked.get_item_count() == 0:
		add_starter_item("health_potion", 2)
		add_starter_item("water_potion", 2)
		add_starter_item("apple", 2)


func add_starter_item(item_name: String, count: int = 1) -> void:
	for i in count:
		var newitem = get_item(item_name)
		if inventory_stacked.can_add_item(newitem):
			inventory_stacked.add_item_automerge(newitem)


func toggle_skin():
	pass


func get_attack_anim() -> String:
	var deg: float = rad_to_deg(mouse_loc_from_player.angle())
	if deg >= -22.5 and deg < 22.5:
		return "e-attack"
	elif deg >= 22.5 and deg < 67.5:
		return "se-attack"
	elif deg >= 67.5 and deg < 112.5:
		return "s-attack"
	elif deg >= 112.5 and deg < 157.5:
		return "sw-attack"
	elif deg >= 157.5 or deg < -157.5:
		return "w-attack"
	elif deg >= -157.5 and deg < -112.5:
		return "nw-attack"
	elif deg >= -112.5 and deg < -67.5:
		return "n-attack"
	elif deg >= -67.5 and deg < -22.5:
		return "ne-attack"
	return "s-attack"


func get_walk_anim(dir: Vector2) -> String:
	var deg: float = rad_to_deg(dir.angle())
	if deg >= -22.5 and deg < 22.5:
		return "e-walk"
	elif deg >= 22.5 and deg < 67.5:
		return "se-walk"
	elif deg >= 67.5 and deg < 112.5:
		return "s-walk"
	elif deg >= 112.5 and deg < 157.5:
		return "sw-walk"
	elif deg >= 157.5 or deg < -157.5:
		return "w-walk"
	elif deg >= -157.5 and deg < -112.5:
		return "nw-walk"
	elif deg >= -112.5 and deg < -67.5:
		return "n-walk"
	elif deg >= -67.5 and deg < -22.5:
		return "ne-walk"
	return "s-walk"


func get_sword_idle_anim() -> String:
	var deg: float = rad_to_deg(mouse_loc_from_player.angle())
	if deg >= -45.0 and deg < 45.0:
		return "e-idle-sword"
	elif deg >= 45.0 and deg < 135.0:
		return "s-idle-sword"
	elif deg >= 135.0 or deg < -135.0:
		return "w-idle-sword"
	else:
		return "n-idle-sword"


func play_anim(dir: Vector2) -> void:
	var spr: AnimatedSprite2D = $AnimatedSprite2D
	
	# Attack slash animation takes highest priority
	if is_slashing:
		spr.speed_scale = 1.0
		spr.play(get_attack_anim())
		return
		
	# Moving: adjust playback speed if sprinting
	if player_state == "walking":
		if is_sprinting:
			spr.speed_scale = 1.6
		else:
			spr.speed_scale = 1.0
		spr.play(get_walk_anim(dir))
		return
		
	# Idle state
	spr.speed_scale = 1.0
	if character_type == PlayerStats.CharacterType.ARCHER:
		var deg: float = rad_to_deg(mouse_loc_from_player.angle())
		var a_idle := "s-idle"
		if deg >= -45.0 and deg < 45.0:
			a_idle = "e-idle"
		elif deg >= 45.0 and deg < 135.0:
			a_idle = "s-idle"
		elif deg >= 135.0 or deg < -135.0:
			a_idle = "w-idle"
		else:
			a_idle = "n-idle"
		if spr.animation != a_idle or !spr.is_playing():
			spr.play(a_idle)
	elif current_weapon == Weapon.SWORD:
		var sword_idle: String = get_sword_idle_anim()
		if spr.animation != sword_idle or !spr.is_playing():
			spr.play(sword_idle)
	else:
		if spr.animation != "idle" or !spr.is_playing():
			spr.play("idle")


func handleInput():
	mouse_loc_from_player = get_global_mouse_position() - global_position
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.is_zero_approx():
		player_state = "idle"
		is_sprinting = false
		velocity = Vector2.ZERO
	else:
		player_state = "walking"
		is_sprinting = Input.is_action_pressed("sprint") or Input.is_key_pressed(KEY_SHIFT)
		var current_speed: float = SPRINT_SPEED if is_sprinting else WALK_SPEED
		velocity = direction * current_speed
	
	
	var mouse_pos = get_global_mouse_position()
	$Marker2D.look_at(mouse_pos)
	
	
	if Input.is_action_just_pressed("inventory"):
		var inv_win = get_tree().get_first_node_in_group("inventory_window")
		if inv_win != null:
			inv_win.visible = !inv_win.visible
			if inv_win.visible and inv_win.has_method("refresh_slots"):
				inv_win.refresh_slots()
		else:
			$CtrlInventoryStacked.visible = !$CtrlInventoryStacked.visible
	

	play_anim(direction)


func player():
	pass


func hurtByEnemy(_source: Node = null, damage_amount: int = 10) -> void:
	if not is_alive or is_hurt:
		return
	current_health = max(0, current_health - damage_amount)
	checkHealth()
	is_hurt = true
	PlayerStats.player_hit = true
	healthChanged.emit()
	
	# Floating Damage Number on Player (Red)
	Helpers.spawn_damage_number(global_position, damage_amount, Color(0.95, 0.25, 0.25), false, "-")
	screen_shake(4.5, 0.18)
	
	hurtTimer.start(1.0)
	await hurtTimer.timeout
	is_hurt = false
	PlayerStats.player_hit = false


func checkHealth() -> void:
	if current_health > max_health:
		current_health = max_health
	if current_health < 30:
		PlayerStats.player_hit = true
	if current_health <= 0 and is_alive:
		is_alive = false
		player_dying.play()
		current_health = 0
		if has_node("hungerTimer"):
			$hungerTimer.stop()
		if has_node("thirstTimer"):
			$thirstTimer.stop()
		if ctrl_inventory_stacked.visible:
			ctrl_inventory_stacked.visible = false
		$AnimatedSprite2D.play("death")
		hurtTimer.start(2)
		await hurtTimer.timeout
		playerDied.emit()


func hungry() -> void:
	# Hunger mechanic removed
	pass


func regen_mana(amount: int = 2) -> void:
	if not is_alive or current_mana >= max_mana:
		return
	current_mana = min(max_mana, current_mana + amount)
	manaChanged.emit()
	thirstChanged.emit()


func thirsty() -> void:
	# Đã thay thế bằng cơ chế hồi phục mana tự nhiên
	regen_mana(2)


func _on_hunger_timer_timeout() -> void:
	pass


func _on_thirst_timer_timeout() -> void:
	if not is_alive:
		return
	# Tự động hồi phục Mana mỗi giây (+2 MP)
	regen_mana(2)
	if has_node("thirstTimer"):
		$thirstTimer.wait_time = 1.0
		$thirstTimer.start()


func drink():
	use_mana_potion()


func use_mana_potion():
	if remove_item("water_potion"):
		current_mana = min(max_mana, current_mana + 30)
		manaChanged.emit()
		thirstChanged.emit()
		Helpers.spawn_damage_number(global_position, 30, Color(0.2, 0.75, 1.0), false, "+", " MP")


func eat():
	if remove_item("apple"):
		current_health = min(max_health, current_health + 15)
		current_hunger = min(max_hunger, current_hunger + 25)
		checkHealth()
		healthChanged.emit()
		hungerChanged.emit()
		Helpers.spawn_damage_number(global_position, 15, Color(0.3, 0.95, 0.4), false, "+", " HP")


func drink_health_potion():
	if current_health < max_health and remove_item("health_potion"):
		current_health = min(max_health, current_health + 40)
		checkHealth()
		healthChanged.emit()
		Helpers.spawn_damage_number(global_position, 40, Color(0.2, 1.0, 0.4), true, "+", " HP")


func remove_item(item_name: String, amount: int = 1) -> bool:
	if inventory_stacked == null:
		return false
	var item = inventory_stacked.get_item_by_id(item_name)
	if item == null or not is_instance_valid(item):
		return false
	var cur_stack: int = int(item.get_property("stack_size", 1))
	if cur_stack > amount:
		InventoryStacked.set_item_stack_size(item, cur_stack - amount)
	else:
		if inventory_stacked.has_item(item):
			inventory_stacked.remove_item(item)
		item.queue_free()
	return true
