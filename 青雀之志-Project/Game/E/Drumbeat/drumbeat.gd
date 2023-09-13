extends Node2D
## 鼓点
class_name Drumbeat


const normal_color: Color = Color(0.14901961386204, 0.84705883264542, 1)
const golden_color: Color = Color(1, 0.84705883264542, 0.16862745583057)
const black_color: Color = Color.BLACK

const little_boom := preload("res://SpecialEffects/little_boom.tscn")

var wait_time: float
var flying_angle: float :
	set(value):
		flying_angle = value
		
		rotation = value

var my_tween: Tween


func _ready() -> void:
	reset()


func reset():
	modulate = normal_color
	
	if my_tween:
		my_tween.kill()


func miss():
	modulate = black_color
	
	my_tween = create_tween()
	my_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)


func hit():
	modulate = golden_color
	
	my_tween = create_tween()
	my_tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
