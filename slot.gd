extends Panel


# Declare member variables here. Examples:
var ItemClass     = preload("res://Item.tscn")
var empty_slot    = preload("res://UI/Inventory/Hotbar/empty_slot.png")
var occupied_slot = preload("res://UI/Inventory/Hotbar/occupied_slot.png")
var selected_slot = preload("res://UI/Inventory/Hotbar/selected_slot.png")

var slot_index
var size = empty_slot.get_size()
var item = null
onready var gridNode = find_parent("GridContainer")
#onready var button = get_node("/root/Inventory/CanvasLayer/Popup/TextureRect/GridContainer/Button")
var occupied_style : StyleBoxTexture = null
var empty_style    : StyleBoxTexture = null
var selected_style : StyleBoxTexture = null
#onready var numColumns = gridNode.get_columns()
#onready var gridSize = gridNode.get_size()
#onready var origin = gridNode.get_global_transform().origin
#onready var spacing = gridSize[0]/(numColumns)

var  slot_type
enum SlotType {HOTBAR = 0, INVENTORY = 1}

# Called when the node enters the scene tree for the first time.
func _ready():
	occupied_style = StyleBoxTexture.new()
	empty_style    = StyleBoxTexture.new()
	selected_style = StyleBoxTexture.new()
	
	empty_style.texture    = empty_slot
	occupied_style.texture = occupied_slot
	selected_style.texture = selected_slot
	
	refresh_style()

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("UserInterface")
	inventoryNode.add_child(item)
	item = null
	refresh_style()

func removeSlotItem():
	remove_child(item)
	item = null
	refresh_style()

func initialize_item(item_name, item_quantity):
	if item == null:
		item = ItemClass.instance()
		add_child(item)
		item.set_item(item_name, item_quantity)
	else:
		item.set_item(item_name, item_quantity)
		
	refresh_style()

#func getSlotPosition(item):
#	"""Get slot position for inventory item """
#
#	#Get mouse position
#	var _mcurrentPosition = get_global_mouse_position()
#
#	#Get cell coordinates
#	var cell = [floor((_mcurrentPosition.x - origin.x)/(36)), floor((_mcurrentPosition.y - origin.y) / (36))]  
#	#Get spacing between tiles (Knowing the gridContainer size and tile makes it easy to take difference to get it)
#	var margin = spacing-size[0]
#
#	#Get the upper left hand corner position  of the item
#	print("origin: ",origin)
#	print("cell: ",cell)
#	print("size: ",size)
#	#410
#	#278
#	var posx = (410) + cell[0]*size[0]+4*cell[0]
#	var posy = (278) + cell[1]*size[1]+4*cell[1]
#
#	return [posx, posy]
	
func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(1,1)
	
	var inventoryNode = find_parent("UserInterface")
	inventoryNode.remove_child(item)
	add_child(item)
	print("putIntoSlot item: ",item)
	refresh_style()

	
func refresh_style():
	if (SlotType.HOTBAR == slot_type and PlayerInventory.active_item_slot == slot_index):
		set("custom_styles/panel", selected_style)
	elif item == null:
		set("custom_styles/panel", empty_style)
	else:
		set("custom_styles/panel",occupied_style)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
