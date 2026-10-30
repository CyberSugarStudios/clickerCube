extends Node3D
class_name Drone

#region - VARS
#region - EXPORTS
@export var orbit_speed: float = 0.8
@export var orbit_margin: float = 1.5
@export var click_interval: float = 1.0
#endregion

var grid: CubeGrid
var damage_numbers: DamageNumbers

var orbit_axis: Vector3
var orbit_start: Vector3
var orbit_angle: float
var click_timer: float
#endregion

func _ready() -> void:
	orbit_axis = Vector3(randf_range(-0.4, 0.4), 1.0, randf_range(-0.4, 0.4)).normalized()
	orbit_start = orbit_axis.cross(Vector3.RIGHT).normalized()
	orbit_angle = randf() * TAU
	click_timer = randf() * click_interval

func _process(delta: float) -> void:
	orbit_angle += orbit_speed * delta
	var radius := grid.get_visible_size() * 0.5 + orbit_margin
	position = orbit_start.rotated(orbit_axis, orbit_angle) * radius
	look_at(grid.global_position, Vector3.UP, true)
	
	click_timer -= delta
	if click_timer <= 0.0:
		click_timer += click_interval
		click_random_cube()

func click_random_cube() -> void:
	var cubes := grid.get_active_cubes()
	if cubes.is_empty():
		return
	var cube: Cube = cubes.pick_random()
	var is_crit := GameState.roll_crit()
	var damage := GameState.get_drone_damage(is_crit)
	if cube.take_damage(damage):
		damage_numbers.spawn(damage, cube.global_position, is_crit)
