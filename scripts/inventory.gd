extends Node

const MAX_CAPACITY: int = 10

var items: Dictionary = {}
# Structure: { "tape_1": {"quantity": 1, "description": "Old tape", "icon": "res://icons/tape.png"} }

signal inventory_updated

func add_item(item_name: String, description: String = "", icon_path: String = "") -> void:
	if get_total_items() >= MAX_CAPACITY:
		print("Inventory full!")
		return
	
	if items.has(item_name):
		items[item_name]["quantity"] += 1
	else:
		items[item_name] = {
			"quantity": 1,
			"description": description,
			"icon": icon_path
		}
	
	print("Picked up: ", item_name)
	print("Inventory: ", items)
	emit_signal("inventory_updated")
	_save()

func remove_item(item_name: String) -> void:
	if items.has(item_name):
		items[item_name]["quantity"] -= 1
		if items[item_name]["quantity"] <= 0:
			items.erase(item_name)
		emit_signal("inventory_updated")
		_save()

func has_item(item_name: String) -> bool:
	return items.has(item_name)

func get_quantity(item_name: String) -> int:
	if items.has(item_name):
		return items[item_name]["quantity"]
	return 0

func get_total_items() -> int:
	var total = 0
	for item in items:
		total += items[item]["quantity"]
	return total

func clear_inventory() -> void:
	items.clear()
	emit_signal("inventory_updated")
	_save()

# ---- SAVE / LOAD ----
func _save() -> void:
	var save_data = ConfigFile.new()
	for item_name in items:
		save_data.set_value("inventory", item_name, items[item_name])
	save_data.save("user://inventory.cfg")
	print("Inventory saved!")

func _load() -> void:
	var save_data = ConfigFile.new()
	if save_data.load("user://inventory.cfg") == OK:
		for item_name in save_data.get_section_keys("inventory"):
			items[item_name] = save_data.get_value("inventory", item_name)
		print("Inventory loaded: ", items)
		emit_signal("inventory_updated")

func _ready() -> void:
	_load()
