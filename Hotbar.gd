extends Node2D


# Declare member variables here. 
const SlotClass = preload("res://slot.gd")
onready var hotbar = $HotbarSlots
onready var slots = hotbar.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(slots.size()):
		slots[i].connect("gui_input",self, "slot_gui_input", [slots[i]])
		PlayerInventory.connect("active_item_updated", slots[i], "refresh_style")
		slots[i].slot_index = i
		slots[i].slot_type = SlotClass.SlotType.HOTBAR
		
	initialize_hotbar()
	
func initialize_hotbar():
	for i in range(slots.size()):
		if PlayerInventory.hotbar.has(i):
			slots[i].initialize_item(PlayerInventory.hotbar[i][0], PlayerInventory.hotbar[i][1])

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed: 
			if find_parent("UserInterface").holding_item  != null: #We are holding an item
				if !slot.item: #Place holding item in slot
					click_add_to_empty_slot(slot)
				else: #Swap holding item with item in slot
					if find_parent("UserInterface").holding_item.item_name != slot.item.item_name: #Item slots don't match
						click_swap_slot(event, slot)
					else:  #Matching item slots, combine items
						click_combine_slot(slot)
			elif slot.item: #Not holding an item, so just pick up item from slot
				click_add_slot(slot)	

func click_add_slot(slot: SlotClass):
	PlayerInventory.remove_from_dict(slot)
	find_parent("UserInterface").holding_item  = slot.item
	slot.pickFromSlot()
	find_parent("UserInterface").holding_item.global_position = get_global_mouse_position()

func click_combine_slot(slot: SlotClass):
	var temp_item = slot.item
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	print("slot_type: ",slot.slot_type)
	var addSize = stack_size - slot.item.item_quantity
	#Check if item is less than max StackSize
	if addSize >= find_parent("UserInterface").holding_item.item_quantity: #stacksize larger than item
		slot.item.add_item_quantity(find_parent("UserInterface").holding_item .item_quantity)
		find_parent("UserInterface").holding_item .queue_free()
		find_parent("UserInterface").holding_item  = null
	else: #More items than stacksize
		PlayerInventory.add_item_quantity(slot, addSize)
		slot.item.add_item_quantity(addSize)
		find_parent("UserInterface").holding_item.decrease_item_quantity(addSize)

func click_add_to_empty_slot(slot: SlotClass):
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
	slot.putIntoSlot(find_parent("UserInterface").holding_item )
	find_parent("UserInterface").holding_item  = null
	print('hotbar: ',PlayerInventory.hotbar)
	
func click_swap_slot(event: InputEvent, slot: SlotClass):
	PlayerInventory.remove_from_dict(slot)
	PlayerInventory.add_item_to_empty_slot(find_parent("UserInterface").holding_item, slot)
	var temp_item = slot.item
	slot.pickFromSlot()
	temp_item.global_position = event.global_position
	slot.putIntoSlot(find_parent("UserInterface").holding_item)
	find_parent("UserInterface").holding_item  = temp_item
	print('hotbar: ',PlayerInventory.hotbar)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
