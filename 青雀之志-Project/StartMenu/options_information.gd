extends CanvasLayer

@export var time_now = 0
@export var TIME_SHOW = 0.5 # second

@export_range(0, 100) var volume_now = 100
@export_range(0, 100) var effect_volume_now = 100

# 音量改变
signal volume_change(volume_now)
signal effect_volume_change(effect_volume_now)

func toggle_visibility():
	if self.visible:
		self.hide()
	else:
		self.show()
		time_now = 0

func get_alpha():
	if time_now > TIME_SHOW:
		return 1
	else:
		return time_now / TIME_SHOW

func set_main_volume_value():
	var new_volume = int($MainVolume.value)
	$LabelMainVolumeValue.text = str(new_volume) + "%"
	if new_volume != volume_now:
		emit_signal("volume_change", new_volume) # 带参数发出信号
	volume_now = new_volume

func get_volume_now_from_root():
	var root_node = $"../../.."
	return root_node.main_volume

func get_effect_volume_now_from_root():
	var root_node = $"../../.."
	return root_node.effect_volume

func _ready():
	volume_now = get_volume_now_from_root()
	effect_volume_now = get_effect_volume_now_from_root()
	print("get_volume_now_from_root", volume_now, effect_volume_now)
	$MainVolume.value = volume_now
	$EffectVolume.value = effect_volume_now
	set_volumn_value()

func set_effect_volume_value():
	var new_volume = int($EffectVolume.value)
	$LabelEffectVolumeValue.text = str(new_volume) + "%"
	if new_volume != effect_volume_now:
		emit_signal("effect_volume_change", new_volume) # 带参数发出信号
	effect_volume_now = new_volume

func set_volumn_value():
	set_main_volume_value()
	set_effect_volume_value()

func _process(delta):
	time_now += delta
	$ColorRect.modulate.a = get_alpha()
	set_volumn_value()

func _on_button_pressed():
	toggle_visibility()
	$"../HUD/AudioDownC".play()
