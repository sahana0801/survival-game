extends StaticBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var inv: Node = $InventoryStacked
@onready var ctrl_inv: Control = $CtrlInventoryStacked
@onready var area: Area2D = $Area2D

var is_open: bool = false
var player_in_range: bool = false

func _ready() -> void:
	if anim:
		anim.play("closed")
	if ctrl_inv:
		ctrl_inv.visible = false
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
	
	# Add initial loot if inventory is empty
	call_deferred("_setup_initial_loot")

func _setup_initial_loot() -> void:
	if inv and inv.has_method("create_and_add_item"):
		if inv.get_item_count() == 0:
			inv.create_and_add_item("apple")
			inv.create_and_add_item("apple")
			inv.create_and_add_item("wood")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_in_range = false
		if is_open:
			close_chest()

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if is_open:
			close_chest()
		else:
			open_chest()

func open_chest() -> void:
	is_open = true
	if anim:
		anim.play("open")
	if ctrl_inv:
		ctrl_inv.visible = true
	if PlayerStats:
		PlayerStats.c_inventory = ctrl_inv
		PlayerStats.inventory = inv
		if PlayerStats.cp_inventory != null:
			PlayerStats.cp_inventory.visible = true

func close_chest() -> void:
	is_open = false
	if anim:
		anim.play("closed")
	if ctrl_inv:
		ctrl_inv.visible = false
	if PlayerStats:
		if PlayerStats.c_inventory == ctrl_inv:
			PlayerStats.c_inventory = null
		if PlayerStats.inventory == inv:
			PlayerStats.inventory = null
