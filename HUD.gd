extends Popup


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var menuDisplayed = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("Inventory") and menuDisplayed == false): # Replace with function body.
		show()
		menuDisplayed = true
	elif (Input.is_action_just_pressed("Inventory") and menuDisplayed == true):
		hide()
		menuDisplayed = false

