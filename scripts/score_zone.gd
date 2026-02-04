extends Area2D
class_name ScoreBox

@export var show_debug := true
@export var debug_width := 20.0

signal scored(ball)

@export var require_falling := true
@export var min_fall_speed := 20.0
@export var vertical_margin := 2.0 # tolerância de posição

func _ready():
	monitoring = true
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if not body is Ball:
		return

	if not _is_ball_from_above(body):
		return

	scored.emit(body)

func _is_ball_from_above(ball: Ball) -> bool:
	# 1️⃣ Bola precisa estar acima da ScoreBox
	if ball.global_position.y > global_position.y + vertical_margin:
		return false

	# 2️⃣ Bola precisa estar descendo
	if require_falling:
		if ball.vertical_velocity >= 0:
			return false

		if abs(ball.vertical_velocity) < min_fall_speed:
			return false

	return true
func _draw():
	if not show_debug:
		return

	# Linha horizontal de corte (entrada válida por cima)
	draw_line(
		Vector2(-debug_width, 0),
		Vector2(debug_width, 0),
		Color(1, 0, 0),
		1.0
	)
func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		queue_redraw()
