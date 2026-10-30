extends Node3D

#region - VARS
#region - CONSTS
const DRONE_SCENE: PackedScene = preload("res://scenes/drone.tscn")
#endregion
#region - EXPORTS
@export var grid: CubeGrid
@export var damage_numbers: DamageNumbers
#endregion
#endregion

func _ready() -> void:
	GameState.skills_changed.connect(sync_drones)
	GameState.upgrades_changed.connect(sync_drones)
	sync_drones()

func sync_drones() -> void:
	while get_child_count() < GameState.get_drone_count():
		var drone := DRONE_SCENE.instantiate() as Drone
		drone.grid = grid
		drone.damage_numbers = damage_numbers
		add_child(drone)
