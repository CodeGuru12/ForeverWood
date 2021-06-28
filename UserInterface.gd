extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ItemClass = preload("res://Item.tscn")
var item = null
var holding_item = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_action_just_pressed("Inventory"):
		$Inventory.visible = !$Inventory.visible
		$Inventory.initialize_inventory()
		$Hotbar.initialize_hotbar()
		
	if event.is_action_pressed("scroll_up"):
		PlayerInventory.active_item_scroll_down()
	elif event.is_action_pressed("scroll_down"):
		PlayerInventory.active_item_scroll_up()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
