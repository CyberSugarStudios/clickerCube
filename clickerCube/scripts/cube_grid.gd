extends Node3D

#region - INIT

#region - CONSTS
const CUBE_SCENE: PackedScene = preload("res://scenes/cube.tscn")

#endregion
#endregion

func _ready() -> void:
	spawn_cube()

func spawn_cube() -> void:
	var cube := CUBE_SCENE.instantiate() as Cube
	cube.broken.connect(_on_cube_broken)
	add_child(cube)

func _on_cube_broken(gold_reward: float) -> void:
	GameState.add_gold(gold_reward)
	spawn_cube()
