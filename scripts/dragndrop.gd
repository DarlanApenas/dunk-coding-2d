extends Node2D
# https://www.youtube.com/watch?v=iSpWZzL2i1o

var selected  = false


func _on_block_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("draggable_click"):
		selected = true

func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position,get_global_mouse_position(), 25 * delta)
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
	
