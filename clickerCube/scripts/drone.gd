extends Node3D
class_name Drone

#region - VARS
#region - EXPORTS
@export var move_speed: float = 1.5
@export var orbit_margin: float = 1.0
@export var attack_angle: float = 0.15
@export var separation_angle: float = 0.35
@export var separation_strength: float = 2.0
@export var radius_smoothing: float = 5.0
#endregion

var grid: CubeGrid
var damage_numbers: DamageNumbers

var target: Cube
var dir: Vector3
var radius: float = 3.0
var click_timer: float = 0.0
var core_offset: Vector3
#endregion

func _ready() -> void:
	dir = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	core_offset = Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	click_timer = randf() * GameState.drone_click_interval

func _process(delta: float) -> void:
	var goal_radius := grid.get_visible_size() * (sqrt(3) / 2) + orbit_margin
	radius = lerpf(radius, goal_radius, 1.0 - exp(-radius_smoothing * delta))
	
	if not has_valid_target():
		pick_target()
	
	var hover := Vector3.ZERO
	if target:
		hover = get_hover_dir(target)
		move_toward_dir(hover, delta)
	
	apply_separation(delta)
	position = dir * radius
	face(target.global_position if target else grid.global_position)
	
	if target and dir.angle_to(hover) < attack_angle:
		tick_click(delta)

func has_valid_target() -> bool:
	return is_instance_valid(target) and not target.is_broken and not target.is_locked

func pick_target() -> void:
	target = null
	var cubes := grid.get_active_cubes()
	var free_cubes := cubes.filter(func(cube): return not is_claimed(cube))
	var pool := free_cubes if not free_cubes.is_empty() else cubes
	var best_angle := INF
	for cube: Cube in pool:
		var angle := dir.angle_to(get_hover_dir(cube))
		if angle < best_angle:
			best_angle = angle
			target = cube

func is_claimed(cube: Cube) -> bool:
	for child in get_parent().get_children():
		var other := child as Drone
		if other and other != self and other.target == cube:
			return true
	return false

func get_hover_dir(cube: Cube) -> Vector3:
	if cube.position.length() < 0.01:
		var camera := get_viewport().get_camera_3d()
		var away_from_camera := -grid.to_local(camera.global_position).normalized()
		return (away_from_camera + core_offset).normalized()
	return cube.position.normalized()

func move_toward_dir(goal: Vector3, delta: float) -> void:
	var angle := dir.angle_to(goal)
	if angle > 0.001:
		dir = dir.slerp(goal, minf(1.0, move_speed * delta / angle))

func apply_separation(delta: float) -> void:
	for child in get_parent().get_children():
		var other := child as Drone
		if other == null or other == self:
			continue
		if dir.angle_to(other.dir) < separation_angle:
			var push := (dir - other.dir).normalized()
			dir = (dir + push * separation_strength * delta).normalized()

func face(world_point: Vector3) -> void:
	var look_dir := (world_point - global_position).normalized()
	var up := Vector3.UP if absf(look_dir.dot(Vector3.UP)) < 0.98 else Vector3.RIGHT
	look_at(world_point, up, true)

func tick_click(delta: float) -> void:
	click_timer -= delta
	if click_timer > 0.0:
		return
	click_timer = GameState.drone_click_interval
	var damage := GameState.get_drone_damage()
	if target.take_damage(damage):
		damage_numbers.spawn(damage, target.global_position, false)
