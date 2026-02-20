extends Node2D

@export_category("Grid Configuration")
@export var grid_columns: int = 3
@export var grid_rows: int = 3
@export var cell_size: int = 32
@export var cell_spacing: int = 16

@export_category("Visual")
@export var cell_texture: Texture2D
@export var draw_outline: bool = true
@export var line_color: Color = Color(1, 1, 1, 0.8)
@export var line_width: float = 2.0
@export var show_coordinates: bool = true

# Dados do grid
var grid_cells: Array = [] 

func _ready():
	add_to_group("grid")
	generate_grid()
	queue_redraw()

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
	# print("✓ ", grid_columns * grid_rows, " células geradas")

func get_cell_position(grid_x: int, grid_y: int) -> Vector2:
	"""Retorna a posição mundial (top-left) de uma célula do grid"""
	var x = grid_x * (cell_size + cell_spacing)
	var y = grid_y * (cell_size + cell_spacing)
	return Vector2(x, y) + global_position

func get_cell_center(grid_x: int, grid_y: int) -> Vector2:
	var pos = get_cell_position(grid_x, grid_y)
	return pos + Vector2(cell_size / 2.0, cell_size / 2.0)

func get_grid_total_size() -> Vector2:
	"""Retorna o tamanho total do grid em pixels"""
	var width = (grid_columns * cell_size) + ((grid_columns - 1) * cell_spacing)
	var height = (grid_rows * cell_size) + ((grid_rows - 1) * cell_spacing)
	return Vector2(width, height)

func is_valid_cell(grid_x: int, grid_y: int) -> bool:
	"""Verifica se uma coordenada de grid é válida"""
	return grid_x >= 0 and grid_x < grid_columns and grid_y >= 0 and grid_y < grid_rows

func get_cell_at_position(world_pos: Vector2) -> Vector2i:
	"""Retorna a coordenada do grid baseada em uma posição mundial"""
	var local_pos = world_pos - global_position
	
	for y in range(grid_rows):
		for x in range(grid_columns):
			var cell = grid_cells[y][x]
			if cell.rect.has_point(world_pos):
				return Vector2i(x, y)
	return Vector2i(-1, -1)  # Fora do grid

func _draw():
	"""Desenha o grid (texturas e/ou contornos)"""
	for y in range(grid_rows):
		for x in range(grid_columns):
			# Desenha textura se houver
			if cell_texture:
				draw_cell_texture(x, y)
			
			# Desenha contorno se habilitado
			if draw_outline:
				draw_cell_outline(x, y)
	
	# Coordenadas por último (aparecem por cima)
	if show_coordinates:
		for y in range(grid_rows):
			for x in range(grid_columns):
				draw_cell_coordinates(x, y)

func draw_cell_texture(grid_x: int, grid_y: int):
	"""Desenha a textura de uma célula"""
	if not cell_texture:
		return
	
	var cell = grid_cells[grid_y][grid_x]
	var pos = cell.world_pos - global_position
	
	# Desenha a textura
	# Se a textura não for 32x32, ela será esticada/encolhida
	draw_texture_rect(
		cell_texture,
		Rect2(pos, Vector2(cell_size, cell_size)),
		false  # tile = false (estica a textura)
	)

func draw_cell_outline(grid_x: int, grid_y: int):
	"""Desenha o contorno de uma célula"""
	var cell = grid_cells[grid_y][grid_x]
	var pos = cell.world_pos - global_position  # Posição local para desenho
	var size = Vector2(cell_size, cell_size)
	
	# Desenha retângulo (apenas borda)
	draw_rect(Rect2(pos, size), line_color, false, line_width)

func draw_cell_coordinates(grid_x: int, grid_y: int):
	"""Desenha as coordenadas [x,y] no centro da célula"""
	var center = get_cell_center(grid_x, grid_y) - global_position
	var text = "[%d,%d]" % [grid_x, grid_y]
	
	# Desenha texto centralizado
	var font = ThemeDB.fallback_font
	var font_size = 10
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_pos = center - text_size / 2.0
	
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 1, 0.6))

# Funções utilitárias para outros scripts

func get_cell_info(grid_x: int, grid_y: int) -> Dictionary:
	"""Retorna informações sobre uma célula"""
	if not is_valid_cell(grid_x, grid_y):
		return {}
	return grid_cells[grid_y][grid_x]

func highlight_cell(grid_x: int, grid_y: int, color: Color = Color.YELLOW):
	"""Destaca uma célula (precisa chamar queue_redraw depois)"""
	if not is_valid_cell(grid_x, grid_y):
		return
	
	var cell = grid_cells[grid_y][grid_x]
	var pos = cell.world_pos - global_position
	var size = Vector2(cell_size, cell_size)
	
	draw_rect(Rect2(pos, size), color, false, line_width + 1.0)
