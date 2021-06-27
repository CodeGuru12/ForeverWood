extends KinematicBody2D


# Declare member variables here.
var ACCELERATION = 460
const MAX_SPEED = 350
var velocity = Vector2.ZERO
var item_name

var player = null
var being_picked_up = false

# Called when the node enters the scene tree for the first time.
func _ready():
	item_name = "Small Health Potion"

func _physics_process(delta):
	if (being_picked_up == true):
		#print("Coming in here?")
		var direction = global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(direction* MAX_SPEED, ACCELERATION * delta)
		
		var distance = global_position.distance_to(player.global_position)
		#print('distance: ',distance)
		if (distance < 4):
			PlayerInventory.add_item(item_name,1)
			queue_free()
			
		velocity = move_and_slide(velocity)
	#velocity = velocity.move_toward(Vector2(0,MAX_SPEED),ACCELERATION * delta)
	#velocity = move_and_slide(velocity, Vector2.UP)
	#pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func pick_up_item(body):
	player = body
	being_picked_up = true

var positionA = Vector2(400, 500)
var positionB = Vector2(100, 200)
var positionC = Vector2(400, -300)

var t = 0.0
var duration = 1.0

func _process(delta):
	pass
	#t += delta / duration
	#var q0 = positionA.linear_interpolate(positionC, min(t, 1.0))
	#var q1 = positionC.linear_interpolate(positionB, min(t, 1.0))
	#position = q0.linear_interpolate(q1, min(t, 1.0))
	#pass
