extends Node2D


# Declare member variables here. Examples:
const SlotClass = preload("res://slot.gd")
onready var inventory_slots = $GridContainer
var holding_item = null
#var temp_item = null
# Called when the node enters the scene tree for the first time.
func _ready():
	for inv_slot in inventory_slots.get_children():
		inv_slot.connect("gui_input",self, "slot_gui_input", [inv_slot])
	initialize_inventory()
	
func initialize_inventory():
	var slots = inventory_slots.get_children()
	for i in range(slots.size()):
		if PlayerInventory.inventory.has(i):
			slots[i].initialize_item(PlayerInventory.inventory[i][0], PlayerInventory.inventory[i][1])

	
func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed: 
			if holding_item != null: #We are holding an item
				if !slot.item: #Place holding item in slot
					click_empty_slot(slot)
				else: #Swap holding item with item in slot
					if holding_item.item_name != slot.item.item_name: #Item slots don't match
						click_swap_slot(event, slot)
					else:  #Matching item slots, combine items
						click_combine_slot(slot)
			elif slot.item: #Not holding an item, so just pick up item from slot
				click_add_slot(slot)
		
func click_empty_slot(slot: SlotClass):
	slot.putIntoSlot(holding_item)
	holding_item = null

func click_swap_slot(event: InputEvent, slot: SlotClass):
	var temp_item = slot.item
	temp_item.global_position = event.global_position
	slot.putIntoSlot(holding_item)
	holding_item = temp_item

func click_combine_slot(slot: SlotClass):
	var temp_item = slot.item
	var stack_size = int(JsonData.item_data[slot.item.item_name]["StackSize"])
	var addSize = stack_size - slot.item.item_quantity
	#Check if item is less than max StackSize
	if addSize >= holding_item.item_quantity: #stacksize larger than item
		slot.item.add_item_quantity(holding_item.item_quantity)
		holding_item.queue_free()
		holding_item = null
	else: #More items than stacksize
		slot.item.add_item_quantity(addSize)
		holding_item.decrease_item_quantity(addSize)

func click_add_slot(slot: SlotClass):
	holding_item = slot.item
	slot.pickFromSlot()
	holding_item.global_position = get_global_mouse_position()

func _input(event):
	if holding_item:
		holding_item.global_position = get_global_mouse_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
