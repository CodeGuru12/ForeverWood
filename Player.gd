extends KinematicBody2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
onready var ui = get_node("/root/MainScene/UserInterface/UI")

var curHp : int = 10
var maxHp : int = 10
var moveSpeed : int = 250
var damage : int = 1

var gold : int = 0
var smallHealAmnt = 2
var inventory = {"gold": 0}
var curLevel : int = 0
var curXp : int = 0
var xpToNextLevel : int = 50
var xpToLevelIncreaseRate : float = 1.2

var interactDist : int = 70
var directionHistory  = "Right"
var vel = Vector2()
var facingDir = Vector2()
var facingDirHistory = Vector2()
var takingDamage = false
var isAttacking  = false
var animationFinished = true
var playDeathAnimation = false
onready var anim = $AnimatedSprite
onready var rayCast = $RayCast2D
onready var attackEffect = $AttackSound
onready var walkingEffect = $WalkingSound
onready var healEffect	  = $HealSound
var swordSwipeSound = preload("res://SoundEffects/Attack/Wind-Shoowsh-Very-Quick-www.fesliyanstudios.com.wav")
var walkingSound    = preload("res://SoundEffects/Player/sneaker-shoe-on-concrete-floor-fast-pace-1-www.FesliyanStudios.com.wav")
var healSound       = preload("res://SoundEffects/Item/heal.wav")
var walking = false
# Called when the node enters the scene tree for the first time.
func _ready ():
	facingDir.x = 1
	ui.update_level_text(curLevel)
	ui.update_health_bar(curHp, maxHp)
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(inventory['gold'])



func level_up ():
	var overflowXp = curXp - xpToNextLevel
 
	xpToNextLevel *= xpToLevelIncreaseRate
	curXp = overflowXp
	curLevel += 1
	damage += 1
	
func give_gold (amount):
	inventory["gold"] += amount
	print("gold: ",inventory["gold"])
	
func give_health_potion(amount):
	if ("smallHealthPotion" in inventory):
		inventory["smallHealthPotion"] += amount
	else:
		inventory["smallHealthPotion"] = amount

func give_xp (amount):
	curXp += amount
	if curXp >= xpToNextLevel:
		level_up()

func death():
	#Reloads scene after player HP reaches zero
	get_tree().reload_current_scene()
	
func take_damage(dmgToTake):
	takingDamage = true
	curHp -= dmgToTake
	if curHp <= 0:
		playDeathAnimation = true


func playSound(sound, soundToPlay):
	if (sound == 'attack'):
		if !attackEffect.is_playing():
			attackEffect.stream = soundToPlay
			attackEffect.play()
	if (sound == 'walk'):
		if !walkingEffect.is_playing():
			walkingEffect.stream = soundToPlay
			walkingEffect.play()
	if (sound == 'heal'):
		if !healEffect.is_playing():
			healEffect.stream = soundToPlay
			healEffect.play()

func stopSound(soundToStop):
	soundToStop.stop()
	
func updateRayCastDirection():
	if (facingDirHistory != facingDir):
		rayCast.cast_to = facingDir * interactDist
		rayCast.force_raycast_update()

			
func try_interact():
	"""Checks if raycast has hit anything """
	rayCast.cast_to = facingDir * interactDist
	rayCast.force_raycast_update()
	if rayCast.is_colliding():
		if rayCast.get_collider() is KinematicBody2D:
			if rayCast.get_collider().has_method("take_damage"):
				rayCast.get_collider().take_damage(damage)
		elif rayCast.get_collider().has_method("on_interact"):
			isAttacking = false
			rayCast.get_collider().on_interact(self)
	
func _input(event):
	if Input.is_action_just_pressed("interact"):
		if $PickupZone.items_in_range.size() > 0:
			var pickup_item =$PickupZone.items_in_range.values()[0]
			pickup_item.pick_up_item(self)
			$PickupZone.items_in_range.erase(pickup_item)
		else:
			isAttacking = true
			try_interact()
		if (isAttacking and animationFinished):
			animationFinished = false
			playSound('attack',swordSwipeSound)
		else:
			stopSound(attackEffect)

	if Input.is_action_just_pressed("heal"):

		var isConsumable = isSelectHotbarItemConsumable()	
		if (isConsumable):
			var healAmount = int(JsonData.item_data[PlayerInventory.hotbar[PlayerInventory.active_item_slot][0]]["AddHealth"])
			var checkHotbar = PlayerInventory.remove_used_item(PlayerInventory.hotbar[PlayerInventory.active_item_slot][0],PlayerInventory.active_item_slot,1,true)
			if (checkHotbar):
				playSound('heal',healSound)
				curHp += healAmount
				if (curHp >= maxHp):
					curHp = maxHp
			#if (not checkHotbar):
				#if (PlayerInventory.remove_used_item(PlayerInventory.hotbar[PlayerInventory.active_item_slot][0],1,true) ):
				#	var healAmount = int(JsonData.item_data[PlayerInventory.hotbar[PlayerInventory.active_item_slot][0]]["AddHealth"])
				#	playSound('heal',healSound)
				#	curHp += healAmount
				#	if (curHp >= maxHp):
				#		curHp = maxHp
#			else:
#				var healAmount = int(JsonData.item_data[PlayerInventory.hotbar[PlayerInventory.active_item_slot][0]]["AddHealth"])
#				playSound('heal',healSound)
#				curHp += healAmount
#				if (curHp >= maxHp):
#					curHp = maxHp
		
func isSelectHotbarItemConsumable():
	var isConsumable = false
	if (PlayerInventory.hotbar.has(PlayerInventory.active_item_slot) == true):
		if (JsonData.item_data[PlayerInventory.hotbar[PlayerInventory.active_item_slot][0]]["ItemCategory"] == "Consumable"):
			isConsumable = true 
		else:
			isConsumable = false		
				
	return isConsumable
	
func _process (delta):
	 # give_gold function
	ui.update_gold_text(inventory['gold'])
	 
	# give_xp function
	ui.update_xp_bar(curXp, xpToNextLevel)
	 
	# level_up function
	ui.update_level_text(curLevel)
	ui.update_xp_bar(curXp, xpToNextLevel)
	 
	# take_damage function
	ui.update_health_bar(curHp, maxHp)
	
	if (walking):
		playSound('walk',walkingSound)
	else:
		stopSound(walkingEffect)
				
func _physics_process (delta):
	
	vel = Vector2()
	# inputs
	if Input.is_action_pressed("move_up"):
		vel.y -= 1
		facingDir = Vector2(0, -1)
	if Input.is_action_pressed("move_down"):
		vel.y += 1
		facingDir = Vector2(0, 1)
	if Input.is_action_pressed("move_left"):
		vel.x -= 1
		facingDir = Vector2(-1, 0)
		directionHistory = "Left"
	if Input.is_action_pressed("move_right"):
		vel.x += 1
		facingDir = Vector2(1, 0)
		directionHistory = "Right"
	if (vel.x != 0 or vel.y != 0):
		walking = true
	else:
		walking = false

	vel = vel.normalized()
	# move the player
	move_and_slide(vel * moveSpeed, Vector2.ZERO)
	manage_animations()
	updateRayCastDirection()
	facingDirHistory = facingDir
	
	
func manage_animations():
	if playDeathAnimation:
		play_animation("die")	
	elif takingDamage and directionHistory == "Left":
		play_animation("HurtLeft")	
	elif takingDamage:
		play_animation("HurtRight")	
	elif isAttacking and directionHistory == "Left":
		play_animation("attackLeft")	
	elif isAttacking and directionHistory == "Right":
		play_animation("attackRight")	
	elif vel.x > 0:
		play_animation("walkRight")
	elif vel.x < 0:
		play_animation("walkLeft")
	elif vel.y < 0 and directionHistory == "Left":
		play_animation("walkLeft")
	elif vel.y < 0:
		play_animation("walkRight")
	elif vel.y > 0 and directionHistory == "Right":
		play_animation("walkRight")
	elif vel.y > 0:
		play_animation("walkLeft")
	elif facingDir.x == 1:
		play_animation("IdleRight")
	elif facingDir.x == -1:
		play_animation("IdleLeft")
	elif facingDir.y == -1 and directionHistory == "Right":
		play_animation("IdleRight")
	elif facingDir.y == -1:
		play_animation("IdleLeft")
	elif facingDir.y == 1 and directionHistory == "Left":
		play_animation("IdleLeft")
	elif facingDir.y == 1:
		play_animation("IdleRight")
		
func play_animation (anim_name):
	if anim.animation != anim_name:
		anim.play(anim_name)



func _on_AnimatedSprite_animation_finished():
	takingDamage = false
	isAttacking  = false
	animationFinished = true

	if playDeathAnimation:
		playDeathAnimation = false
		death()
