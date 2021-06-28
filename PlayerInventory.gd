extends Node

signal active_item_updated

# Declare member variables here. 
const SlotClass = preload("res://slot.gd")
const ItemClass = preload("res://Item.gd")
onready var inventory_slots = get_node("/root/MainScene/UserInterface/Inventory/GridContainer")
onready var hotbar_slots    = get_node("/root/MainScene/UserInterface/Hotbar")

const NUM_INVENTORY_SLOTS = 18
const NUM_HOTBAR_SLOTS = 8
var inventory = {0: ['Golden Sword', 1], 
				 1: ['Apple', 46],
				 2: ['Apple', 30],
				 4: ['Small Health Potion',1],
				 3: ['Chicken', 10]
				}

var hotbar = {0: ['Golden Sword', 1], 
				 1: ['Apple', 46],
				 2: ['Small Health Potion',1],
				 3: ['Apple', 30],
				 4: ['Chicken', 10]
				}
				
var active_item_slot = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_item(item_name, item_quantity):
	var slot_indices:   Array = inventory.keys()
	var hotbar_indices: Array = hotbar.keys()

	slot_indices.sort()
	hotbar_indices.sort()
	if (attempt_to_add_item(item_name,item_quantity,hotbar,hotbar_indices,true)):
		return
	else:
		attempt_to_add_item(item_name,item_quantity,inventory,slot_indices)
		
func attempt_to_add_item(item_name,item_quantity,checkInventory,indices,is_hotbar: bool = false):
	for item in indices:
		if checkInventory[item][0] == item_name:
			var stack_size = int(JsonData.item_data[item_name]["StackSize"])
			var able_to_add = stack_size - checkInventory[item][1]
			if able_to_add >= item_quantity:
				checkInventory[item][1] += item_quantity
				update_slot_visual(item, checkInventory[item][0], checkInventory[item][1],is_hotbar)
				return true
			else:
				checkInventory[item][1] += able_to_add
				update_slot_visual(item, checkInventory[item][0], checkInventory[item][1],is_hotbar)
				item_quantity = item_quantity - able_to_add
			return true
	# item doesn't exist in inventory yet, so add it to an empty slot
	for i in range(NUM_INVENTORY_SLOTS):
		if checkInventory.has(i) == false:
			checkInventory[i] = [item_name, item_quantity]
			update_slot_visual(i, checkInventory[i][0], checkInventory[i][1],is_hotbar)
			return true
	return false

func add_item_to_empty_slot(item: ItemClass, slot: SlotClass):
	match slot.slot_type:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index] = [item.item_name, item.item_quantity]	
		SlotClass.SlotType.INVENTORY:			
			inventory[slot.slot_index] = [item.item_name, item.item_quantity]

func update_slot_visual(slot_index, item_name, new_quantity, is_hotbar: bool = false):
	var slot
	if (is_hotbar):
		slot = get_tree().root.get_node("/root/MainScene/UserInterface/Hotbar/HotbarSlots/HotbarSlot" + str(slot_index + 1))
	else:
		slot = get_tree().root.get_node("/root/MainScene/UserInterface/Inventory/GridContainer/Panel" + str(slot_index + 1))

	if slot.item != null:
		slot.item.set_item(item_name, new_quantity)
	else:
		slot.initialize_item(item_name, new_quantity)

func remove_used_item(item_name, item_index, item_quantity, is_hotbar: bool = false):
	var slot_indices: Array
	var item_found = false
	var temp_item_name
	var temp_quantity
	
	var slot 
	if (is_hotbar):
		slot = get_tree().root.get_node("/root/MainScene/UserInterface/Hotbar/HotbarSlots/HotbarSlot" + str(item_index + 1))
		print("slot: ",slot)
	else:
		slot = get_tree().root.get_node("/root/MainScene/UserInterface/Inventory/GridContainer/Panel" + str(item_index + 1))
	if (is_hotbar):
		temp_item_name = hotbar[item_index][0]
		temp_quantity  = hotbar[item_index][1]
	else:
		temp_item_name = inventory[item_index][0]
		temp_quantity = inventory[item_index][1]
	
	if temp_item_name == item_name:
		temp_quantity -= item_quantity
		self.decrease_item_quantity(slot, item_quantity)
		print("temp_quantity: ",temp_quantity)
		print("item_index: ",item_index)
		print("temp_item_name: ", temp_item_name)
		print("temp_quantity: ",temp_quantity)
		print("hotbar: ",hotbar)
		if (temp_quantity > 0):
			print("Is this executing?")
			if (is_hotbar):
				update_slot_visual(item_index, temp_item_name, temp_quantity,true)
			else:
				update_slot_visual(item_index, temp_item_name, temp_quantity)
		else:
			#Remove slot item visual
			slot.removeSlotItem()
			#Remove from dictionary, not doing this will cause the item to get added back to the inventory visual
			remove_from_dict(slot,is_hotbar)

		item_found = true

	return item_found


func remove_from_dict(slot: SlotClass,is_hotbar :bool = false):
	"""Remove item from inventory or hotbar dictionary"""
	match slot.slot_type:
		SlotClass.SlotType.HOTBAR:
			hotbar.erase(slot.slot_index)
		SlotClass.SlotType.INVENTORY:
			inventory.erase(slot.slot_index)

			
func add_item_quantity(slot: SlotClass, quantity: int):
	match slot.slot_type:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] += quantity
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] += quantity

func decrease_item_quantity(slot: SlotClass, quantity: int):
	match slot.slot_type:
		SlotClass.SlotType.HOTBAR:
			hotbar[slot.slot_index][1] -= quantity
		SlotClass.SlotType.INVENTORY:
			inventory[slot.slot_index][1] -= quantity

func active_item_scroll_up():
	active_item_slot = (active_item_slot + 1) % NUM_HOTBAR_SLOTS
	emit_signal("active_item_updated")

func active_item_scroll_down():
	if active_item_slot == 0:
		active_item_slot = NUM_HOTBAR_SLOTS - 1
	else:
		active_item_slot -= 1
	emit_signal("active_item_updated")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
