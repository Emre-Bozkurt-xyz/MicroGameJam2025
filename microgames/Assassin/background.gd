extends Node2D

@export var min_x: float = -1000.0
@export var max_x: float = 1000.0
@export var mouse_sensitivity: float = 0.002
@export var smoothing: float = 10.0

var scroll_t: float = 0.5  # 0..1 along [min_x, max_x]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		scroll_t -= event.relative.x * mouse_sensitivity
		scroll_t = clamp(scroll_t, 0.0, 1.0)

func _process(delta: float) -> void:
	var target_x = lerp(min_x, max_x, scroll_t)
	position.x = lerp(position.x, target_x, smoothing * delta)
