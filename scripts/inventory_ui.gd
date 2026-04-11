extends CanvasLayer

@onready var item_list: VBoxContainer = $Panel/VBoxContainer

func _ready() -> void:
	Inventory.inventory_updated.connect(_refresh_ui)
	_refresh_ui()

func _refresh_ui() -> void:
	# Clear old UI
	for child in item_list.get_children():
		child.queue_free()
	
	# Rebuild UI from inventory
	for item_name in Inventory.items:
		var label = Label.new()
		var qty = Inventory.items[item_name]["quantity"]
		var desc = Inventory.items[item_name]["description"]
		label.text = item_name + " x" + str(qty) + " — " + desc
		item_list.add_child(label)
