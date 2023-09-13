extends CanvasLayer

# 关于场景切换，请监听一下事件
signal game_button_start_game_click
signal game_button_options_click
signal game_button_about_click
signal game_button_quit_click

@export var TIME_SPAN = 0.4
@export var BAN_TIME = 2.5 # 开始时不允许触发事件
@export var time_now = 0
var son_list
var audio_list

func button_alive():
	return time_now >= BAN_TIME

# Called when the node enters the scene tree for the first time.
func _ready():
	time_now = 0
	
	son_list = [$ButtonStartGame, $ButtonOptions, $ButtonAbout, $ButtonQuit]
	audio_list = [$AudioC, $AudioD, $AudioE, $AudioF]
	
	# hide all
	for id in range(len(son_list)):
		son_list[id].hide()
		
	await get_tree().create_timer(TIME_SPAN).timeout
	
	# show all
	for id in range(len(son_list)):
		await get_tree().create_timer(TIME_SPAN).timeout
		son_list[id].show()
		audio_list[id].play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_now += delta

func _on_button_quit_button_down():
	if button_alive():
		$AudioDownC.play()
		game_button_quit_click.emit()


func _on_button_start_game_pressed() -> void:
	if button_alive():
		game_button_start_game_click.emit()


func _on_button_about_pressed():
	if button_alive():
		game_button_about_click.emit()

func _on_button_options_pressed():
	if button_alive():
		game_button_options_click.emit()
