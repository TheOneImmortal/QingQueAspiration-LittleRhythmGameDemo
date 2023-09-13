extends AnimatedSprite2D

@export var time_now = 0
@export var SLEEP_TIME = 10 # second
@export var SHOW_TIME  = 2 # second
@export var MAX_ALPHA  = 1
@export var MIN_ALPHA  = 0.45

@export var BLINK_LENGTH = 3 # second

func math_wave(time_t, period_t):
	return 0.5 * (cos(time_t / period_t * 2 * PI) + 1)

func _ready():
	hide()
	await get_tree().create_timer(SLEEP_TIME).timeout
	show()

func get_alpha():
	if time_now < SLEEP_TIME:
		return 0
	elif time_now > SLEEP_TIME + SHOW_TIME:
		return math_wave(time_now, BLINK_LENGTH) * (MAX_ALPHA - MIN_ALPHA) + MIN_ALPHA
	else:
		return (time_now - SLEEP_TIME) / SHOW_TIME
	
func _process(delta):
	time_now += delta
	modulate.a = get_alpha()
