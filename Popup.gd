extends Popup


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var menuDisplayed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	show()
	#pass#hide() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("Inventory") and menuDisplayed == false): # Replace with function body.
		pass
		#show()
		#menuDisplayed = true
		#get_tree().paused = true
	elif (Input.is_action_just_pressed("Inventory") and menuDisplayed == true):
		pass
		#hide()
		#menuDisplayed = false
		#get_tree().paused = false

