extends CanvasLayer

@export var time_now = 0
@export var TIME_SHOW = 0.5 # second

func toggle_visibility():
	if self.visible:
		self.hide()
	else:
		self.show()
		time_now = 0

func get_alpha():
	if time_now > TIME_SHOW:
		return 1
	else:
		return time_now / TIME_SHOW

func _process(delta):
	time_now += delta
	$ColorRect.modulate.a = get_alpha()

func _on_button_pressed():
	toggle_visibility()
	$"../HUD/AudioDownC".play()
