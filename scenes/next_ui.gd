extends CanvasLayer

@onready var hoop: Node2D = $"../Hoop"
@onready var panel: Panel = $Panel

func _ready() -> void:
	visible = false
	hoop.scored.connect(_on_scored)

func _on_scored() -> void:
	visible = true
	panel.scale = Vector2.ZERO
	panel.pivot_offset = panel.size / 2.0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.35)

func _on_next_button_pressed() -> void:
	LevelManager.next_level()
