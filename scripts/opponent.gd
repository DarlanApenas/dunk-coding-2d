extends CharacterBody2D

@export var forbidden_cells: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, 1),
	Vector2i(0, 2),
	Vector2i(2, 0),
]
@export var sprite_offset: Vector2 = Vector2(2, 16)
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var grid: Node2D
var current_grid_pos: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	add_to_group("opponent")
	anim.flip_h = true
	anim.play("idle")
	#place_at(1, 2)
	spawn_random()

func spawn_random() -> void:
	var free_cells: Array = []
	for y in range(grid.grid_rows):
		for x in range(grid.grid_columns):
			var cell := Vector2i(x, y)
			if grid.is_valid_cell(x, y) and not forbidden_cells.has(cell) and _is_cell_safe(cell):
				free_cells.append(cell)
	if free_cells.is_empty():
		push_warning("Opponent: nenhuma célula disponível!")
		return
	
	var chosen: Vector2i = free_cells[randi() % free_cells.size()]
	place_at(chosen.x, chosen.y)

func place_at(grid_x: int, grid_y: int) -> void:
	if current_grid_pos != Vector2i(-1, -1):
		grid.unblock_cell(current_grid_pos.x, current_grid_pos.y)
	
	current_grid_pos = Vector2i(grid_x, grid_y)
	grid.block_cell(grid_x, grid_y)
	global_position = grid.get_cell_center(grid_x, grid_y) - sprite_offset
	
func get_spawn_cell() -> Vector2i:
	return current_grid_pos
	
func _is_cell_safe(cell: Vector2i) -> bool:
	for opponent in get_tree().get_nodes_in_group("opponent"):
		if opponent == self:
			continue
		# célula já ocupada
		if opponent.current_grid_pos == cell:
			return false
		# célula está na frente de outro oponente
		var their_front = opponent.current_grid_pos + (Vector2i(-1, 0) if not opponent.anim.flip_h else Vector2i(1, 0))
		if their_front == cell:
			return false
		# outro oponente está na frente dessa célula
		var my_front := cell + (Vector2i(-1, 0) if not anim.flip_h else Vector2i(1, 0))
		if opponent.current_grid_pos == my_front:
			return false
	return true

func block_shot() -> void:
	anim.play("block")
	await anim.animation_finished
	anim.play("idle")

func _exit_tree() -> void:
	if grid and current_grid_pos != Vector2i(-1, -1):
		grid.unblock_cell(current_grid_pos.x, current_grid_pos.y)
