extends Area2D
@export_category("Juicy")
@export var hover_scale: float = 1.15
@export var hover_duration: float = 0.2 
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_BACK

var original_scale: Vector2 = Vector2.ONE
var is_hovered: bool = false
var current_tween: Tween

func _ready() -> void:
	original_scale = scale
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	is_hovered = true
	animate_scale(original_scale * hover_scale)

func _on_mouse_exited():
	is_hovered = false
	animate_scale(original_scale)

func animate_scale(target_scale: Vector2):
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.set_ease(ease_type)
	current_tween.set_trans(trans_type)
	current_tween.tween_property(self, "scale", target_scale, hover_duration)
