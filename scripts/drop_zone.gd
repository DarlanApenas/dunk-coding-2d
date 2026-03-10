extends Node2D

@export var accepted_types: Array[String] = [
	"MOVE ←",
	"MOVE →",
	"MOVE ↑",
	"MOVE ↓",
	"SHOOT!",
	"DRIBBLE"
	]
@export var slot_height: float = 16.0
@export var snap_radius: float = 15.0
@onready var player: CharacterBody2D = $"../../Player"
var stack: Array = []

func try_add_block(block, insert_index: int = -1) -> bool:
	if not block.block_type in accepted_types:
		return false

	if insert_index == -1 or insert_index >= stack.size():
		insert_index = stack.size()
	insert_index = clamp(insert_index, 0, stack.size())

	stack.insert(insert_index, {
		"block": block,
		"type": block.block_type,
		"cost": block.block_cost
	})
	_reposition_all()
	return true
	
func remove_block(block):
	for i in stack.size():
		if stack[i]["block"] == block:
			stack.remove_at(i)
			break
	_reposition_all()

func get_insert_index(mouse_y: float) -> int:
	var local_y = mouse_y - global_position.y
	var index = int(local_y / slot_height)
	return clamp(index, 0, stack.size())

func is_near(point: Vector2) -> bool:
	return global_position.distance_to(point) < snap_radius

func _reposition_all():
	for i in stack.size():
		var block = stack[i]["block"]
		block.rest_point = global_position + Vector2(0, i * slot_height)

func _on_reset_button_pressed() -> void:
	LevelManager.reset()

func _on_run_button_pressed() -> void:
	GameEvents.run_pressed.emit(stack.duplicate())
	for entry in stack:
		entry["block"].in_grid = false
		entry["block"].current_zone = null
		entry["block"].rest_point = entry["block"].origin_position
	stack.clear()
