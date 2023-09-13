extends Node2D


@export var radius      = 50
@export var color_outer = Color.from_hsv(0, 1, 1)
@export var color_inner = Color.WHITE
@export var time_now    = 0
@export var BEAT_LENGTH = 0.450857 # second

func start():
	time_now = 0
	position = Vector2(550, 25)

# Called when the node enters the scene tree for the first time.
func _ready():
	start()

func get_alpha():
	return fposmod(time_now, BEAT_LENGTH) / BEAT_LENGTH

func _draw():
	var color_now = Color.from_hsv(color_outer.h, color_outer.s, color_outer.v,
		get_alpha())
	# draw_circle(position, radius, color_now)
	# draw_circle(position, radius * 0.75, color_inner)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_now += delta
	queue_redraw()

