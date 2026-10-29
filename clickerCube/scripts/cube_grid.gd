extends Node3D

#region - INIT

#region - CONSTS
const CUBE_SCENE: PackedScene = preload("res://scenes/cube.tscn")
const CUBE_SPACING: float = 1.05

#region - VARS
var grid_size: int = 1
var active_layer: int = 0
var shells: Array[Array] = []

#region - EXPORT VARS
@export var camera: Camera3D
#endregion
#endregion
#endregion
#endregion

func _ready() -> void:
	build_grid(grid_size)

func spawn_cube(grid_pos: Vector3i, cube_layer: int) -> void:
	var cube := CUBE_SCENE.instantiate() as Cube
	cube.position = Vector3(grid_pos) * CUBE_SPACING
	cube.layer = cube_layer
	cube.broken.connect(_on_cube_broken.bind(cube))
	add_child(cube)
	cube.set_locked(cube_layer != active_layer)
	shells[cube_layer].append(cube)

func build_grid(size: int) -> void:
	@warning_ignore("integer_division")
	var half: int = size / 2
	active_layer = half
	shells.clear()
	for i in range(half + 1):
		shells.append([])
	
	for x in range(-half, half + 1):
		for y in range(-half, half + 1):
			for z in range(-half, half + 1):
				var cube_layer := maxi(absi(x), maxi(absi(y), absi(z)))
				spawn_cube(Vector3i(x, y, z), cube_layer)
	
	if camera:
		var target_z := size * 1.6 + 1.0
		create_tween().tween_property(camera, "position:z", target_z, 0.6)

func _on_cube_broken(gold_reward: float, cube: Cube) -> void:
	GameState.add_gold(gold_reward)
	shells[cube.layer].erase(cube)
	
	if not shells[active_layer].is_empty():
		return
	
	active_layer -= 1
	if active_layer < 0:
		grid_size += 2
		build_grid(grid_size)
	else:
		for inner_cube: Cube in shells[active_layer]:
			inner_cube.set_locked(false)
