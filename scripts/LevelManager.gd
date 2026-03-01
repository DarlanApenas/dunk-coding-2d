extends Node

var levels := [
	"res://scenes/game.tscn",
	"res://scenes/court_2.tscn",
]

var current_index := 0

func next_level() -> void:
	current_index += 1
	if current_index >= levels.size():
		current_index = 0  # volta pro início ou vai pra tela de vitória
	get_tree().change_scene_to_file(levels[current_index])

func reset() -> void:
	get_tree().reload_current_scene()
