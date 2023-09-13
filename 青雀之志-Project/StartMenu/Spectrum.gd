extends Node2D

@export var music_paused = true # 暂停播放音乐频谱

@export var SLEEP_TIME  = 3 # second
@export var FREQ_CNT    = 32 # 32 频率分级
@export var AMP_CNT     = 40 # 20 响度分级
@export var KEY_WIDTH   = 30 # 键宽度
@export var SPACE_WIDTH = 1  # 键间隔
@export var KEY_HEIGHT  = 5  # 键高度
@export var KEY_ALPHA   = 0.5 # 键不透明度

var filename_now = ""
var amp_now = []
var json_data
var time_now = 0
var music_length

func set_json_file(filename):
	var json_as_text = FileAccess.get_file_as_string(filename)
	json_data = JSON.parse_string(json_as_text)
	if json_data:
		filename_now = filename

func clear_amp(): # 默认最初每种频率上响度都是 0
	for x in range(FREQ_CNT):
		amp_now.append(0)

func music_start():
	music_paused = false
	time_now = 0
	set_json_file("res://art/StartMenuMusic.json")
	$AudioStreamPlayer.play()
	music_length = $AudioStreamPlayer.stream.get_length()
	clear_amp()

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.stop()
	await get_tree().create_timer(SLEEP_TIME).timeout
	music_start()

func color_for_amp(amp: int): # 为指定频率计算颜色
	var rate = 1 - float(amp) / AMP_CNT
	return Color.from_hsv(rate * PI / 4 - PI / 16, 1.0, 1.0, KEY_ALPHA)

func _draw():
	# draw_rect(Rect2(1.0, 1.0, 100.0, 5.0), Color.GREEN)
	for freq in range(FREQ_CNT):
		for amp in range(AMP_CNT):
			var pos_x = (KEY_WIDTH + SPACE_WIDTH) * freq
			var pos_y = KEY_HEIGHT * amp
			
			# get amp_now_for freq
			var amp_now_for_freq = 0
			if freq <= len(amp_now) - 1:
				amp_now_for_freq = amp_now[freq]
				
			if amp_now_for_freq > amp:
				draw_rect(Rect2(pos_x, pos_y, KEY_WIDTH, KEY_HEIGHT), self.color_for_amp(amp))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not music_paused:
		time_now += delta
		var frame_cnt = int(time_now / music_length * len(json_data))
		if frame_cnt < len(json_data):
			amp_now = json_data[frame_cnt]
		else:
			self.clear_amp()
		queue_redraw()
	else:
		amp_now = []

func _on_audio_stream_player_finished():
	await get_tree().create_timer(1).timeout
	music_start()
	# $AudioStreamPlayer.play()
	# $CircleDisplay.restart()

func stop():
	$AudioStreamPlayer.stop()
	music_paused = true
