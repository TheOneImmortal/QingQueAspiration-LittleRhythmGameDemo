extends Node2D
## 爆炸环
class_name BoomRings


var boom_ring := preload("res://Game/E/BoomRings/BoomRing/boom_ring.tscn")


## 半径198时，scale为1
func boom(radius: float, color: Color) -> void:
	var ring: Node2D = boom_ring.instantiate()
	ring.scale = (radius / 198) * Vector2.ONE
	ring.modulate = color
	
	add_child(ring)
