extends Node2D

@export_category("Grid Configuration")
@export var grid_columns: int = 3
@export var grid_rows: int = 3
@export var cell_size: int = 32
@export var cell_spacing: int = 16
@export var cell_texture: Texture2D
@export var draw_outline: bool = true
@export var line_color: Color = Color(1, 1, 1, 0.8)
@export var line_width: float = 2.0
@export var show_coordinates: bool = true

@export_category("Opponent Configuration")
@export var has_opponent: bool = false
@export var opponent_scene: PackedScene

# Dados do grid
var grid_cells: Array = []
var blocked_cells: Dictionary = {}

func _ready():
	add_to_group("grid")
	generate_grid()
	queue_redraw()
	if has_opponent:
		call_deferred("spawn_opponent")

func generate_grid():
	grid_cells.clear()
	for y in range(grid_rows):
		var row = []
		for x in range(grid_columns):
			var cell_pos = get_cell_position(x, y)
			row.append({
				"grid_x": x,
				"grid_y": y,
				"world_pos": cell_pos,
				"rect": Rect2(cell_pos, Vector2(cell_size, cell_size))
			})
		grid_cells.append(row)

func get_cell_position(grid_x: int, grid_y: int) -> Vector2:
	var x = grid_x * (cell_size + cell_spacing)
	var y = grid_y * (cell_size + cell_spacing)
	return Vector2(x, y) + global_position

func get_cell_center(grid_x: int, grid_y: int) -> Vector2:
	var pos = get_cell_position(grid_x, grid_y)
	return pos + Vector2(cell_size / 2.0, cell_size / 2.0)

func get_grid_total_size() -> Vector2:
	var width = (grid_columns * cell_size) + ((grid_columns - 1) * cell_spacing)
	var height = (grid_rows * cell_size) + ((grid_rows - 1) * cell_spacing)
	return Vector2(width, height)

func is_valid_cell(grid_x: int, grid_y: int) -> bool:
	if grid_x < 0 or grid_x >= grid_columns or grid_y < 0 or grid_y >= grid_rows:
		return false
	return not blocked_cells.has(Vector2i(grid_x, grid_y))

func block_cell(grid_x: int, grid_y: int) -> void:
	blocked_cells[Vector2i(grid_x, grid_y)] = true
	queue_redraw()

func unblock_cell(grid_x: int, grid_y: int) -> void:
	blocked_cells.erase(Vector2i(grid_x, grid_y))
	queue_redraw()

func spawn_opponent() -> void:
	if not opponent_scene:
		push_warning("Grid: opponent_scene está vazio!")
		return
	var opponent = opponent_scene.instantiate()
	opponent.grid = self
	get_tree().current_scene.add_child(opponent)
	print("Opponent adicionado na célula: ", opponent.current_grid_pos)
	print("Opponent posição mundial: ", opponent.global_position)
	

func get_cell_at_position(world_pos: Vector2) -> Vector2i:
	for y in range(grid_rows):
		for x in range(grid_columns):
			var cell = grid_cells[y][x]
			if cell.rect.has_point(world_pos):
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func _draw():
	for y in range(grid_rows):
		for x in range(grid_columns):
			if cell_texture:
				draw_cell_texture(x, y)
			if draw_outline:
				draw_cell_outline(x, y)
	if show_coordinates:
		for y in range(grid_rows):
			for x in range(grid_columns):
				draw_cell_coordinates(x, y)

func draw_cell_texture(grid_x: int, grid_y: int):
	if not cell_texture:
		return
	var cell = grid_cells[grid_y][grid_x]
	var pos = cell.world_pos - global_position
	draw_texture_rect(cell_texture, Rect2(pos, Vector2(cell_size, cell_size)), false)

func draw_cell_outline(grid_x: int, grid_y: int):
	var cell = grid_cells[grid_y][grid_x]
	var pos = cell.world_pos - global_position
	var size = Vector2(cell_size, cell_size)
	draw_rect(Rect2(pos, size), line_color, false, line_width)

func draw_cell_coordinates(grid_x: int, grid_y: int):
	var center = get_cell_center(grid_x, grid_y) - global_position
	var text = "[%d,%d]" % [grid_x, grid_y]
	var font = ThemeDB.fallback_font
	var font_size = 10
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_pos = center - text_size / 2.0
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 1, 0.6))

func get_cell_info(grid_x: int, grid_y: int) -> Dictionary:
	if not is_valid_cell(grid_x, grid_y):
		return {}
	return grid_cells[grid_y][grid_x]

func highlight_cell(grid_x: int, grid_y: int, color: Color = Color.YELLOW):
	if not is_valid_cell(grid_x, grid_y):
		return
	var cell = grid_cells[grid_y][grid_x]
	var pos = cell.world_pos - global_position
	var size = Vector2(cell_size, cell_size)
	draw_rect(Rect2(pos, size), color, false, line_width + 1.0)
