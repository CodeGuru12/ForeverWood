extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

onready var levelText : Label = get_node("Popup/BG/LevelBG/LevelText")
onready var healthBar : TextureProgress = get_node("Popup/BG/HealthBar")
onready var xpBar : TextureProgress = get_node("Popup/BG/XPBar")
onready var goldText : Label = get_node("Popup/BG/GoldText")


# updates the level text Label node
func update_level_text(level):
	levelText.text = str(level)
 
# updates the health bar TextureProgress value
func update_health_bar(curHp, maxHp):
	healthBar.value = (100 / maxHp) * curHp
 
# updates the xp bar TextureProgress value
func update_xp_bar(curXp, xpToNextLevel):
	xpBar.value = (100 / xpToNextLevel) * curXp
 
# updates the gold text Label node
func update_gold_text(gold):
 
	goldText.text = "Credits: " + str(gold)
