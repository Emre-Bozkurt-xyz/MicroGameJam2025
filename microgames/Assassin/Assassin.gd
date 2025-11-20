extends Microgame

signal game_begin
signal cleaning_up

const BLOOD_SPLATTER = preload("uid://koyn58n0ddv1")
const VICTIM = preload("uid://camlwa5boen3n")

@onready var game: Node2D = $Game
@onready var intro: Node2D = $Intro
@onready var game_ui: Control = $UI/GameUI
@onready var intro_ui: Control = $UI/IntroUI

@onready var background: Node2D = %Background

# Weapon stuff
@onready var scope: TextureRect = %Scope
var base_scale: Vector2
var scope_tween: Tween

@onready var gunshot: AudioStreamPlayer2D = %Gunshot

@onready var gun_cd_timer: Timer = $Game/GunCDTimer
@export var gun_cd: float = 2.0
var gun_flag: bool = true

# Victim stuff
@export var victim_registry: VictimRegistry
@onready var victim_spawns: Node2D = %Background/VictimSpawns

var spawned_victims: Array[Node2D] = []
var target_victim: Node2D
## on the clip board
@onready var target_sprite: Sprite2D = %TargetSprite

func _ready() -> void:
	super()
	
	finish_game.connect(cleanup)
	
	game.visible = false
	intro.visible = true 
	game_ui.visible = false
	intro_ui.visible = true
	
	base_scale = scope.scale
	
	gun_cd_timer.wait_time = gun_cd
	
	setup_victims()
	pick_target()
	
	# Show target for 2 seconds, then start game
	await get_tree().create_timer(2.0).timeout
	game_begin.emit()
	
	game.visible = true
	intro.visible = false 
	game_ui.visible = true
	intro_ui.visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func cleanup():
	cleaning_up.emit()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 


func setup_victims() -> void:
	spawned_victims.clear()
	if victim_registry == null:
		return
	
	# Copy and shuffle both lists
	var textures: Array[Texture2D] = victim_registry.victims.duplicate()
	var spawns := victim_spawns.get_children()
	
	textures.shuffle()
	spawns.shuffle()
	
	var max_count: int = min(textures.size(), spawns.size())
	var victim_count := randi_range(1, max_count)
	
	for i in victim_count:
		var victim := VICTIM.instantiate()
		background.add_child(victim)
		
		var spawn := spawns[i]
		victim.global_position = spawn.global_position
		
		var sprite := victim.get_node("Sprite2D") as Sprite2D
		sprite.texture = textures[i]
		
		victim.add_to_group("assassin_victim")
		spawned_victims.append(victim)


func pick_target() -> void:
	if spawned_victims.is_empty():
		return
	target_victim = spawned_victims[randi() % spawned_victims.size()]
	target_victim.add_to_group("assassin_target")
	
	var sprite = target_victim.find_child("Sprite2D")
	
	if sprite is not Sprite2D:
		return
	
	target_sprite.texture = sprite.texture


#
#func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 


func attempt_fire():
	if not gun_flag:
		return
	
	gun_flag = false
	
	gun_cd_timer.start()
	
	var hit := _check_hit()
	if hit:
		var victim = hit.collider
		if victim.is_in_group("assassin_victim"):
			var blood = BLOOD_SPLATTER.instantiate()
			background.add_child(blood)
			
			var marker: Node2D = scope.get_node("Marker")
			var marker_pos: Vector2 = marker.global_position
			
			blood.global_position = marker_pos
			
			if victim.is_in_group("assassin_target"):
				win_game.emit()
			else:
				lose_game.emit()
			
			cleanup()
		
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
	if scope_tween and scope_tween.is_valid():
		scope_tween.kill()
	
	scope.scale = base_scale
	
	scope_tween = create_tween()
	
	scope_tween.tween_property(
		scope, "scale", base_scale * 1.1, 0.05
	).set_ease(Tween.EASE_OUT)
	
	scope_tween.tween_property(
		scope, "scale", base_scale, 0.15
	).set_ease(Tween.EASE_IN)


func _process(_delta: float) -> void:	
	if Input.is_action_just_pressed("mouse_left"):
		attempt_fire()
