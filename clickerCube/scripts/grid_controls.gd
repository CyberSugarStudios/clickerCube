extends Node

#region - VARS

#region - EXPORT VARS
@export var camera: Camera3D
@export var grid: Node3D
@export var drag_threshold: float = 20.0
@export var quick_drag_threshold: float = 50.0
@export var quick_tap_time: float = 0.15
@export var rotate_speed: float = 0.01
#endregion

var is_pressing: bool = false
var is_dragging: bool = false
var press_pos: Vector2
var pending_tap: bool  = false
var tap_pos: Vector2
var press_time: float = 0.0
#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.index == 0:
		if event.pressed:
			is_pressing = true
			is_dragging = false
			press_pos = event.position
			press_time = Time.get_ticks_msec() / 1000.0
		else:
			if is_pressing and not is_dragging:
				pending_tap = true
				tap_pos = event.position
			is_pressing = false
			is_dragging = false
	elif event is InputEventScreenDrag and event.index == 0 and is_pressing:
		var held_for := Time.get_ticks_msec() / 1000.0 - press_time
		var threshold := quick_drag_threshold if held_for < quick_tap_time else drag_threshold
		if not is_dragging and event.position.distance_to(press_pos) > threshold:
			is_dragging = true
		if is_dragging:
			grid.rotate(Vector3.UP, event.relative.x * rotate_speed)
			grid.rotate(Vector3.RIGHT, event.relative.y * rotate_speed)

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
	if cube:
		cube.take_damage(GameState.get_click_damage())
