extends Control

@onready var combol_times_label: Label = $"Combol Times"

func set_combol_times(combol_times: int) -> void:
	combol_times_label.text = " " + var_to_str(combol_times) + " "
