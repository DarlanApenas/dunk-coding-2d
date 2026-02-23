extends Node2D

@export var block_type: String = ""
@onready var label: Label = $Block/Label

var selected = false
var in_grid = false
var current_zone = null
var rest_point = Vector2.ZERO
var origin_position = Vector2.ZERO

func _ready():
	label.text = block_type
	origin_position = global_position
	rest_point = global_position

func _on_block_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if Input.is_action_just_pressed("draggable_click"):
		selected = true
		if in_grid and current_zone != null:
			current_zone.remove_block(self)
			current_zone = null
			in_grid = false

func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	else:
		global_position = lerp(global_position, rest_point, 10 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not selected:
				return
			selected = false

			var zone = _find_closest_zone()
			if zone == null:
				rest_point = origin_position
				return

			var insert_index = zone.get_insert_index(get_global_mouse_position().y)
			var accepted = zone.try_add_block(self, insert_index)

			if accepted:
				in_grid = true
				current_zone = zone
			else:
				rest_point = origin_position

func _find_closest_zone() -> Node:
	var zones = get_tree().get_nodes_in_group("zone")
	for zone in zones:
		if zone.is_near(get_global_mouse_position()):
			return zone
	return null
