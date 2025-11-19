extends Camera2D

@export var min_x: float = -1000.0
@export var max_x: float = 1000.0

func _process(delta: float) -> void:
	var vp_size = get_viewport().get_visible_rect().size
	var mouse_x = get_viewport().get_mouse_position().x

	# Map mouse 0..width -> 0..1
	var t = clamp(mouse_x / vp_size.x, 0.0, 1.0)

	# Lerp camera within building span
	var target_x = lerp(min_x, max_x, t)
	global_position.x = lerp(global_position.x, target_x, 10.0 * delta)
