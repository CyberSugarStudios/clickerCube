extends Node3D
class_name CubeGrid
#the handler for building the grids of cubes needed for the recursion element of the game

#region - INIT
signal hp_changed

#region - CONSTS
const CUBE_SCENE: PackedScene = preload("res://scenes/cube.tscn")
const CUBE_SPACING: float = 1.0

#region - VARS
var grid_size: int = 1
var active_layer: int = 0
var shells: Array[Array] = []
var camera_tween: Tween

var total_hp: float = 0.0
var total_max_hp: float = 0.0
var layer_hp: Array[float] = []
var layer_max_hp: Array[float] = []
var player_target: Cube

var cells: Dictionary[Vector3i, Cube] = {}
var grid_generation: int = 0

#region - EXPORT VARS
@export var camera: Camera3D

@export var hp_growth_per_depth: float = 3.0
@export var gold_growth_per_depth: float = 2.5

@export var damage_numbers: DamageNumbers
@export var explosion_delay: float = 0.12
#endregion
#endregion
#endregion
#endregion

func _ready() -> void:
	#initialize the current grid size
	GameState.run_started.connect(start_run)
	start_run()

func start_run() -> void:
	grid_size = 1 if GameState.run_number == 1 else GameState.get_max_grid_size()
	build_grid(grid_size)

func zoom_camera_to(visible_size: int) -> void:
	#adjust the camera depending on the current size of the grid
		#closer for smaller grids, further away for larger grids
	if camera == null:
		return
	if camera_tween:
		camera_tween.kill()
	var target_z := visible_size * 1.6 + 1.0
	camera_tween = create_tween()
	camera_tween.tween_property(camera, "position:z", target_z, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func choose_cube_type() -> CubeTypeData:
	if GameState.has_skill(GameState.EXPLOSIVE_CUBES_SKILL) and randf() < GameState.explosive_chance:
		return GameState.EXPLOSIVE_TYPE
	if GameState.has_skill(GameState.GOLD_CUBE_SKILL) and randf() < GameState.gold_cube_chance:
		return GameState.GOLDEN_TYPE
	return null

func roll_cube_type(cube: Cube) -> void:
	var chosen := choose_cube_type()
	if chosen == null:
		return
	var old_max := cube.max_hp
	cube.cube_type = chosen
	cube.max_hp *= chosen.hp_mult
	cube.cur_hp = cube.max_hp
	cube.gold_reward *= chosen.gold_mult
	var extra := cube.max_hp - old_max
	total_hp += extra
	total_max_hp += extra
	layer_hp[cube.layer] += extra
	layer_max_hp[cube.layer] += extra

func cube_explodes(cube: Cube) -> bool:
	return cube.cube_type != null and cube.cube_type.explodes

func spawn_cube(grid_pos: Vector3i, cube_layer: int, depth: int) -> void:
	#spawn in the cubes at their correct grid position
	var cube := CUBE_SCENE.instantiate() as Cube
	cube.position = Vector3(grid_pos) * CUBE_SPACING
	cube.layer = cube_layer
	cube.grid_pos = grid_pos
	cells[grid_pos] = cube
	cube.max_hp *= pow(hp_growth_per_depth, depth)
	cube.gold_reward *= pow(gold_growth_per_depth, depth)
	total_hp += cube.max_hp
	total_max_hp += cube.max_hp
	layer_hp[cube_layer] += cube.max_hp
	layer_max_hp[cube_layer] += cube.max_hp
	cube.damaged.connect(_on_cube_damaged.bind(cube))
	cube.broken.connect(_on_cube_broken.bind(cube))
	add_child(cube)
	if cube_layer == active_layer:
		roll_cube_type(cube)
	cube.set_locked(cube_layer != active_layer)
	shells[cube_layer].append(cube)

func build_grid(size: int) -> void:
	#grid math
	cells.clear()
	grid_generation += 1
	@warning_ignore("integer_division")
	var half: int = size / 2
	active_layer = half
	shells.clear()
	for i in range(half + 1):
		shells.append([])
	total_hp = 0.0
	total_max_hp = 0.0
	layer_hp.resize(half + 1)
	layer_hp.fill(0.0)
	layer_max_hp.resize(half + 1)
	layer_max_hp.fill(0.0)
	player_target = null
	
	for x in range(-half, half + 1):
		for y in range(-half, half + 1):
			for z in range(-half, half + 1):
				var cube_layer := maxi(absi(x), maxi(absi(y), absi(z)))
				spawn_cube(Vector3i(x, y, z), cube_layer, half - cube_layer)
	
	zoom_camera_to(size)
	hp_changed.emit()

func _on_cube_damaged(amount: float, cube: Cube) -> void:
	total_hp -= amount
	layer_hp[cube.layer] -= amount
	hp_changed.emit()

func _on_cube_broken(gold_reward: float, cube: Cube) -> void:
	#track broken cubes and grid layers
	var payout := gold_reward
	if cube.cube_type == GameState.GOLDEN_TYPE:
		payout *= 1.0 + GameState.gold_payout_bonus / GameState.GOLDEN_TYPE.gold_mult
	GameState.add_gold(payout)
	shells[cube.layer].erase(cube)
	cells.erase(cube.grid_pos)
	if cube_explodes(cube):
		explode_after_delay(cube.grid_pos, grid_generation)
	
	if not shells[active_layer].is_empty():
		return
	
	layer_hp[active_layer] = 0.0
	
	active_layer -= 1
	if active_layer < 0:
		total_hp = 0.0
		hp_changed.emit()
		if grid_size >= GameState.get_max_grid_size():
			GameState.complete_run()
		else:
			grid_size += 2
			build_grid(grid_size)
	else:
		for inner_cube: Cube in shells[active_layer]:
			roll_cube_type(inner_cube)
			inner_cube.set_locked(false)
		zoom_camera_to(active_layer * 2 + 1)
		hp_changed.emit()

func get_active_layer_hp() -> float:
	return layer_hp[active_layer] if active_layer >= 0 else 0.0

func get_active_layer_max_hp() -> float:
	return layer_max_hp[active_layer] if active_layer >= 0 else 0.0

#region - DRONE CODE
func get_active_cubes() -> Array:
	if active_layer < 0 or shells.is_empty():
		return []
	return shells[active_layer]

func get_visible_size() -> int:
	return maxi(active_layer, 0) * 2 + 1
#endregion

#region - EXPLOSIONS
func explode_after_delay(center: Vector3i, generation: int) -> void:
	await get_tree().create_timer(explosion_delay).timeout
	if generation != grid_generation:
		return
	var damage := GameState.click_damage * GameState.explosion_damage_mult
	for cube in get_cubes_in_radius(center, GameState.explosion_radius):
		var hit := damage
		if cube_explodes(cube):
			hit = maxf(damage, cube.cur_hp)
		if cube.take_damage(hit) and damage_numbers:
			damage_numbers.spawn(hit, cube.global_position, false)

func get_cubes_in_radius(center: Vector3i, radius: int) -> Array[Cube]:
	var found: Array[Cube] = []
	for x in range(-radius, radius + 1):
		for y in range (-radius, radius + 1):
			for z in range(-radius, radius + 1):
				if x == 0 and y == 0 and z == 0:
					continue
				var cube: Cube = cells.get(center + Vector3i(x, y, z))
				if cube:
					found.append(cube)
	return found
#endregion
