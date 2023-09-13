extends AnimatedSprite2D

@export var time_now = 0
@export var BEGIN_TIME = 3 # second
@export var END_TIME   = 4.5 # second

@export var QUIT_TIME = 7

@export var QUIT_DIR = Vector2(-1, 0)
@export var QUIT_SPEED = 400

# Called when the node enters the scene tree for the first time.
func _ready():
	time_now = 0
	
func get_timespan():
	return abs(END_TIME -  BEGIN_TIME)

func get_alpha():
	if time_now < BEGIN_TIME:
		return 0
	elif time_now > END_TIME:
		return 1
	else:
		return (time_now - BEGIN_TIME) / get_timespan()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_now += delta
	modulate.a = get_alpha()
	if time_now > QUIT_TIME:
		position += QUIT_DIR * delta * QUIT_SPEED
	pass
