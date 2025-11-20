extends Node2D

@export var min_x: float = -1000.0
@export var max_x: float = 1000.0
@export var min_y: float = -500.0
@export var max_y: float = 500.0
@export var mouse_sensitivity: Vector2 = Vector2(0.002, 0.005)
@export var smoothing: float = 10.0

var scroll_x: float = 0.5  # 0..1 along [min_x, max_x]
var scroll_y: float = 0.5

var can_scroll: bool = false

func _input(event: InputEvent) -> void:
	if can_scroll and event is InputEventMouseMotion:
		scroll_x -= event.relative.x * mouse_sensitivity.x
		scroll_x = clamp(scroll_x, 0.0, 1.0)
		
		scroll_y -= event.relative.y * mouse_sensitivity.y
		scroll_y = clamp(scroll_y, 0.0, 1.0)


func _process(delta: float) -> void:
	var target_x = lerp(min_x, max_x, scroll_x)
	position.x = lerp(position.x, target_x, smoothing * delta)
	
	var target_y = lerp(min_y, max_y, scroll_y)
	position.y = lerp(position.y, target_y, smoothing * delta)


func _on_assassin_game_begin() -> void:
	can_scroll = true


func _on_assassin_cleaning_up() -> void:
	can_scroll = false
