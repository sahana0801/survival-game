class_name HotbarUI extends Control

@export var player: Player

@onready var slot_bow: HotbarSlot = $Panel/HBoxContainer/SlotBow
@onready var slot_sword: HotbarSlot = $Panel/HBoxContainer/SlotSword
@onready var slot_potion: HotbarSlot = $Panel/HBoxContainer/SlotPotion
@onready var slot_apple: HotbarSlot = $Panel/HBoxContainer/SlotApple
@onready var slot_skin: HotbarSlot = $Panel/HBoxContainer/SlotSkin


func _ready():
	if player != null:
		player.weaponChanged.connect(_on_weapon_changed)
		player.skinChanged.connect(_on_skin_changed)
	update_active_weapon(0)


func _on_weapon_changed(weapon_index: int):
	update_active_weapon(weapon_index)


func update_active_weapon(weapon_index: int):
	if slot_bow != null:
		slot_bow.set_active(weapon_index == 1)
	if slot_sword != null:
		slot_sword.set_active(weapon_index == 2)


func _on_skin_changed(_skin_name: String):
	pass


func _on_slot_bow_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player != null:
			player.equip_weapon(1)


func _on_slot_sword_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player != null:
			player.equip_weapon(2)


func _on_slot_potion_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player != null:
			player.drink_health_potion()
			player.drink()


func _on_slot_apple_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player != null:
			player.eat()


func _on_slot_skin_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if player != null:
			player.toggle_skin()
