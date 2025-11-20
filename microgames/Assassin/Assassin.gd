extends Microgame

@onready var scope: TextureRect = %Scope
var base_scale: Vector2
var scope_tween: Tween

@onready var gunshot: AudioStreamPlayer2D = $Gunshot

@onready var gun_cd_timer: Timer = $GunCDTimer
@export var gun_cd: float = 1.0
var gun_flag: bool = true

func _ready() -> void:
	super()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	gun_cd_timer.wait_time = gun_cd

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	
	if event.is_action_pressed("mouse_left"):
		attempt_fire()

func attempt_fire():
	if not gun_flag:
		return
	gun_flag = false
	
	gun_cd_timer.start()
	
	var hit := _check_hit()
	if hit:
		var victim = hit.collider
		if victim.is_in_group("assassin_victim"):
			print("HIT victim: ", victim.name)
		
	gunshot.play()
	_pump_scope()
	
	await gun_cd_timer.timeout
	
	gun_flag = true

func _check_hit() -> Dictionary:
	var marker: Node2D = scope.get_node("Marker")
	var marker_pos: Vector2 = marker.global_position

	var space_state := get_world_2d().direct_space_state

	var params := PhysicsPointQueryParameters2D.new()
	params.position = marker_pos
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var results: Array = space_state.intersect_point(params, 8)
	if results.size() > 0:
		return results[0] 
	return {}


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
