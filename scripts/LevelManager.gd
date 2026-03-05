extends Node

var levels := [
	"res://scenes/court_1.tscn",
	"res://scenes/court_2.tscn",
]

var current_index := 0

func next_level() -> void:
	current_index += 1
	if current_index >= levels.size():
		current_index = 0
	get_tree().change_scene_to_file(levels[current_index])

func reset() -> void:
	get_tree().reload_current_scene()
