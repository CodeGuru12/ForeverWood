extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



const FACING = {
	Vector2(1, 0): 'right',
	Vector2(-1, 0): 'left',
	Vector2(0, -1): 'down',
	Vector2(0, 1): 'up',
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (callTimer > recordTimeInterval):
		callTimer = 0
		movementBuffer()
	callTimer += delta
	
	if (not target):
		timeToSearch += delta
		if (timeToSearch >= searchTimerMax):# and searchForPlayer == true):
			searchForPlayer = false
			timeToSearch = 0
			
var takingDamage = false
var curHp : int = 5
var maxHp : int = 5
var searchTimerMax : int = 5
export var timeToSearch : float = 0
var searchForPlayer = false
var moveSpeed : int = 100
var xpToGive : int = 30
var xhistory : int = 0
var yhistory : int = 0
var damage : int = 1
var attackRate : float = 1.0
var attackDist : int = 95
var isAttacking = false
var playDeathAnimation = false
var dead = false
var chaseDist : int = 400
var direction = Vector2()
var animationDirection = Vector2()
var velocityDirection = Vector2()
var originalLocation = Vector2()
var vel = Vector2()
onready var anim = $AnimatedSprite
onready var timer = $Timer
onready var target = null#get_node("/root/MainScene/Player")
var player = null
#Path finding
var trackPoints : Array = []
var callTimer = 0
export(float, 0.0, 10.0) var recordTimeInterval = 0.5    # Record the time interval of tracking the target location
export(int, 1, 100) var maxTargetPositionRecords = 8   # Record the maximum number of points
export(float, 0.0, 100.0) var minDistanceToRecord = 20   # Allow recording the minimum distance from the previous point

onready var _raycastTarget = $RayCast2D# as RayCast2D# as RayCast2D # Detection ray directed directly at the target
onready var _raycastStatic = $RayCast2D# as RayCast2D # The ray pointing to the recorded target moving point


var wolfCry = preload("res://SoundEffects/Enemy/Wolf/DogWhimperWhineCry PE918602.wav")
var wolfAttack = preload("res://SoundEffects/Enemy/Wolf/attackWithThud.wav")
onready var wolfSound = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = attackRate
	timer.start()
	originalLocation = self.global_position
	#Get player from scene tree
	yield(get_tree(), "idle_frame")
	var tree = get_tree()
	if tree.has_group("Player"):
		player = tree.get_nodes_in_group("Player")[0]

func movementBuffer():
	if ( trackPoints.size() > 0):
		#print("distance: ",(trackPoints[-1].length()-player.global_position.length()))
		if (abs(trackPoints[-1].length()-player.global_position.length()) >= minDistanceToRecord):
			if (trackPoints.size() < maxTargetPositionRecords):
				trackPoints.append(player.global_position)
			else:
				trackPoints.pop_front()
				trackPoints.append(player.global_position)
	else:
		trackPoints.append(player.global_position)
	
func generate_path(delta: float, ltarget) -> Vector2:
	#print("searchForPlayer: ",searchForPlayer)
	if (ltarget != null and searchForPlayer == true):
		direction = ltarget.global_position - self.global_position
		# Update the direction of the ray, forcibly update the detection result, if there is no collision, move in this direction first
		_raycastTarget.cast_to = direction
		_raycastTarget.force_raycast_update()
		# If there is a collision between the AI ​​and the target or cannot move, then start to detect the recorded target array
		if _raycastTarget.is_colliding() && _raycastTarget.get_collider() != ltarget || self.test_move(self.transform, moveSpeed * delta * direction.normalized()):
			# Loop through all recorded points, looking for points that can be moved
			for point in trackPoints:
				var newDirection = point - self.global_position
				# Update the ray pointing to the record point and force the update of the detection result
				_raycastStatic.cast_to = newDirection
				_raycastStatic.force_raycast_update()
				# If the ray pointing to this point has a collision and can be moved, then move in this direction
				if ! _raycastStatic.is_colliding() && ! self.test_move(self.transform, moveSpeed * delta * newDirection.normalized()):
					direction = newDirection
					break
	else:
		direction = originalLocation - self.global_position
		#print('direction:',direction)

	if (direction.length() <= 20):
		direction = Vector2(0,0)			
		
	return direction.normalized()
	
func take_damage(dmgToTake):
	if (curHp > 0):
		curHp -= dmgToTake
		takingDamage = true
	if ((curHp <= 0 ) and (not dead)):
		playDeathAnimation = true
		dead = true
		death()
 
func playWolfSound():
		#if !wolfSound.is_playing():
		if (dead):
			wolfSound.stream = wolfCry
		else: 
			wolfSound.stream = wolfAttack
		wolfSound.play()


func death():
	playWolfSound()
	target.give_xp(xpToGive)


func get_facing_vector(vec_to_player):
	"""Get vector closest to facing left,right, up, down for enemy animation """
	var min_angle = 360
	var facing = Vector2()
	for vec in FACING.keys():
		var ang = abs(vec_to_player.angle_to(vec))
		if ang < min_angle:
			min_angle = ang
			facing = vec
	
	return FACING[facing]
	

func play_animation(anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)

func manage_animations():
	if (dead == true):
		play_animation("dead")	
	elif playDeathAnimation:
		play_animation("die")	
	elif takingDamage:
		play_animation("Hurt")	
	elif ((abs(vel.x) > 0 or abs(vel.x) > 0)):# and (animationDirection == 'right')):
		play_animation("walkRight")
	#elif ((abs(vel.x) > 0 or abs(vel.x) > 0) and (animationDirection == 'left')):
	#	play_animation("walkLeft")	
	elif (isAttacking == true):
		play_animation("attackRight")
			
	else:
		play_animation("Idle")	
		
func oldSimpleNavigation():		
	if target:
		#var dist = position.distance_to(target.position)
		vel = (target.position - position).normalized()
		animationDirection = get_facing_vector(vel)
		move_and_slide(vel * moveSpeed)
	else:
		vel.x = 0
		vel.y = 0
		
func _physics_process (delta):
	#if dist > attackDist and dist < chaseDist:
	if (dead == false):
		if (callTimer >= recordTimeInterval):
			velocityDirection = generate_path(delta,player)

		vel = velocityDirection * moveSpeed
		animationDirection = get_facing_vector(vel)
		vel = move_and_slide(vel)
	manage_animations()

func _on_Area2D_body_entered(body):
	print(body.name)
	if body.name == "Player":
		target = body
		searchForPlayer = true
func _on_Area2D_body_exited(body):
	if body.name == "Player":
		target = null

func _on_Timer_timeout():
	if (target and (not dead)):
		#print("attackDist: ",attackDist)
		#print("position.distance_to(target.position): ",position.distance_to(target.position))
		if position.distance_to(target.position) <= attackDist:
			isAttacking = true
			playWolfSound()
			target.take_damage(damage)

		

func _on_AnimatedSprite_animation_finished():
	takingDamage = false
	isAttacking = false
	if (playDeathAnimation == true):
		playDeathAnimation = false
		#queue_free()
