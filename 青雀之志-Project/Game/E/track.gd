extends Node2D
## 鼓点轨道
class_name Track


## 尝试在检测区内空时打击
signal meaningless_try
## 太早未命中
signal too_eraly_miss
## 较早击中
signal earlier_hit
## 完美击中
signal prefect_hit
## 较晚击中
signal later_hit
## 太晚未命中
signal too_late_miss

@export_group("环设置")
## 外圈鼓点接近速度
@export_range(1, 1000, 0.5, "suffix: /s") var outside_speed: float = 100
## 内圈鼓点接近速度
@export_range(1, 1000, 0.5, "suffix: /s") var inside_speed: float = 300
## 内外圈半径
@export_range(198, 328, 0.5) var ioside_radius: float = 198 :
	set(value):
		ioside_radius = value
		
		if !is_node_ready():
			return
		
		ioside_range.scale = (value / 198) * Vector2.ONE
## 判定环半径
@export_range(98, 198, 0.5) var check_radius: float = 98 :
	set(value):
		check_radius = value
		
		if !is_node_ready():
			return
		
		check_e.scale = (value / 98) * Vector2.ONE

@export_group("判定范围")
@export var start_check: float = -1
@export var start_ok: float = -0.5
@export var start_prefect: float = -0.1
@export var end_prefect: float = 0.1
@export var end_ok: float = 0.5
@export var end_check: float = 1

@export_group("动画","motion_")
@export var motion_normal_lighting_size: Vector2 = Vector2(1, 1)
@export var motion_emphasize_lighting_size: Vector2 = Vector2(1.4, 1.4)
@export var motion_normal_lighting_color: Color = Color.TRANSPARENT
@export var motion_miss_lighting_color: Color = Color.CORNFLOWER_BLUE
@export var motion_ok_lighting_color: Color = Color.DARK_SEA_GREEN
@export var motion_prefect_lighting_color: Color = Color.GOLD

var music_timer: Timer

var drumbeat_times: Array[float]
var drumbeats: Array[Drumbeat]
var now_chack: int = 0

var hited_tween: Tween
var lighting_tween: Tween

var last_e_pos: Vector2

const drumbeat_template: PackedScene = preload("res://Game/E/Drumbeat/drumbeat.tscn")
const little_boom := preload("res://SpecialEffects/little_boom.tscn")

@onready var lighting_dumbeats: Node2D = $"Lighting Dumbeats"
@onready var drumbeats_node: Node2D = $Drumbeats
@onready var lighting: Sprite2D = $Lighting
@onready var ioside_range: Node2D = $"Ioside Range"
@onready var check_e: Node2D = $"Check E"
@onready var boom_rings: BoomRings = $"Boom Rings"


func _ready() -> void:
	ioside_range.scale = (ioside_radius / 198) * Vector2.ONE
	check_e.scale = (check_radius / 98) * Vector2.ONE


func _process(delta: float) -> void:
	update_drumbeats_position()


func _physics_process(delta: float) -> void:
	var nowtime: float = music_timer.wait_time - music_timer.time_left
	
	if now_chack < drumbeats.size():
		var now_chack_drumbeat := drumbeats[now_chack]
		# 晚打，完蛋
		if nowtime - now_chack_drumbeat.wait_time > end_check:
			now_chack_drumbeat.miss()
			now_chack += 1
			too_late_missing(now_chack_drumbeat)


## 新歌开始时调用，初始化鼓点
func start(bgm_drumbeats_times: Array[float], timer: Timer) -> void:
	drumbeat_times = bgm_drumbeats_times
	music_timer = timer
	
	# 节点就绪后继续执行
	if !is_node_ready():
		await ready
	
	for drumbeat_time in drumbeat_times:
		var drumbeat: Drumbeat = drumbeat_template.instantiate()
		drumbeat.wait_time = drumbeat_time
		drumbeat.flying_angle = randf_range(0, 2 * PI)
		
		drumbeats.append(drumbeat)
		drumbeats_node.add_child(drumbeat)
	
	update_drumbeats_position()


## 重新播放本首歌时调用
func restart() -> void:
	now_chack = 0
	
	for drumbeat in drumbeats:
		drumbeat.get_parent().remove_child(drumbeat)
		
		drumbeat.reset()
		drumbeat.flying_angle = randf_range(0, 2 * PI)
		
		drumbeats_node.add_child(drumbeat)
	
	update_drumbeats_position()


## 更新鼓点的位置
func update_drumbeats_position() -> void:
	var nowtime: float = music_timer.wait_time - music_timer.time_left
	
	for drumbeat in drumbeats_node.get_children():
		update_drumbeat_position(drumbeat, drumbeat.wait_time - nowtime)


## 更新单个鼓点的位置
func update_drumbeat_position(drumbeat: Drumbeat, time: float) -> void:
	var dir := Vector2.from_angle(drumbeat.flying_angle)
	
	var target_pos: Vector2
	var just_inside_speed_length := (check_radius + inside_speed * time)
	# 内圈
	if just_inside_speed_length < ioside_radius:
		target_pos = dir * (just_inside_speed_length)
	# 外圈
	else:
		var left_length := just_inside_speed_length - ioside_radius
		var outside_length := left_length * outside_speed / inside_speed
		target_pos = dir * (ioside_radius + outside_length)
	drumbeat.position = target_pos


## 尝试打击
func try_hit() -> void:
	try_hit_anmi()
	
	# 全走完了，不用检查了
	if now_chack >= drumbeats.size():
		return
	
	var now_chack_drumbeat := drumbeats[now_chack]
	
	var nowtime: float = music_timer.wait_time - music_timer.time_left
	var time_difference = nowtime - now_chack_drumbeat.wait_time
	
	# 接近，打击
	if (time_difference < end_ok
		and time_difference > start_ok):
		now_chack_drumbeat.hit()
		now_chack += 1
		now_chack_drumbeat.get_parent().remove_child(now_chack_drumbeat)
		lighting_dumbeats.add_child(now_chack_drumbeat)
		
		var boom := little_boom.instantiate() as Node2D
		boom.position = now_chack_drumbeat.position
		add_child(boom)
		
		# 完美检测
		if (time_difference < end_prefect
			and time_difference > start_prefect):
			prefect_hiting(now_chack_drumbeat)
		elif time_difference < start_prefect:
			earlier_hiting(now_chack_drumbeat)
		else:
			later_hiting(now_chack_drumbeat)
	# 早打，完蛋
	elif (time_difference < 0
		and time_difference > start_check):
		#print("早打: [Time]", nowtime, "[number]", now_chack, "[difference]", time_difference)
		now_chack_drumbeat.miss()
		now_chack += 1
		too_eraly_missing(now_chack_drumbeat)
		now_chack_drumbeat.get_parent().remove_child(now_chack_drumbeat)
		lighting_dumbeats.add_child(now_chack_drumbeat)
	# 晚打，完蛋
	elif time_difference > 0:
		#print("晚打: [Time]", nowtime, "[number]", now_chack, "[difference]", time_difference)
		now_chack_drumbeat.miss()
		now_chack += 1
		too_late_missing(now_chack_drumbeat)
		now_chack_drumbeat.get_parent().remove_child(now_chack_drumbeat)
		lighting_dumbeats.add_child(now_chack_drumbeat)
	else:
		meaningless_trying()


func try_hit_anmi() -> void:
	if hited_tween:
		hited_tween.kill()
	hited_tween = create_tween()
	hited_tween.tween_property($E, "scale", Vector2(0.8, 0.8), 0.05)
	hited_tween.tween_property($E, "scale", Vector2(1, 1), 0.05)


## 尝试在检测区内空时打击
func meaningless_trying() -> void:
	emit_signal("meaningless_try")


## 太早未命中
func too_eraly_missing(drumbeat: Drumbeat) -> void:
	anmi_lighting(motion_miss_lighting_color, motion_emphasize_lighting_size)
	
	last_e_pos = drumbeat.global_position
	
	emit_signal("too_eraly_miss")


## 较早击中
func earlier_hiting(drumbeat: Drumbeat) -> void:
	anmi_lighting(motion_ok_lighting_color, motion_emphasize_lighting_size)
	boom_rings.boom(ioside_radius, motion_ok_lighting_color)
	
	last_e_pos = drumbeat.global_position
	
	emit_signal("earlier_hit")


## 完美击中
func prefect_hiting(drumbeat: Drumbeat) -> void:
	anmi_lighting(motion_prefect_lighting_color, motion_emphasize_lighting_size)
	boom_rings.boom(ioside_radius, motion_prefect_lighting_color)
	
	last_e_pos = drumbeat.global_position
	
	emit_signal("prefect_hit")


## 较晚击中
func later_hiting(drumbeat: Drumbeat) -> void:
	anmi_lighting(motion_ok_lighting_color, motion_emphasize_lighting_size)
	boom_rings.boom(ioside_radius, motion_ok_lighting_color)
	
	last_e_pos = drumbeat.global_position
	
	emit_signal("later_hit")


## 太晚未命中
func too_late_missing(drumbeat: Drumbeat) -> void:
	anmi_lighting(motion_miss_lighting_color, motion_emphasize_lighting_size)
	
	last_e_pos = drumbeat.global_position
	
	emit_signal("too_late_miss")


func anmi_lighting(color: Color, size: Vector2) -> void:
	if lighting_tween:
		lighting_tween.kill()
	lighting_tween = create_tween().set_parallel()
	
	var color_trans := color;
	color_trans.a = 0;
	
	lighting.scale = motion_normal_lighting_size
	lighting.self_modulate = motion_normal_lighting_color
	
	lighting_tween.tween_property(lighting, "scale", size, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lighting_tween.tween_property(lighting, "self_modulate", color, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lighting_tween.tween_property(check_e, "modulate", color, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lighting_tween.tween_property(ioside_range, "modulate", color, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lighting_tween.chain()
	lighting_tween.tween_property(lighting, "scale", motion_normal_lighting_size, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lighting_tween.tween_property(lighting, "self_modulate", color_trans, 0.7).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	lighting_tween.tween_property(check_e, "modulate", Color.WHITE, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	lighting_tween.tween_property(ioside_range, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
