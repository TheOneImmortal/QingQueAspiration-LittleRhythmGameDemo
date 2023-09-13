extends Node2D
class_name Game


signal exit(score: int)


@export var drumbeats_times: Array[float]

var score: int = 0
var combol_count: int = 0
var combol_max: int = 0 # 最大连击

var is_start: bool = false
var is_real_start: bool = false

var music_path := "res://Music/Song/"
var music_show_path := "res://Music/VoiceShow/"
var music_time := 0

var shower: Node2D

@onready var music_timer: Timer = $Timer
@onready var bgm: AudioStreamPlayer = $BGM
# @onready var server_connect: Node2D = $ServerConnect
@onready var combol_count_text: Control = $"Combol Times"
@onready var score_text: Control = $Score
@onready var score_target: Node2D = $Score/ScoreTarget
@onready var track_e: Track = $trackE
@onready var attack_q: Node2D = $Q
@onready var mahjong: Mahjong = $Mahjong
@onready var te_xiao: Node2D = $"Te Xiao"
@onready var te_xiao_2: Node2D = $"Te Xiao2"
@onready var flying_card: CardFlier = $"Flying Card"

const voice_show := preload("res://SpecialEffects/VoiceDraw/voice_show.tscn")

func set_volume_db(volumn_db):
	$BGM.volume_db = volumn_db

func set_effect_volume_db(effect_volumn_db):
	$Hited.volume_db = effect_volumn_db

func _ready() -> void:
	mahjong.mahjong_prefect_reduced.connect(Callable(self, "attack_prefect"))
	mahjong.mahjong_reduced.connect(Callable(self, "attack_success"))
	mahjong.excessived_reduced.connect(Callable(self, "attack_false"))
	
	track_e.meaningless_try.connect(Callable(self, "e_meaningless_try"))
	track_e.too_eraly_miss.connect(Callable(self, "e_too_eraly_miss"))
	track_e.earlier_hit.connect(Callable(self, "e_earlier_hit"))
	track_e.prefect_hit.connect(Callable(self, "e_prefect_hit"))
	track_e.later_hit.connect(Callable(self, "e_later_hit"))
	track_e.too_late_miss.connect(Callable(self, "e_too_late_miss"))
	
	# server_connect.sound_value.connect(Callable(self, "take_sound"))
	$ButtonQuit.position = Vector2(1100, 10)
	
	var root_node = $"../.."
	set_volume_db(root_node.get_volume_db_from_volume_now(root_node.main_volume))
	set_effect_volume_db(root_node.get_volume_db_from_volume_now(root_node.effect_volume))
	
	if is_start and !is_real_start:
		game_real_start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Q") and !event.is_echo():
		$Mahjong.attack()
	
	elif event.is_action_pressed("E") and !event.is_echo():
		put_e()
	
	elif event.is_action_pressed("Restart") and !event.is_echo():
		game_restart()
	
	elif event.is_action_pressed("Exit") and !event.is_echo():
		exit.emit(score)


func game_start(music_drumbeats_times: Array[float], music_name: String, voice_show: String = "") -> void:
	is_start = true
	
	drumbeats_times = music_drumbeats_times
	music_path += music_name
	music_show_path += voice_show
	
	if !is_node_ready():
		return
	
	game_real_start()


func game_real_start():
	is_real_start = true
	
	combol_count = 0
	combol_count_text.set_combol_times(combol_count)
	score = 0
	score_text.set_score(score)
	
	bgm.stream = load(music_path)
	music_time = bgm.stream.get_length() + 5
	music_timer.paused = true
	music_timer.start(music_time)
	track_e.start(drumbeats_times, music_timer)
	
	if FileAccess.file_exists(music_show_path):
		shower = voice_show.instantiate()
		$ShowHere.add_child(shower)
		shower.set_json_file(music_show_path)
		shower.music_length = bgm.stream.get_length()
		shower.clear_amp()
		print(str(music_show_path) + " Exist")
	else:
		print(str(music_show_path) + " Not Exist")
	
	bgm.play()
	music_timer.paused = false


func game_restart() -> void:
	mahjong.restart()
	
	combol_count = 0
	combol_count_text.set_combol_times(combol_count)
	score = 0
	score_text.set_score(score)
	
	music_timer.paused = true
	music_timer.start(music_time)
	track_e.restart()
	
	bgm.play()
	music_timer.paused = false
	
	if shower:
		shower.time_now = 0


func attack_prefect(mahjong_kind: Mahjong.MahjongKind) -> void:
	score += 8
	score_text.set_score(score)
	
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_GOLDENROD)


func attack_success(mahjong_kind: Mahjong.MahjongKind) -> void:
	score += 1
	score_text.set_score(score)
	
	flying_card.flying(attack_q.position, score_target.global_position, Color.DARK_CYAN)


func attack_false() -> void:
	#if score < 1:
	#	return
	#score -= 1
	#score_text.set_score(score)
	pass


func attack_miss() -> void:
	combol_count = 0
	combol_count_text.set_combol_times(combol_count)


## 麦克风收取到声音
func take_sound(value) -> void:
	put_e()


func put_e() -> void:
	var nowtime: float = music_timer.wait_time - music_timer.time_left
	print(nowtime)
	track_e.try_hit()


## 尝试在检测区内空时打击
func e_meaningless_try():
	pass


## 太早未命中
func e_too_eraly_miss():
	combol_count = 0
	combol_count_text.set_combol_times(combol_count)


## 较早击中
func e_earlier_hit():
	combol_count += 1
	combol_count_text.set_combol_times(combol_count)
	
	var kard_kind := randi_range(0,2)
	
	mahjong.add_card(kard_kind)
	
	te_xiao.hit(kard_kind)
	
	flying_card.flying(track_e.last_e_pos, attack_q.position, Color.DARK_CYAN)
	
	$Hited.play(0)


## 完美击中
func e_prefect_hit():
	combol_count += 1
	combol_count_text.set_combol_times(combol_count)
	combol_max = max(combol_max, combol_count)
	
	var kard_kind := randi_range(0,2)
	var kard2_kind := randi_range(0,2)
	
	mahjong.add_card(kard_kind)
	mahjong.add_card(kard2_kind)
	
	te_xiao.hit(kard_kind)
	te_xiao_2.hit(kard2_kind)
	
	flying_card.flying(track_e.last_e_pos, attack_q.position, Color.DARK_RED)
	flying_card.flying(track_e.last_e_pos, attack_q.position, Color.DARK_RED)
	
	$Hited.play(0)


## 较晚击中
func e_later_hit():
	combol_count += 1
	combol_count_text.set_combol_times(combol_count)
	
	var kard_kind := randi_range(0,2)
	
	mahjong.add_card(kard_kind)
	
	te_xiao.hit(kard_kind)
	
	flying_card.flying(track_e.last_e_pos, attack_q.position, Color.DARK_CYAN)
	
	$Hited.play(0)


## 太晚未命中
func e_too_late_miss():
	combol_count = 0
	combol_count_text.set_combol_times(combol_count)


func get_global_effect_volume_db(): # TODO 效果音量
	return 0


func _on_bgm_finished():
	# BGM 结束后一秒钟播放鼓掌声音
	await get_tree().create_timer(1.0).timeout
	$FinishEffect.volume_db = get_global_effect_volume_db()
	$FinishEffect.play()
	$FinalScore/LabelScore.text += " " + str(score)
	$FinalScore/LabelMaxCombol.text += " " + str(combol_max)
	$FinalScore.show()


func _on_button_quit_pressed():
	$AudioCDown.play()
	await get_tree().create_timer(1.0).timeout
	exit.emit(score)
