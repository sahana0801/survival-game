class_name Player extends CharacterBody2D

# Constants
const WALK_SPEED: float = 150.0
const SPRINT_SPEED: float = 240.0
const SPEED: float = 150.0
var is_sprinting: bool = false

# Signals
signal healthChanged
signal hungerChanged
signal thirstChanged
signal playerDied
signal weaponChanged(weapon_index: int)
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
var current_skin: int = 0
var mouse_loc_from_player: Vector2 = Vector2.ZERO

var max_health: int = 100
var current_health: int = 100
var max_hunger: int = 100
var current_hunger: int = 100
var max_thirst: int = 100
var current_thirst: int = 100
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
	# Connect all items that can be picked up
	PlayerStats.StickCollected.connect(collect_stick)
	PlayerStats.AppleCollected.connect(collect_apple)
	PlayerStats.WaterCollected.connect(collect_water)
	PlayerStats.SlimeCollected.connect(collect_slime)
	PlayerStats.HealthPotionCollected.connect(collect_health_potion)


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


func equip_weapon(weapon_type: int):
	if current_weapon == weapon_type:
		current_weapon = Weapon.NONE
	else:
		current_weapon = weapon_type
	bow_equiped = (current_weapon == Weapon.BOW)
	weaponChanged.emit(current_weapon)


func toggle_skin():
	current_skin = (current_skin + 1) % 2
	var skin_name = "Golden Hero" if current_skin == 1 else "Adventurer"
	if current_skin == 1:
		$AnimatedSprite2D.modulate = Color(1.15, 1.05, 0.85, 1.0)
	else:
		$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	Helpers.spawn_damage_number(global_position, skin_name, Color(0.3, 0.9, 1.0), true, "✦ ", " ✦")
	skinChanged.emit(skin_name)


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
	if current_weapon == Weapon.SWORD:
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
	
	if Input.is_action_just_pressed("bow"):
		equip_weapon(Weapon.BOW)
		
	if Input.is_action_just_pressed("sword"):
		equip_weapon(Weapon.SWORD)
		
	if Input.is_action_just_pressed("toggle_skin"):
		toggle_skin()
	
	var mouse_pos = get_global_mouse_position()
	$Marker2D.look_at(mouse_pos)
	
	# Bow Shoot
	if Input.is_action_just_pressed("left_mouse") and current_weapon == Weapon.BOW and bow_cooldown:
		arrow_audio.play()
		bow_cooldown = false
		
		# 🎯 PINPOINT LASER ARCHERY: Bắn thẳng tắp 100% theo hướng chuột
		var aim_dir = (mouse_pos - global_position).normalized()
		var arrow_instance = arrow.instantiate()
		arrow_instance.global_position = global_position + aim_dir * 12.0
		arrow_instance.rotation = aim_dir.angle()
		get_parent().add_child(arrow_instance)
		
		await get_tree().create_timer(0.35).timeout
		bow_cooldown = true
		
	# Melee Sword Slash
	elif Input.is_action_just_pressed("left_mouse") and current_weapon == Weapon.SWORD and sword_cooldown:
		sword_cooldown = false
		is_slashing = true
		
		# Play sword swing whoosh sound
		arrow_audio.pitch_scale = 0.6
		arrow_audio.play()
		
		var aim_dir = (mouse_pos - global_position).normalized()
		var slash = sword_slash_scene.instantiate()
		slash.global_position = global_position + aim_dir * 28.0
		slash.rotation = aim_dir.angle()
		get_parent().add_child(slash)
		
		await get_tree().create_timer(0.25).timeout
		arrow_audio.pitch_scale = 1.0
		is_slashing = false
		await get_tree().create_timer(0.1).timeout
		sword_cooldown = true
	
	if Input.is_action_just_pressed("inventory"):
		$CtrlInventoryStacked.visible = !$CtrlInventoryStacked.visible
	
	if Input.is_action_just_pressed("drink"):
		drink()
		
	if Input.is_action_just_pressed("eat"):
		eat()

	play_anim(direction)


func player():
	pass


func hurtByEnemy(_area: Area2D) -> void:
	if not is_alive or is_hurt:
		return
	current_health = max(0, current_health - 10)
	checkHealth()
	is_hurt = true
	PlayerStats.player_hit = true
	healthChanged.emit()
	
	# Floating Damage Number on Player (Red)
	Helpers.spawn_damage_number(global_position, 10, Color(0.95, 0.25, 0.25), false, "-")
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
	if not is_alive:
		return
	# Scale decay with activity (sprinting drains 15, walking drains 10, idle drains 5)
	var decay: int = 15 if is_sprinting else (10 if player_state == "walking" else 5)
	current_hunger = max(0, current_hunger - decay)
	hungerChanged.emit()
	if current_hunger <= 0:
		current_health = max(0, current_health - 10)
		checkHealth()
		healthChanged.emit()


func thirsty() -> void:
	if not is_alive:
		return
	# Scale decay with activity (sprinting drains 15, walking drains 10, idle drains 5)
	var decay: int = 15 if is_sprinting else (10 if player_state == "walking" else 5)
	current_thirst = max(0, current_thirst - decay)
	thirstChanged.emit()
	if current_thirst <= 0:
		current_health = max(0, current_health - 10)
		checkHealth()
		healthChanged.emit()


func _on_hunger_timer_timeout() -> void:
	if not is_alive:
		return
	hungry()
	$hungerTimer.start()


func _on_thirst_timer_timeout() -> void:
	if not is_alive:
		return
	thirsty()
	$thirstTimer.start()


func drink():
	if remove_item("water_potion"):
		current_thirst = min(max_thirst, current_thirst + 25)
		thirstChanged.emit()
		Helpers.spawn_damage_number(global_position, 25, Color(0.2, 0.75, 1.0), false, "+", " Water")


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


func remove_item(item_name: String) -> bool:
	if inventory_stacked.get_item_by_id(item_name) != null:
		var size = inventory_stacked.get_item_by_id(item_name).get_property("stack_size")
		if size >= 1:
			inventory_stacked.set_item_stack_size(inventory_stacked.get_item_by_id(item_name), size - inventory_stacked.get_prototype_stack_size(item_name))
			return true
		else:
			return false
	else:
		return false
