extends Node2D


@export var FREQ_CNT    = 32 # 32 频率分级
@export var AMP_CNT     = 40 # 20 响度分级
@export var KEY_WIDTH   = 30 # 键宽度
@export var SPACE_WIDTH = 1  # 键间隔
@export var KEY_HEIGHT  = 5  # 键高度
@export var KEY_ALPHA   = 20 # 键不透明度

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


func color_for_amp(amp: int): # 为指定频率计算颜色
	var rate = 1 - float(amp) / AMP_CNT
	return Color.from_hsv(rate * PI / 4 - PI / 16, 1.0, 1.0, KEY_ALPHA)


func _draw():
	# draw_rect(Rect2(1.0, 1.0, 100.0, 5.0), Color.GREEN)
	for freq in range(FREQ_CNT):
		for amp in range(AMP_CNT):
			var pos_x = (KEY_WIDTH + SPACE_WIDTH) * freq
			var pos_y = KEY_HEIGHT * amp
			if amp_now[freq] > amp:
				draw_rect(Rect2(pos_x, pos_y, KEY_WIDTH, KEY_HEIGHT), self.color_for_amp(amp))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_now += delta
	var frame_cnt = int(time_now / music_length * len(json_data))
	if frame_cnt < len(json_data):
		amp_now = json_data[frame_cnt]
	else:
		self.clear_amp()
	queue_redraw()
