extends Node2D

@export var accepted_types: Array[String] = ["normal"]
@export var slot_height: float = 16.0
@export var snap_radius: float = 15.0

var stack: Array = []

func try_add_block(block, insert_index: int = -1) -> bool:
	if not block.block_type in accepted_types:
		return false

	# Define índice de inserção
	if insert_index == -1 or insert_index >= stack.size():
		insert_index = stack.size()

	insert_index = clamp(insert_index, 0, stack.size())
	stack.insert(insert_index, block)
	_reposition_all()
	return true

func remove_block(block):
	stack.erase(block)
	_reposition_all()

func get_insert_index(mouse_y: float) -> int:
	var local_y = mouse_y - global_position.y
	var index = int(local_y / slot_height)
	return clamp(index, 0, stack.size())

func is_near(point: Vector2) -> bool:
	return global_position.distance_to(point) < snap_radius

func _reposition_all():
	for i in stack.size():
		var block = stack[i]
		block.rest_point = global_position + Vector2(0, i * slot_height)
