extends Node2D


func _ready() -> void:
	var tween := create_tween().set_parallel()
	
	
	modulate.a = 0.2
	var target_color = modulate
	target_color.a = 0
	
	
	tween.tween_property(self, "scale", scale + 2 * Vector2.ONE, 1).set_trans(tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", target_color, 1).set_trans(tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
