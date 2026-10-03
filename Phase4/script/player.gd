class_name Player extends CharacterBody2D

# Constants
const SPEED = 150

# Signals
signal healthChanged
signal hungerChanged
signal thirstChanged
signal playerDied
signal weaponChanged(weapon_index: int)
signal skinChanged(skin_name: String)

enum Weapon { NONE = 0, BOW = 1, SWORD = 2 }
var current_weapon = Weapon.NONE

var player_state
@onready var is_hurt = false
@onready var is_alive = true
var bow_equiped = false
var bow_cooldown = true
var sword_cooldown = true
var is_slashing = false

var arrow = preload("res://scene/arrow.tscn")
var sword_slash_scene = preload("res://scene/sword_slash.tscn")
var skin_green = preload("res://art/character/survivalgame-player-green.png")
var skin_red = preload("res://art/character/Human-Worker-Red.png")
var current_skin = 0
var mouse_loc_from_player = null

@onready var max_health = 100
@onready var current_health = max_health
@onready var max_hunger = 100
@onready var current_hunger = max_hunger
@onready var max_thirst = 100
@onready var current_thirst = max_thirst
@onready var hurtBox = $hurtBox
@onready var hurtTimer = $hurtBox/hurtTimer

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
	# Connect all items that can be picked up
	PlayerStats.StickCollected.connect(collect_stick)
	PlayerStats.AppleCollected.connect(collect_apple)
	PlayerStats.WaterCollected.connect(collect_water)
	PlayerStats.SlimeCollected.connect(collect_slime)
	PlayerStats.HealthPotionCollected.connect(collect_health_potion)


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
	var m = mouse_loc_from_player
	if m.x >= -25 and m.x <= 25 and m.y < 0:
		return "n-attack"
	elif m.y >= -25 and m.y <= 25 and m.x > 0:
		return "e-attack"
	elif m.x >= -25 and m.x <= 25 and m.y > 0:
		return "s-attack"
	elif m.y >= -25 and m.y <= 25 and m.x < 0:
		return "w-attack"
	elif m.x >= 25 and m.y <= -25:
		return "ne-attack"
	elif m.x >= 0.5 and m.y >= 25:
		return "se-attack"
	elif m.x <= -0.5 and m.y >= 25:
		return "sw-attack"
	elif m.x <= -25 and m.y <= -25:
		return "nw-attack"
	return "s-attack"


func play_anim(dir):
	var sword_pose = current_weapon == Weapon.SWORD or is_slashing
	if !sword_pose:
		if player_state == "idle":
			$AnimatedSprite2D.play("idle")
		if player_state == "walking":
			if dir.y == -1:
				$AnimatedSprite2D.play("n-walk")
			elif dir.y == 1:
				$AnimatedSprite2D.play("s-walk")
			if dir.x == -1:
				$AnimatedSprite2D.play("w-walk")
			elif  dir.x == 1:
				$AnimatedSprite2D.play("e-walk")
			
			if dir.x > 0.5 and dir.y < -0.5:
				$AnimatedSprite2D.play("ne-walk")
			if dir.x > 0.5 and dir.y > 0.5:
				$AnimatedSprite2D.play("se-walk")
			if dir.x < -0.5 and dir.y > 0.5:
				$AnimatedSprite2D.play("sw-walk")
			if dir.x < -0.5 and dir.y < -0.5:
				$AnimatedSprite2D.play("nw-walk")
	else:	# sword held or slashing
		var spr: AnimatedSprite2D = $AnimatedSprite2D
		var attack_anim = get_attack_anim()
		if is_slashing:
			spr.play(attack_anim)
		elif spr.animation != attack_anim or spr.is_playing():
			# Sword raised and ready: hold the first frame of the slash
			spr.play(attack_anim)
			spr.stop()
			spr.frame = 0


func handleInput():
	mouse_loc_from_player = get_global_mouse_position() - self.position
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif  direction.x != 0 or direction.y != 0:
		player_state = "walking"
		
	velocity = direction * SPEED
	
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


func hurtByEnemy(_area):
	current_health -= 10
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


func checkHealth():
	if current_health > max_health:
		current_health = max_health
	if current_health < 30:
		PlayerStats.player_hit = true
	if current_health <= 0:
		player_dying.play()
		current_health = 0
		is_alive = false
		if ctrl_inventory_stacked.visible:
			ctrl_inventory_stacked.visible = false
		$AnimatedSprite2D.play("death")
		hurtTimer.start(2)
		await hurtTimer.timeout
		playerDied.emit()


func hungry():
	current_hunger -= 10
	hungerChanged.emit()
	if current_hunger <= 0:
		current_hunger = 0
		current_health -= 10
		checkHealth()
		healthChanged.emit()


func thirsty():
	current_thirst -= 10
	thirstChanged.emit()
	if current_thirst <= 0:
		current_thirst = 0
		current_health -= 10
		checkHealth()
		healthChanged.emit()


func _on_hunger_timer_timeout():
	hungry()
	$hungerTimer.start()


func _on_thirst_timer_timeout():
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
