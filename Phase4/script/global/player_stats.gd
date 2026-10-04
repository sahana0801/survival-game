extends Node

var experience: int = 0
var shooting: int = 1
var max_shooting_level: int = 15
var hits: int = 0
var day: int = 1
var start_time: float = 0.0
var end_time: float = 0.0
var player_hit: bool = false
var is_night: bool = false

enum CharacterType { KNIGHT = 0, ARCHER = 1 }
var active_character: int = CharacterType.KNIGHT

signal ShootingChanged
signal DayChanged
@warning_ignore("unused_signal")
signal DayStarted
@warning_ignore("unused_signal")
signal NightStarted
@warning_ignore("unused_signal")
signal RequestToggleDayNight
@warning_ignore("unused_signal")
signal DrinkWater
@warning_ignore("unused_signal")
signal EatApple
signal sendMessage(text: String)
signal characterChanged(new_char: int)

# Collect Items: player.gd connects to <item>
@warning_ignore("unused_signal")
signal StickCollected
@warning_ignore("unused_signal")
signal AppleCollected
@warning_ignore("unused_signal")
signal WaterCollected
@warning_ignore("unused_signal")
signal HealthPotionCollected
@warning_ignore("unused_signal")
signal SlimeCollected

# Tutorial message flags
var tutorial_message_3_shown: bool = false
var tutorial_message_4_shown: bool = false
var tutorial_message_inv_shown: bool = false

# Inventories
var inventory: InventoryStacked = null			# Changes to whatever inv is open
var c_inventory: CtrlInventoryStacked = null		# Changes to whatever inv is open
var player_inventory: InventoryStacked = null		# Constant
var cp_inventory: CtrlInventoryStacked = null		# Constant


func _ready() -> void:
	experience = 0
	shooting = 1
	hits = 0
	day = 1
	start_time = Time.get_unix_time_from_system()


func changeDay() -> void:
	day += 1
	DayChanged.emit()


func toggle_day_night() -> void:
	is_night = !is_night
	if is_night:
		NightStarted.emit()
	else:
		changeDay()
		DayStarted.emit()
	RequestToggleDayNight.emit()


const MAX_WEAPON_TIER: int = 8

const TIER_NAMES: Array[String] = [
	"Tier 1 (Sơ Cấp)",
	"Tier 2 (Đồng Thau)",
	"Tier 3 (Đồng Đỏ)",
	"Tier 4 (Sắt Thép)",
	"Tier 5 (Hoàng Kim)",
	"Tier 6 (Huyền Bí)",
	"Tier 7 (Hỏa Ngọc)",
	"Tier 8 (Thần Thoại)"
]

var weapon_level: int:
	get:
		return shooting
	set(val):
		shooting = clampi(val, 1, MAX_WEAPON_TIER)

# Bảng Cân Bằng Chỉ Số Vũ Khí 8 Tier (Min DMG, Max DMG, Crit Chance, Crit Multiplier)
const WEAPON_BALANCE: Array[Dictionary] = [
	{"min": 12, "max": 18, "crit": 0.05, "mult": 1.5},
	{"min": 16, "max": 24, "crit": 0.10, "mult": 1.5},
	{"min": 21, "max": 31, "crit": 0.15, "mult": 1.5},
	{"min": 27, "max": 39, "crit": 0.20, "mult": 1.6},
	{"min": 34, "max": 48, "crit": 0.25, "mult": 1.6},
	{"min": 42, "max": 58, "crit": 0.30, "mult": 1.7},
	{"min": 51, "max": 69, "crit": 0.35, "mult": 1.75},
	{"min": 62, "max": 82, "crit": 0.40, "mult": 2.0}
]

var base_weapon_damage: int = 15


func get_weapon_tier_name(tier: int = -1) -> String:
	if tier <= 0:
		tier = weapon_level
	var idx = clampi(tier - 1, 0, TIER_NAMES.size() - 1)
	return TIER_NAMES[idx]


func get_sword_texture_path(tier: int = -1) -> String:
	if tier <= 0:
		tier = weapon_level
	tier = clampi(tier, 1, MAX_WEAPON_TIER)
	return "res://art/weapons/sword_tier_%d.png" % tier


func get_bow_texture_path(tier: int = -1) -> String:
	if tier <= 0:
		tier = weapon_level
	tier = clampi(tier, 1, MAX_WEAPON_TIER)
	return "res://art/weapons/bow_tier_%d.png" % tier


func get_arrow_texture_path(tier: int = -1) -> String:
	if tier <= 0:
		tier = weapon_level
	tier = clampi(tier, 1, MAX_WEAPON_TIER)
	if tier <= 2:
		return "res://art/weapons/arrow_tier_1.png"
	elif tier <= 4:
		return "res://art/weapons/arrow_tier_2.png"
	elif tier <= 6:
		return "res://art/weapons/arrow_tier_3.png"
	else:
		return "res://art/weapons/arrow_tier_4.png"


func get_arrow_tier_index(tier: int = -1) -> int:
	if tier <= 0:
		tier = weapon_level
	tier = clampi(tier, 1, MAX_WEAPON_TIER)
	if tier <= 2:
		return 1
	elif tier <= 4:
		return 2
	elif tier <= 6:
		return 3
	else:
		return 4


func get_weapon_min_damage(tier: int = -1) -> int:
	if tier <= 0:
		tier = weapon_level
	var idx = clampi(tier - 1, 0, WEAPON_BALANCE.size() - 1)
	return WEAPON_BALANCE[idx]["min"]


func get_weapon_max_damage(tier: int = -1) -> int:
	if tier <= 0:
		tier = weapon_level
	var idx = clampi(tier - 1, 0, WEAPON_BALANCE.size() - 1)
	return WEAPON_BALANCE[idx]["max"]


func get_weapon_crit_chance(tier: int = -1) -> float:
	if tier <= 0:
		tier = weapon_level
	var idx = clampi(tier - 1, 0, WEAPON_BALANCE.size() - 1)
	return WEAPON_BALANCE[idx]["crit"]


func get_weapon_crit_multiplier(tier: int = -1) -> float:
	if tier <= 0:
		tier = weapon_level
	var idx = clampi(tier - 1, 0, WEAPON_BALANCE.size() - 1)
	return WEAPON_BALANCE[idx]["mult"]


func roll_attack_damage(tier: int = -1) -> Dictionary:
	if tier <= 0:
		tier = weapon_level
	var min_dmg = get_weapon_min_damage(tier)
	var max_dmg = get_weapon_max_damage(tier)
	var crit_rate = get_weapon_crit_chance(tier)
	var crit_mult = get_weapon_crit_multiplier(tier)
	
	var base_roll: int = randi_range(min_dmg, max_dmg)
	var is_crit: bool = randf() < crit_rate
	var final_dmg: int = base_roll
	if is_crit:
		final_dmg = int(round(base_roll * crit_mult))
	
	return {
		"damage": final_dmg,
		"base_damage": base_roll,
		"is_crit": is_crit,
		"tier": tier
	}


# Tương thích ngược với các script cũ
func get_sword_damage() -> int:
	return roll_attack_damage()["damage"]


func get_bow_damage() -> int:
	return roll_attack_damage()["damage"]


func get_weapon_damage() -> int:
	return roll_attack_damage()["damage"]


func get_player_inventory_node() -> InventoryStacked:
	if player_inventory != null and is_instance_valid(player_inventory):
		return player_inventory
	if Engine.get_main_loop() is SceneTree:
		var tree = Engine.get_main_loop() as SceneTree
		var p = tree.get_first_node_in_group("player")
		if p != null and p.has_node("InventoryStacked"):
			player_inventory = p.get_node("InventoryStacked") as InventoryStacked
			return player_inventory
	return null


func get_slime_count() -> int:
	var inv = get_player_inventory_node()
	if inv == null:
		return 0
	var count: int = 0
	for item in inv.get_items():
		if item != null and is_instance_valid(item) and item.prototype_id == "slime":
			var stack = item.get_property("stack_size", 1)
			count += int(stack) if stack != null else 1
	return count


func consume_slime(amount: int = 1) -> bool:
	var inv = get_player_inventory_node()
	if inv == null or get_slime_count() < amount:
		return false
	var needed = amount
	var to_remove: Array[InventoryItem] = []
	for item in inv.get_items():
		if item != null and is_instance_valid(item) and item.prototype_id == "slime":
			var stack = item.get_property("stack_size", 1)
			var cur_stack: int = int(stack) if stack != null else 1
			if cur_stack <= needed:
				needed -= cur_stack
				to_remove.append(item)
			else:
				item.set_property("stack_size", cur_stack - needed)
				needed = 0
			if needed <= 0:
				break
	
	for item in to_remove:
		inv.remove_item(item)
		item.queue_free()
	
	return true


func upgrade_weapon_tier() -> bool:
	if weapon_level >= MAX_WEAPON_TIER:
		return false
	if not consume_slime(1):
		return false
	weapon_level += 1
	ShootingChanged.emit()
	var min_d = get_weapon_min_damage()
	var max_d = get_weapon_max_damage()
	var crit_pct = int(get_weapon_crit_chance() * 100)
	send_message("⚒️ Vũ Khí nâng lên %s! (%d~%d DMG, +%d%% Chí Mạng)" % [get_weapon_tier_name(), min_d, max_d, crit_pct])
	return true


func shooting_level(hit: int = 1) -> void:
	hits += hit
	var upper: float = pow(float((shooting + 1) * 2), 3.0)
	if hits > upper and shooting < MAX_WEAPON_TIER:
		shooting += 1
		ShootingChanged.emit()
		var min_d = get_weapon_min_damage()
		var max_d = get_weapon_max_damage()
		var crit_pct = int(get_weapon_crit_chance() * 100)
		send_message("⚔️ Cấp Vũ Khí lên %s! (%d~%d DMG, +%d%% Chí Mạng)" % [get_weapon_tier_name(), min_d, max_d, crit_pct])


func send_message(text: String) -> void:
	sendMessage.emit(text)


func set_active_character(new_char: int) -> void:
	if active_character != new_char:
		active_character = new_char
		characterChanged.emit(new_char)


func get_character_name() -> String:
	return "Hiệp Sĩ" if active_character == CharacterType.KNIGHT else "Cung Thủ"


func check_item_selected(inv: CtrlInventoryStacked) -> void:
	if inv == c_inventory:
		if c_inventory == null or inventory == null:
			return
		var item: InventoryItem = c_inventory.get_selected_inventory_item()
		if item == null:
			return
		inventory.transfer_autosplitmerge(item, player_inventory)
	else:
		if cp_inventory == null or player_inventory == null:
			return
		var item: InventoryItem = cp_inventory.get_selected_inventory_item()
		if item == null:
			return
		player_inventory.transfer_autosplitmerge(item, inventory)
