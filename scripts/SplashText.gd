extends CanvasLayer
class_name SplashText

@onready var label: RichTextLabel = $RichTextLabel

@export var word := "SPLASH"
@export var letter_delay := 0.06
@export var visible_time := 0.6
@export var fade_time := 0.3

func _ready():
	label.visible = false
	label.bbcode_enabled = true
	label.clear()
	
func play():
	label.visible = true
	label.modulate.a = 1.0
	label.clear()

	var text := ""
	for i in word.length():
		text += word[i]
		label.text = "[b][font_size=7][center][rainbow][wave]%s[/wave][/rainbow][/center]" % text
		await get_tree().create_timer(letter_delay).timeout

	await get_tree().create_timer(visible_time).timeout
	await _fade_out()

func _fade_out():
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 0.0, fade_time)
	await tween.finished
	label.visible = false
