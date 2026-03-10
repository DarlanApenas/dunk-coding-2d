extends Camera2D

@export var follow_speed := 5.0
@export var ball_follow_speed := 8.0
@export var return_speed := 10.0

var target: Node2D = null
var player: Node2D = null
var following_ball := false

func _ready() -> void:
	player = get_parent()
	target = player

func _process(delta: float) -> void:
	if target == null:
		target = player
	
	var speed := ball_follow_speed if following_ball else follow_speed
	global_position = global_position.lerp(target.global_position, speed * delta)

func follow_ball(ball: Node2D) -> void:
	target = ball
	following_ball = true
	ball.tree_exited.connect(_return_to_player)

func _return_to_player() -> void:
	target = player
	following_ball = false
