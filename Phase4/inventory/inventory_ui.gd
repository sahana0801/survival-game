class_name InventoryUi extends Control

@onready var inv: InventoryEx = preload("res://inventory/player_inventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false
@export var player:Player

func _ready():
	inv.update.connect(update_slots)
	#player.drinkWater.connect(remove_water)
	#player.eatApple.connect(remove_apple)
	update_slots()
	visible = is_open


func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])


func _process(_delta):
	#if Input.is_action_just_pressed("inventory"):
	#	show_inv()
	pass


func show_inv():
	visible = !is_open
	is_open = visible
	#search_items(apple)
	#remove_water()


func search_items(search_item: InvItem):
	for i in range(min(inv.slots.size(), slots.size())):
		if inv.slots[i].item != null:
			print(inv.slots[i].item.name)


func remove_apple():
	pass


func remove_water():
	for i in range(min(inv.slots.size(), slots.size())):
		if inv.slots[i].item != null:
			print(inv.slots[i].item.name)
			if inv.slots[i].item.name == "water_potion":
				if inv.slots[i].amount > 1:
					inv.slots[i].amount -= 1
				elif inv.slots[i].amount == 1:
					inv.slots[i].amount -= 1
					print("empty")
