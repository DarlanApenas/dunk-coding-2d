extends Node2D

@onready var score_zone: ScoreBox = $ScoreZone
@onready var net_sprite: AnimatedSprite2D = $NetSprite
@onready var splash_text: SplashText = $Text

func _ready():
	score_zone.body_entered.connect(_on_score_zone_body_entered)
	
func _on_score_zone_body_entered(body: Node2D) -> void:
	if body is Ball:
		play_net_squash_stretch(abs(body.vertical_velocity) / 300.0)
		splash_text.play()

func play_net_squash_stretch(force := 1.0):
	var squash := Vector2(1.1 + 0.1 * force, 0.8 - 0.1 * force)
	var stretch := Vector2(0.95, 1.2 + 0.1 * force)

	var tween := create_tween()
	tween.tween_property(net_sprite, "scale", squash, 0.07)
	tween.tween_property(net_sprite, "scale", stretch, 0.1)
	tween.tween_property(net_sprite, "scale", Vector2.ONE, 0.12)
