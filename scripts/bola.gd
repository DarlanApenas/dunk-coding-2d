class_name Ball
extends CharacterBody2D

@export_category('ARREMESSO')
@export var gravity := 900.0
@export var arc_height := 5.0       # arco estético — ajuste no inspetor
@export var flight_time_scale := 50.0  # divisor da distância pro tempo de voo

@export_category('VARIAVEIS')
@export var lifetime := 6.0

@export_category('BOUNCE')
@export var bounce := 0.6
@export var friction := 0.95
@export var ground_offset: float = 0.0  # define onde é o "chão" após a cesta

@onready var sprite: Sprite2D = $ball
@onready var shadow: Sprite2D = $shadow
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var height: float = 0.0
var vertical_velocity: float = 0.0
var horizontal_velocity: Vector2 = Vector2.ZERO
var _bounce_active: bool = false  # false = indo para cesta | true = física livre

func _ready() -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_end)
	add_child(timer)
	timer.start()

	set_meta("scored", false)

func _physics_process(delta: float) -> void:
	vertical_velocity -= gravity * delta
	height += vertical_velocity * delta

	if _bounce_active and height <= ground_offset:
		height = ground_offset
		if abs(vertical_velocity) > 30.0:
			vertical_velocity = -vertical_velocity * bounce
			squash_and_stretch()
		else:
			vertical_velocity = 0.0
			horizontal_velocity = Vector2.ZERO
		horizontal_velocity *= friction
	elif not _bounce_active and height <= 0.0:
		# Segurança: se nunca entrou no ScoreZone, para no chão
		height = 0.0
		vertical_velocity = 0.0
		horizontal_velocity = Vector2.ZERO

	velocity = horizontal_velocity
	move_and_slide()
	update_visual()
	update_collision()

func update_visual() -> void:
	sprite.position.y = -height
	var shadow_scale: float = clamp(1.0 - height / 200.0, 0.4, 1.0)
	shadow.scale = Vector2.ONE * shadow_scale

func update_collision() -> void:
	if collision_shape:
		collision_shape.position.y = -height

func throw(target_global_pos: Vector2) -> void:
	var displacement: Vector2 = target_global_pos - global_position
	var distance: float = displacement.length()
	var ft: float = clamp(distance / flight_time_scale, 0.4, 1.2)

	horizontal_velocity = displacement / ft
	height = 0.0
	vertical_velocity = (arc_height + 0.5 * gravity * ft * ft) / ft

func activate_bounce() -> void:
	"""Chamada pelo Hoop quando a bola entra no ScoreZone"""
	_bounce_active = true

func squash_and_stretch() -> void:
	sprite.scale = Vector2(1.3, 0.7)
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func _on_lifetime_end() -> void:
	queue_free()

func is_falling() -> bool:
	return vertical_velocity < 0

func is_on_ground() -> bool:
	return height <= ground_offset

func on_scored() -> void:
	set_meta("scored", true)
