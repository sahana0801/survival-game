class_name RPGInventorySlot
extends PanelContainer

var slot_index: int = -1
var window: RPGInventoryWindow = null


func _get_drag_data(_at_position: Vector2) -> Variant:
	if window == null:
		return null
	var inv = window._get_inv()
	if inv == null:
		return null
	var items = inv.get_items()
	if slot_index < 0 or slot_index >= items.size():
		return null
	var item = items[slot_index]
	if item == null or not is_instance_valid(item):
		return null

	var item_id = window._get_item_id(item)
	var category = item.get_property("category", "")
	var tex = item.get_texture()

	# Create drag preview widget centered at mouse
	var preview_root := Control.new()
	var preview_panel := PanelContainer.new()
	preview_panel.theme_type_variation = &"InsetPanel"
	preview_panel.custom_minimum_size = Vector2(26, 26)
	preview_panel.position = Vector2(-13, -13)

	var preview_icon := TextureRect.new()
	preview_icon.texture = tex
	preview_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview_icon.offset_left = 3
	preview_icon.offset_top = 3
	preview_icon.offset_right = -3
	preview_icon.offset_bottom = -3
	preview_panel.add_child(preview_icon)
	preview_root.add_child(preview_panel)

	set_drag_preview(preview_root)

	return {
		"type": "inventory_item",
		"item_id": item_id,
		"title": item.get_title(),
		"texture": tex,
		"category": category,
		"slot_index": slot_index
	}
