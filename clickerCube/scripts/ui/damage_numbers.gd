extends Control
class_name DamageNumbers

const DAMAGE_NUMBER_SCENE: PackedScene = preload("res://scenes/ui/damage_number.tscn")

@export var camera: Camera3D

func spawn(amount: float, world_pos: Vector3, is_crit: bool) -> void:
	var number := DAMAGE_NUMBER_SCENE.instantiate() as DamageNumber
	number.setup(amount, camera.unproject_position(world_pos), is_crit)
	add_child(number)
