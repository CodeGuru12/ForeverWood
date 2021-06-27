extends Panel


# Declare member variables here. Examples:
var ItemClass = preload("res://Item.tscn")
var empty_slot = preload("res://UI/Inventory/empty_slot.png")
var default_slot = preload("res://UI/Inventory/item.png")
var slot_index
var size = empty_slot.get_size()
var item = null
onready var gridNode = find_parent("GridContainer")
#onready var button = get_node("/root/Inventory/CanvasLayer/Popup/TextureRect/GridContainer/Button")
var default_style : StyleBoxTexture = null
var empty_style : StyleBoxTexture = null
#onready var numColumns = gridNode.get_columns()
#onready var gridSize = gridNode.get_size()
#onready var origin = gridNode.get_global_transform().origin
#onready var spacing = gridSize[0]/(numColumns)

# Called when the node enters the scene tree for the first time.
func _ready():
	default_style = StyleBoxTexture.new()
	empty_style = StyleBoxTexture.new()
	empty_style.texture = empty_slot
	default_style.texture = default_slot
		
	refresh_style()

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("Inventory")
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
	
	var inventoryNode = find_parent("Inventory")
	inventoryNode.remove_child(item)
	add_child(item)
	refresh_style()

	
func refresh_style():
	if item == null:
		set("custom_styles/panel", empty_style)
	else:
		set("custom_styles/panel",default_style)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
