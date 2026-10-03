extends Node

var experience
var shooting
var max_shooting_level = 15
var hits
var day
var start_time
var end_time
var player_hit = false

signal ShootingChanged
signal DayChanged
signal DrinkWater
signal EatApple
signal sendMessage

#Collect Items: player.gd connects to <item>
signal StickCollected
signal AppleCollected
signal WaterCollected
signal HealthPotionCollected
signal SlimeCollected

#bugfix: not every apple tree/stick needs its own tutorial message
var tutorial_message_3_shown = false
var tutorial_message_4_shown = false
var tutorial_message_inv_shown = false

#inventories
var inventory: InventoryStacked				#changes to whatever inv is open
var c_inventory: CtrlInventoryStacked		#changes to whatever inv is open
var player_inventory: InventoryStacked		#constant
var cp_inventory: CtrlInventoryStacked		#constant

func _ready():
	experience = 0
	shooting = 1
	hits = 0
	day = 1
	start_time = Time.get_unix_time_from_system()


func changeDay():
	day += 1
	DayChanged.emit()


func shooting_level(hit = 1):
	hits += hit
	var upper = pow((shooting + 1) * 2, 3.0)
	if hits > upper:
		shooting += 1
		ShootingChanged.emit()


func send_message(text: String):
	sendMessage.emit(text)


func check_item_selected(inv: CtrlInventoryStacked):
	if inv == PlayerStats.c_inventory:
		var item: InventoryItem = PlayerStats.c_inventory.get_selected_inventory_item()
		if item == null:
			print("Inv null")
			return
		PlayerStats.inventory.transfer_autosplitmerge(item, PlayerStats.player_inventory)
		print("Inv not null")
	else:
		var item: InventoryItem = PlayerStats.cp_inventory.get_selected_inventory_item()
		if item == null:
			print("P-Inv null")
			return
		PlayerStats.player_inventory.transfer_autosplitmerge(item, PlayerStats.inventory)
		print("P-Inv not null")
