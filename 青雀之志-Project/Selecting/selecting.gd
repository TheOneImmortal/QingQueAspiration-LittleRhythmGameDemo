extends Node2D


signal select_music(music: Dictionary)
signal selection_quit # 返回到主界面

@onready var music_cards: Node2D = $MusicCards



func _ready() -> void:
	music_cards.select_music.connect(Callable(self, "music_select"))
	
	var music: Array[String]
	get_music("res://Music/Music", music)
	
	var root_node = $"../.."
	$AudioDownC.volume_db = root_node.get_volume_db_from_volume_now(root_node.effect_volume)
	$AudioF.volume_db = root_node.get_volume_db_from_volume_now(root_node.effect_volume)

func get_music(path: String, array: Array[String]):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				get_music(path + "/" + file_name, array)
			else:
				if file_name.ends_with(".json"):
					print("发现文件：" + file_name)
					array.append(path + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("尝试访问路径时出错。")


func try_select(mouse_position):
	music_cards.try_select(mouse_position)


func music_select(music: Dictionary):
	$AudioF.play()
	await get_tree().create_timer(1.0).timeout
	emit_signal("select_music", music)


func _on_music_cards_select_music(music):
	pass

func _process(delta):
	# ESC 或者返回
	if Input.is_action_just_pressed("Exit"):
		selection_quit.emit()


func _on_button_pressed():
	# 返回主菜单
	$AudioDownC.play()
	await get_tree().create_timer(1.0).timeout
	selection_quit.emit()
