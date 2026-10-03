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

signal ShootingChanged
signal DayChanged
signal DayStarted
signal NightStarted
signal DrinkWater
signal EatApple
signal sendMessage(text: String)

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


func shooting_level(hit: int = 1) -> void:
	hits += hit
	var upper: float = pow(float((shooting + 1) * 2), 3.0)
	if hits > upper:
		shooting += 1
		ShootingChanged.emit()


func send_message(text: String) -> void:
	sendMessage.emit(text)


func check_item_selected(inv: CtrlInventoryStacked) -> void:
	if inv == PlayerStats.c_inventory:
		if PlayerStats.c_inventory == null or PlayerStats.inventory == null:
			return
		var item: InventoryItem = PlayerStats.c_inventory.get_selected_inventory_item()
		if item == null:
			return
		PlayerStats.inventory.transfer_autosplitmerge(item, PlayerStats.player_inventory)
	else:
		if PlayerStats.cp_inventory == null or PlayerStats.player_inventory == null:
			return
		var item: InventoryItem = PlayerStats.cp_inventory.get_selected_inventory_item()
		if item == null:
			return
		PlayerStats.player_inventory.transfer_autosplitmerge(item, PlayerStats.inventory)
