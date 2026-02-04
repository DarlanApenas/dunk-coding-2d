class_name Ball
extends CharacterBody2D

@export_category('BOUNCE')
@export var gravity := 900.0
@export var bounce := 0.6
@export var friction := 0.95

@export_category('VARIAVEIS')
@export var lifetime := 6.0  # segundos

@onready var sprite: Sprite2D = $ball
@onready var shadow: Sprite2D = $shadow
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var height: float = 0.0
var vertical_velocity: float = 0.0
var horizontal_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	
	# Timer de vida
	var timer: Timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_end)
	add_child(timer)
	timer.start()
	
	# Metadados
	set_meta("scored", false)
	set_meta("in_hoop_area", false)
	set_meta("rim_hit_registered", false)

func _physics_process(delta: float) -> void:
	# Física vertical (gravidade e quique)
	vertical_velocity -= gravity * delta
	height += vertical_velocity * delta
	
	# Chão
	if height <= 0.0:
		height = 0.0
		if abs(vertical_velocity) > 30.0:
			vertical_velocity = -vertical_velocity * bounce
			squash_and_stretch()
		else:
			vertical_velocity = 0.0
			squash_and_stretch()
		horizontal_velocity *= friction
	
	# Movimento horizontal
	velocity = horizontal_velocity
	move_and_slide()
	
	# Atualiza visual E collision
	update_visual()
	update_collision()  # NOVO

func update_visual() -> void:
	# Posição vertical da sprite (altura)
	sprite.position.y = -height
	
	# Escala da sombra baseada na altura
	var shadow_scale: float = clamp(
		1.0 - height / 200.0,
		0.4,
		1.0
	)
	shadow.scale = Vector2.ONE * shadow_scale

func update_collision() -> void:
	"""NOVO: Move o CollisionShape junto com a altura da bola"""
	if collision_shape:
		collision_shape.position.y = -height

func throw(direction: Vector2, force: float, arc_force: float) -> void:
	horizontal_velocity = direction.normalized() * force
	vertical_velocity = arc_force

func squash_and_stretch() -> void:
	sprite.scale = Vector2(1.3, 0.7)
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_lifetime_end() -> void:
	queue_free()

# Funções auxiliares

func get_height() -> float:
	return height

func get_vertical_velocity() -> float:
	return vertical_velocity

func is_falling() -> bool:
	return vertical_velocity < 0

func is_on_ground() -> bool:
	return height <= 0.0

func on_scored():
	"""Chamada quando a bola pontua"""
	set_meta("scored", true)
	# Efeitos visuais aqui
