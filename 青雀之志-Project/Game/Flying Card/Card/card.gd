extends Node2D
## 被飞的牌
class_name FlownCard


@onready var line_2d: Line2D = $Line2D
@onready var timer: Timer = $Timer


func flying(from: Vector2, control: Vector2,to: Vector2, color: Color) -> void:
	if !is_node_ready():
		await ready
	
	line_2d.global_position = Vector2.ZERO
	line_2d.default_color = color
	
	for i in range(0, 21):
		var point := _quadratic_bezier(from, control, to, i as float / 20)
		line_2d.add_point(point)
	
	timer.timeout.connect(Callable(self, "de_point"))
	timer.start()


func de_point() -> void:
	for i in range(0, 4):
		if line_2d.get_point_count():
			line_2d.remove_point(0)
		else:
			call_deferred("free")


func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
