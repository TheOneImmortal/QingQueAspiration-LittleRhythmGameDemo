extends Node2D


signal game_start
signal game_exit

signal effect_volume_change(effect_volume_now)
signal volume_change(volume_now)

var effect_player_list

func _on_hud_game_button_quit_click():
	$Spectrum.stop()
	await get_tree().create_timer(1.0).timeout
	emit_signal("game_exit")


func _on_hud_game_button_start_game_click() -> void:
	$HUD/AudioC.play()
	await get_tree().create_timer(1.0).timeout
	emit_signal("game_start")
	print("startbuttonclick")


func _ready():
	effect_player_list = [
		$HUD/AudioC, $HUD/AudioD, $HUD/AudioDownC, $HUD/AudioE, $HUD/AudioF
	]
	var root_node = $"../.."
	_on_options_information_volume_change(root_node.main_volume)
	_on_options_information_effect_volume_change(root_node.effect_volume)

func _on_hud_game_button_options_click():
	$OptionsInformation.toggle_visibility()
	$AboutInfomation.hide()
	$HUD/AudioD.play()


func _on_hud_game_button_about_click():
	$AboutInfomation.toggle_visibility()
	$OptionsInformation.hide()
	$HUD/AudioE.play()

func _on_options_information_volume_change(volume_now):
	var root_node = $"../.."
	$Spectrum/AudioStreamPlayer.volume_db = root_node.get_volume_db_from_volume_now(volume_now)
	emit_signal("volume_change", volume_now)


func _on_options_information_effect_volume_change(effect_volume_now):
	var root_node = $"../.."
	for effect_player in effect_player_list:
		effect_player.volume_db = root_node.get_volume_db_from_volume_now(effect_volume_now)
	emit_signal("effect_volume_change", effect_volume_now)
