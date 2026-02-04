extends Area2D
@export var block_input_name: String
@export_category("Juicy")
@export var hover_scale: float = 1.15
@export var hover_duration: float = 0.2 
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
@export var trans_type: Tween.TransitionType = Tween.TRANS_BACK

var original_scale: Vector2 = Vector2.ONE
var is_hovered: bool = false
var current_tween: Tween

enum BLOCK_TYPE{
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_BACK,
	SHOOT,
	PASS
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = block_input_name
	original_scale = scale
	get_block_type_from_name(block_input_name)
	# Conecta sinais de mouse
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func get_block_type_from_name(block_input_name: String):
	match block_input_name:
		"move ←":
			return BLOCK_TYPE.MOVE_LEFT
		"move →":
			return BLOCK_TYPE.MOVE_RIGHT
		"move ↑":
			return BLOCK_TYPE.MOVE_UP
		_:
			print("Tipo de bloco não reconhecido: ", block_input_name)
			return -1
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
