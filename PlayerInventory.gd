extends Node


# Declare member variables here. 
const SlotClass = preload("res://slot.gd")
const ItemClass = preload("res://Item.gd")

const NUM_INVENTORY_SLOTS = 18
const NUM_HOTBAR_SLOTS = 8
var inventory = {0: ['Golden Sword', 1], 
				 1: ['Apple', 46],
				 2: ['Apple', 30],
				 4: ['Small Health Potion',1],
				 3: ['Chicken', 10]
				}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_item(item_name, item_quantity):
	var slot_indices: Array = inventory.keys()
	slot_indices.sort()
	for item in slot_indices:
		if inventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - inventory[item][1]
			if able_to_add >= item_quantity:
				inventory[item][1] += item_quantity
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				return
			else:
				inventory[item][1] += able_to_add
				update_slot_visual(item, inventory[item][0], inventory[item][1])
				item_quantity = item_quantity - able_to_add
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0], inventory[i][1])
			return
	
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if inventory.has(i) == false:
			inventory[i] = [item_name, item_quantity]
			update_slot_visual(i, inventory[i][0], inventory[i][1])
			return	

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass):
	inventory[slot.slot_index] = [slot.item.item_name, slot.item.item_quantity]

func update_slot_visual(slot_index, item_name, new_quantity):
	var slot = get_tree().root.get_node("/root/MainScene/UserInterface/Inventory/GridContainer/Panel" + str(slot_index + 1))
	if slot.item != null:
		slot.item.set_item(item_name, new_quantity)
	else:
		slot.initialize_item(item_name, new_quantity)

func remove_item(item_name, item_quantity):
	var slot_indices: Array = inventory.keys()
	var item_found = false
	slot_indices.sort()
	for item in slot_indices:
		if inventory[item][0] == item_name:
			inventory[item][1] -= item_quantity
			if (inventory[item][1] > 0):
				update_slot_visual(item, inventory[item][0], inventory[item][1])
			else:
				var slot = get_tree().root.get_node("/root/MainScene/UserInterface/Inventory/GridContainer/Panel" + str(item + 1))
				#Remove slot item visual
				slot.removeSlotItem()
				#Remove from dictionary, not doing this will cause the item to get added back to the inventory visual
				remove_from_dict(slot)

			item_found = true
			break
	return item_found


func remove_from_dict(slot: SlotClass):
	inventory.erase(slot.slot_index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
