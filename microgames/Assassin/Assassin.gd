extends Microgame

@onready var scope: TextureRect = %Scope
var base_scale: Vector2
var scope_tween: Tween

@onready var gunshot: AudioStreamPlayer2D = $Gunshot

func _ready() -> void:
	super()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	
	if event.is_action_pressed("mouse_left"):
		gunshot.play()
		
		_pump_scope()

func _pump_scope() -> void:
	# stop previous tween if still running
	if scope_tween and scope_tween.is_valid():
		scope_tween.kill()

	scope.scale = base_scale

	scope_tween = create_tween()
	# quick grow
	scope_tween.tween_property(
		scope, "scale", base_scale * 1.1, 0.05
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# slower return
	scope_tween.tween_property(
		scope, "scale", base_scale, 0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

func _process(delta: float) -> void:
	
	var we_won := false
	var we_lost := false
	
	
	if we_won:
		win_game.emit()
	
	if we_lost:
		lose_game.emit()
