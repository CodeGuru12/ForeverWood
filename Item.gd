extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var item_name
var item_quantity
export var count = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_val = randi() % 3
	if rand_val == 0:
		item_name = "Apple"
		#$TextureRect.texture = load("res://Assets/Items/Potions/smallPotionInventory.png")
	elif rand_val == 1:
		item_name = "Small Health Potion"
	else:
		item_name = "Bag"	
	
	$TextureRect.texture = load("res://Assets/Items/Item_icons/" + item_name + ".png")
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	item_quantity = randi() % stack_size + 1
	
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.text = String(item_quantity)

func set_item(nm, qt):
	item_name = nm
	print("name: ",item_name)
	count+=1
	print("count: ",count)
	item_quantity = qt
	$TextureRect.texture = load("res://Assets/Items/Item_icons/"+ item_name + ".png")
	print("texture: ",$TextureRect.texture)
	var stack_size = int(JsonData.item_data[item_name]["StackSize"])
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.visible = true
		$Label.text = String(item_quantity)		

func add_item_quantity(amount):
	item_quantity += amount
	$Label.text = String(item_quantity)

func decrease_item_quantity(amount):
	item_quantity -= amount
	$Label.text = String(item_quantity)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
