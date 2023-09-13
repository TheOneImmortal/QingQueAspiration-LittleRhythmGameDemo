extends Control


@onready var score_times_label: Label = $"Score Times"


func set_score(combol_times: int) -> void:
	score_times_label.text = " " + var_to_str(combol_times) + " "
