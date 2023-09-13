extends Node2D
class_name MusicCard


## 鼠标移至该卡上方时发出
signal ready_to_select
## 鼠标在该卡上方按下时发出
signal selected

@export var music_json: JSON

func get_area() -> Array[float]:
	return [global_position.x - 182, global_position.y - 324, global_position.x + 182, global_position.y + 324]

@export var raw_position = Vector2(0, 0)

func _ready():
	raw_position = self.position

func _process(delta):
	self.position = raw_position
	if $"..".music_name_now == music_json.data["name"]:
		self.position.y -= 50
