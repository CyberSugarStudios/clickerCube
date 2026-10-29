extends Node

#region - VARS

#region - EXPORT VARS
@export var camera: Camera3D
@export var grid: Node3D
@export var drag_threshold: float = 20.0
@export var quick_drag_threshold: float = 80.0
@export var quick_tap_time: float = 0.10
@export var rotate_speed: float = 0.01
@export var click_streak_window: float = 0.35
@export var damage_numbers: DamageNumbers
#endregion

var is_mouse_rotating: bool = false
var last_tap_time: float = -1.0
var in_click_streak: bool = false
var is_pressing: bool = false
var is_dragging: bool = false
var press_pos: Vector2
var pending_tap: bool  = false
var tap_pos: Vector2
var press_time: float = 0.0
#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			queue_tap(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			is_mouse_rotating = event.pressed
		return
	
	if event is InputEventMouseMotion:
		if is_mouse_rotating:
			rotate_grid(event.relative)
		return
	
	if event is InputEventScreenTouch and event.index == 0:
		if event.pressed:
			is_pressing = true
			is_dragging = false
			press_pos = event.position
			press_time = Time.get_ticks_msec() / 1000.0
			in_click_streak = last_tap_time >= 0.0 and press_time - last_tap_time < click_streak_window
		else:
			if is_pressing and not is_dragging:
				queue_tap(event.position)
				last_tap_time = Time.get_ticks_msec() / 1000.0
			is_pressing = false
			is_dragging = false
	elif event is InputEventScreenDrag and event.index == 0 and is_pressing:
		var held_for := Time.get_ticks_msec() / 1000.0 - press_time
		var use_quick := held_for < quick_tap_time or in_click_streak
		var threshold := quick_drag_threshold if use_quick else drag_threshold
		if not is_dragging and event.position.distance_to(press_pos) > threshold:
			is_dragging = true
		if is_dragging:
			rotate_grid(event.relative)

func _physics_process(_delta: float) -> void:
	if pending_tap:
		pending_tap = false
		hit_cube_at(tap_pos)

func hit_cube_at(screen_pos: Vector2) -> void:
	var from := camera.project_ray_origin(screen_pos)
	var to := from + camera.project_ray_normal(screen_pos) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return
	var cube := result.collider as Cube
	if cube == null:
		return
	var is_crit := GameState.roll_crit()
	var damage := GameState.get_click_damage(is_crit)
	if cube.take_damage(damage) and damage_numbers:
		damage_numbers.spawn(damage, result.position, is_crit)

func queue_tap(screen_pos: Vector2) -> void:
	pending_tap = true
	tap_pos = screen_pos

func rotate_grid(relative: Vector2) -> void:
	grid.rotate(Vector3.UP, relative.x * rotate_speed)
	grid.rotate(Vector3.RIGHT, relative.y * rotate_speed)
