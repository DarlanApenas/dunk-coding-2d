extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var ball_scene: PackedScene
@export var throw_force := 180.0
@export var throw_arc := 350.0
@export var grid: Node2D

const SPEED := 60.0

var is_doing_action := false
var active_ball: Ball = null
var is_shooting := false
var ball_released := false

@export var sprite_offset: Vector2 = Vector2(0, 12)  # Offset para pés no chão
var current_grid_pos: Vector2i = Vector2i(0, 1)
var is_moving_grid := false
var move_duration := 1

func _ready():
	# Tenta encontrar o grid automaticamente
	if not grid:
		grid = get_tree().get_first_node_in_group("grid")
	# Posiciona o player na célula inicial [0,1]
	if grid:
		snap_to_grid(current_grid_pos.x, current_grid_pos.y)
		# print("✓ Player iniciado na célula [0,1]")

func _physics_process(_delta: float) -> void:
	if is_doing_action or is_moving_grid:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Input.is_action_just_pressed("dribble"):
		play_dribble()
	# Detecta input de movimento
	if Input.is_action_just_pressed("right"):
		move_grid(1, 0)
	elif Input.is_action_just_pressed("left"):
		move_grid(-1, 0)
	elif Input.is_action_just_pressed("down"):
		move_grid(0, 1)
	elif Input.is_action_just_pressed("up"):
		move_grid(0, -1)

func move_grid(dx: int, dy: int):
	if not grid or is_moving_grid:
		return
	
	var new_x = current_grid_pos.x + dx
	var new_y = current_grid_pos.y + dy
	
	# Valida movimento
	if not grid.is_valid_cell(new_x, new_y):
		return
	
	# Atualiza flip baseado na direção
	if dx > 0:
		anim.flip_h = false
	elif dx < 0:
		anim.flip_h = true
	
	# Inicia animação de correr
	anim.play("run_wball")
	
	# Move
	current_grid_pos = Vector2i(new_x, new_y)
	is_moving_grid = true
	
	# Anima movimento
	var target_pos = grid.get_cell_center(new_x, new_y)
	animate_to_position(target_pos)
	
	#print("→ Moveu para [%d,%d]" % [new_x, new_y])

func animate_to_position(target: Vector2):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", target - sprite_offset, move_duration)
	tween.finished.connect(_on_move_finished)

func _on_move_finished():
	is_moving_grid = false
	# Volta para animação idle
	anim.play("idle_bouncing")

func snap_to_grid(grid_x: int, grid_y: int):
	if not grid:
		return
	
	if not grid.is_valid_cell(grid_x, grid_y):
		#print("⚠️ Célula inválida: [%d,%d]" % [grid_x, grid_y])
		return
	
	current_grid_pos = Vector2i(grid_x, grid_y)
	var target_pos = grid.get_cell_center(grid_x, grid_y)
	
	global_position = target_pos - sprite_offset
	
	#print("📍 Player posicionado em [%d,%d]" % [grid_x, grid_y])

func throw_ball() -> void:
	if active_ball != null:
		return
	var ball: Ball = ball_scene.instantiate()
	get_parent().add_child(ball)
	ball.global_position = global_position
	active_ball = ball
	ball.tree_exited.connect(func():
		active_ball = null
	)
	var dir := Vector2.RIGHT if not anim.flip_h else Vector2.LEFT
	ball.throw(dir, throw_force, throw_arc)

func play_dribble() -> void:
	if is_doing_action:
		return
	is_doing_action = true
	velocity = Vector2.ZERO
	anim.play("fast_cross")
	if not anim.animation_finished.is_connected(_on_action_finished):
		anim.animation_finished.connect(_on_action_finished)

func shoot() -> void:
	if is_doing_action or active_ball != null:
		return
	is_doing_action = true
	is_shooting = true
	ball_released = false
	velocity = Vector2.ZERO
	anim.play("shooting")
	if not anim.frame_changed.is_connected(_on_shoot_frame):
		anim.frame_changed.connect(_on_shoot_frame)
	if not anim.animation_finished.is_connected(_on_shoot_finished):
		anim.animation_finished.connect(_on_shoot_finished)

func _on_shoot_frame() -> void:
	if not is_shooting:
		return
	# frame 5 da animação
	if anim.frame == 4 and not ball_released:
		ball_released = true
		throw_ball()

func _on_shoot_finished() -> void:
	is_doing_action = false
	is_shooting = false
	if anim.frame_changed.is_connected(_on_shoot_frame):
		anim.frame_changed.disconnect(_on_shoot_frame)
	if anim.animation_finished.is_connected(_on_shoot_finished):
		anim.animation_finished.disconnect(_on_shoot_finished)
		anim.play("idle_bouncing")

func _on_action_finished() -> void:
	is_doing_action = false
	anim.animation_finished.disconnect(_on_action_finished)
	anim.play("idle_bouncing")
