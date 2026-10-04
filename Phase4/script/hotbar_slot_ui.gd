class_name HotbarSlotUI
extends PanelContainer

var slot_index: int = -1
var hotbar: HotbarUI = null


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if slot_index == 0:
		# Slot 1 is class weapon (locked)
		return false
	if data is Dictionary and data.get("type") == "inventory_item":
		var category = data.get("category", "")
		if category == "consumable":
			return true
	return false


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(_at_position, data):
		return
	var item_id = data.get("item_id", "")
	var item_title = data.get("title", item_id)
	if hotbar != null and item_id != "":
		hotbar.bind_item_to_slot(slot_index, item_id)
		PlayerStats.send_message("✨ Đã gán [%s] vào phím [%d]!" % [item_title, slot_index + 1])
