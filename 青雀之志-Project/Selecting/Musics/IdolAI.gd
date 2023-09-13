extends Node2D


signal select_music(music: Dictionary)

#preload("res://Selecting/Musics/Music/music_card.tscn")


func _ready() -> void:
	for music_card in get_children():
		music_card.selected.connect(Callable(self, "music_selected"))


func try_select(mouse_position):
	for music_card in get_children():
		var area = music_card.get_area()
		if is_point_in_area(mouse_position, area):
			music_selected(music_card.music_json)


func music_selected(music: JSON):
	print("music_selected")
	var music_dic: Dictionary = music.data
	print(music)
	print(music_dic)
	emit_signal("select_music", music_dic)


static func is_point_in_area(point: Vector2, area: Array[float]) -> bool:
	if (point.x > area[0]
			and point.y > area[1]
			and point.x < area[2]
			and point.y < area[3]):
		return true
	
	return false
