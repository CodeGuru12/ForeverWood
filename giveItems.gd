extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var chestOpen = $AudioStreamPlayer2D
var chestOpenSound = preload("res://SoundEffects/Chest/Opening/opening-door-1-www.FesliyanStudios.com.wav")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

export var goldToGive : int = 5
export var healthPotiion : int = 5
var chest_closed = preload("res://Assets/Items/Chests/brown_chest_closed.png")
var chest_open = preload("res://Assets/Items/Chests/brown_chest_open.png")
var chestOpened = false

onready var chest = get_node("props_chest")


func on_interact(player):
	if (not chestOpened):
		player.give_gold(goldToGive)
		PlayerInventory.add_item("Small Health Potion",5)
		playChestOpenSound()
		chest.set_texture(chest_open)
		chestOpened = true
	

	
func playChestOpenSound():
		if !chestOpen.is_playing():
			chestOpen.stream = chestOpenSound
			chestOpen.play()



