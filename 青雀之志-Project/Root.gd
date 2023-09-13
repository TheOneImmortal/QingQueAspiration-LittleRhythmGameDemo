extends Node2D
class_name Root


signal mouse_move(mouse_position: Vector2)
signal try_select(mouse_position: Vector2)

var mouse_pos: Vector2 :
	set(value):
		mouse_pos = value
		emit_signal("mouse_move", mouse_pos)

var start: Vector2
var end: Vector2

@export var main_volume = 100
@export var effect_volume = 100

var is_dragging := false

@onready var start_menu: Node2D = $Scenes/StartMenu
var selecting: Node2D
var game: Game

@onready var scenes: Node2D = $Scenes

const select_scene := preload("res://Selecting/selecting.tscn")
const game_scene := preload("res://Game/game.tscn")
const start_menu_class := preload("res://StartMenu/start_menu.tscn")

func _ready() -> void:
	connect_start_menu_signals()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("LeftClick"):
		start = mouse_pos
		is_dragging = true
		emit_signal("try_select", mouse_pos)
	elif Input.is_action_just_released("LeftClick"):
		end = mouse_pos
		is_dragging = false
	
	if is_dragging:
		end = mouse_pos


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_pos = event.position


func game_exit() -> void:
	print("exit")
	get_tree().quit()
	
func connect_start_menu_signals():
	start_menu.game_start.connect(Callable(self, "to_select"))
	start_menu.game_exit.connect(Callable(self, "game_exit"))
	start_menu.volume_change.connect(Callable(self, "change_volume"))
	start_menu.effect_volume_change.connect(Callable(self, "change_effect_volume"))

func get_volume_db_from_volume_now(volume_now):
	if volume_now != 0:
		return (volume_now - 100) * 0.2
	else:
		return -2000

func change_volume(volume_now):
	main_volume = volume_now
	print("main_volume: " + str(main_volume))

func change_effect_volume(effect_volume_now):
	effect_volume = effect_volume_now
	print("effect_volume: " + str(effect_volume))

func selection_quit() -> void:
	start_menu = start_menu_class.instantiate()
	for i in scenes.get_children():
		i.call_deferred("free")
	scenes.add_child(start_menu)
	connect_start_menu_signals()

func to_select() -> void:
	selecting = select_scene.instantiate()
	for i in scenes.get_children():
		i.call_deferred("free")
	scenes.add_child(selecting)
	try_select.connect(Callable(selecting, "try_select"))
	
	selecting.select_music.connect(Callable(self, "music_select"))
	selecting.selection_quit.connect(Callable(self, "selection_quit"))

func to_game(music: Dictionary) -> void:
	game = game_scene.instantiate()
	
	var drumbeats:Array[float]
	for drumbeat_time in music.drumbeats:
		drumbeats.append(drumbeat_time)
	
	if music.has("show"):
		game.game_start(drumbeats, music.name, music.show)
	else:
		game.game_start(drumbeats, music.name)
	
	for i in scenes.get_children():
		i.call_deferred("free")
	scenes.add_child(game)
	
	game.exit.connect(Callable(self, "out_game"))


func out_game(score: int) -> void:
	to_select()


func music_select(music: Dictionary) -> void:
	to_game(music)
