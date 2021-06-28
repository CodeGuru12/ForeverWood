extends Node2D


# Declare member variables here. Examples:
const SlotClass = preload("res://slot.gd")
onready var inventory_slots = $GridContainer

#var temp_item = null
# Called when the node enters the scene tree for the first time.
func _ready():
	var slots = inventory_slots.get_children()

	for i in range(slots.size()):
		slots[i].connect("gui_input",self, "slot_gui_input", [slots[i]])
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.INVENTORY

	initialize_inventory()
	
func initialize_inventory():
	var slots = inventory_slots.get_children()

	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])
			

	
func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed: 
			if find_parent("UserInterface").holding_item != null: #We are holding an item
				if !slot.item: #Place holding item in slot
					click_empty_slot(slot)
				else: #Swap holding item with item in slot
					if find_parent("UserInterface").holding_item.item_name != slot.item.item_name: #Item slots don't match
						click_swap_slot(event, slot)
					else:  #Matching item slots, combine items
						click_combine_slot(slot)
			elif slot.item: #Not holding an item, so just pick up item from slot
				click_pick_from_slot(slot)
		
func click_empty_slot(slot: SlotClass):
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item,slot)
	slot.putIntoSlot(find_parent("UserInterface").holding_item)
	find_parent("UserInterface").holding_item  = null

func click_swap_slot(event: InputEvent, slot: SlotClass):
	PlayerInventory.remove_from_dict(slot)
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(find_parent("UserInterface").holding_item)
	find_parent("UserInterface").holding_item  = temp_item

func click_combine_slot(slot: SlotClass):
	var temp_item = slot.item
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var addSize = stack_size - slot.item.item_quantity
	#Check if item is less than max StackSize
	if addSize >= find_parent("UserInterface").holding_item.item_quantity: #stacksize larger than item
		PlayerInventory.add_item_quantity(slot, find_parent("UserInterface").holding_item.item_quantity)
		slot.item.add_item_quantity(find_parent("UserInterface").holding_item.item_quantity)
		find_parent("UserInterface").holding_item.queue_free()
		find_parent("UserInterface").holding_item  = null
		PlayerInventory.remove_from_dict(slot)
		print("inventory: ",slot)
	else: #More items than stacksize
		PlayerInventory.add_item_quantity(slot, find_parent("UserInterface").holding_item.item_quantity)
		slot.item.add_item_quantity(addSize)
		find_parent("UserInterface").holding_item.decrease_item_quantity(addSize)
		
func click_pick_from_slot(slot: SlotClass):
	PlayerInventory.remove_from_dict(slot)
	find_parent("UserInterface").holding_item  = slot.item
	slot.pickFromSlot()
	find_parent("UserInterface").holding_item .global_position = get_global_mouse_position()

func _input(event):
	if find_parent("UserInterface").holding_item:
		find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
