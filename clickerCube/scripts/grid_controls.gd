extends Node

#region - VARS
#region - CONSTS
const DRAG_THRESHOLD: float = 10.0
const ROTATE_SPEED: float = 0.01
#endregion

#region - EXPORT VARS
@export var camera: Camera3D
@export var grid: Node3D
#endregion

var is_pressing: bool = false
var is_dragging: bool = false
var press_pos: Vector2
var pending_tap: bool  = false
var tap_pos: Vector2
#endregion

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.index == 0:
		if event.pressed:
			is_pressing = true
			is_dragging = false
			press_pos = event.position
		else:
			if is_pressing and not is_dragging:
				pending_tap = true
				tap_pos = event.position
			is_pressing = false
			is_dragging = false
	elif event is InputEventScreenDrag and event.index == 0 and is_pressing:
		if not is_dragging and event.position.distance_to(press_pos) > DRAG_THRESHOLD:
			is_dragging = true
		if is_dragging:
			grid.rotate(Vector3.UP, event.relative.x * ROTATE_SPEED)
			grid.rotate(Vector3.RIGHT, event.relative.y * ROTATE_SPEED)

func _physics_process(_delta: float) -> void:
	if pending_tap:
		pending_tap = false
		hit_cube_at(tap_pos)

func hit_cube_at(screen_pos: Vector2) -> void:
	var from := camera.project_ray_origin(screen_pos)
	var to := camera.project_ray_normal(screen_pos) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := camera.get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return
	var cube := result.collider as Cube
	if cube:
		cube.take_damage(GameState.get_click_damage())
