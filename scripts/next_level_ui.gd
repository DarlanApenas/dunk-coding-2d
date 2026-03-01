extends Control

@onready var hoop: Node2D = $"../Hoop"
@onready var panel: Panel = $Panel

func _ready() -> void:
	hide()
	hoop.scored.connect(_on_scored)

func _on_scored() -> void:
	show()
	scale = Vector2.ZERO
	pivot_offset = size / 2.0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ONE, 0.35)

func _on_next_button_pressed() -> void:
	LevelManager.next_level()

func _on_reset_button_up() -> void:
	LevelManager.reset()
