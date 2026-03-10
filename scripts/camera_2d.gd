extends Camera2D

@export var follow_speed := 5.0
@export var ball_follow_speed := 8.0
@export var return_speed := 10.0
@export var ball_zoom := Vector2(1.5, 1.5)
@export var zoom_duration := 0.3
@export var bounce_follow_speed := 15.0

var target: Node2D = null
var player: Node2D = null
var following_ball := false

func _ready() -> void:
	player = get_parent()
	target = player

func _process(delta: float) -> void:
	if target == null:
		target = player
	
	var speed: float
	if following_ball and target is Ball:
		speed = bounce_follow_speed if target._bounce_active else ball_follow_speed
	else:
		speed = follow_speed
	
	var target_pos: Vector2
	if following_ball and target is Ball:
		target_pos = target.get_visual_position()
	else:
		target_pos = target.global_position
	
	global_position = global_position.lerp(target_pos, speed * delta)
func follow_ball(ball: Node2D) -> void:
	target = ball
	following_ball = true
	_tween_zoom(ball_zoom)
	ball.tree_exited.connect(_return_to_player)

func _return_to_player() -> void:
	target = player
	following_ball = false
	_tween_zoom(Vector2.ONE) 
	
func _tween_zoom(target_zoom: Vector2) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "zoom", target_zoom, zoom_duration)
