extends Node2D
## 飞卡器
class_name CardFlier


var card_template := preload("res://Game/Flying Card/Card/card.tscn")
var boom := preload("res://SpecialEffects/boom.tscn")


func flying(from: Vector2, to: Vector2, color: Color) -> void:
	var card := card_template.instantiate() as FlownCard
	add_child(card)
	card.flying(from, from + 200 * Vector2.from_angle(randf_range(0, 2 * PI)), to, color)
	
	var newboom := boom.instantiate() as Node2D
	newboom.global_position = to
	add_child(newboom)
