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
signal DayStarted
signal NightStarted
signal DrinkWater
signal EatApple
signal sendMessage(text: String)
signal characterChanged(new_char: int)

# Collect Items: player.gd connects to <item>
signal StickCollected
signal AppleCollected
signal WaterCollected
signal HealthPotionCollected
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

# Sát thương cơ bản cho vũ khí: Cấp 1 = 15, mỗi cấp tăng thêm +5 dmg
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


func get_sword_damage() -> int:
	return base_weapon_damage + (shooting - 1) * 5


func get_bow_damage() -> int:
	return base_weapon_damage + (shooting - 1) * 5


func get_weapon_damage() -> int:
	return base_weapon_damage + (shooting - 1) * 5


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
	var to_remove: Array = []
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
	send_message("⚒️ Vũ Khí nâng lên %s! (+5 Sát Thương, Tổng: +%d DMG)" % [get_weapon_tier_name(), get_weapon_damage()])
	return true


func shooting_level(hit: int = 1) -> void:
	hits += hit
	var upper: float = pow(float((shooting + 1) * 2), 3.0)
	if hits > upper and shooting < MAX_WEAPON_TIER:
		shooting += 1
		ShootingChanged.emit()
		send_message("⚔️ Cấp Vũ Khí lên %s! (+5 Sát Thương Cung & Kiếm)" % get_weapon_tier_name())


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
