extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_ofs()
	connect("frame_changed", self, "set_ofs")

	
var offsets = Vector2(-60, 0)

func set_ofs():
	if animation  == "walkLeft" or animation == "attackLeft":
		set_offset(offsets)
	else:
		set_offset(Vector2(0,0))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
