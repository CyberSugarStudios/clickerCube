extends StaticBody3D
class_name Cube
#the base building block for the game, each cube has HP and a gold value for breaking it

#region - INIT
signal broken(gold_reward: float)

#region - VARS
var is_broken: bool = false
var cur_hp: float
var scale_tween: Tween
var layer: int = 0
var is_locked: bool = false

#region - EXPORT VARS
@export var max_hp: float = 10
@export var gold_reward: float = 10
@export var locked_material: Material
#endregion

#region - ONREADY VARS
@onready var model: Node3D = $Model
@onready var mesh: MeshInstance3D = $Model/Cube
#endregion
#endregion
#endregion

func _ready() -> void:
	#set up the cube by making it small and then growing it in place, then set it's HP
	model.scale = Vector3.ZERO
	scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3.ONE, 0.5)
	cur_hp = max_hp

func set_locked(value: bool) -> void:
	#set locked cubes so that only the top row can be clicked (later need to implment upgrades so that multiple
	#layers can be damaged at a time
	is_locked = value
	mesh.material_override = locked_material if value else null

func take_damage(amount: float) -> void:
	#the cube takes damage unless it is already broken
	if is_broken:
		return
	if is_locked:
		#play clink locked sound
		return
	cur_hp -= amount
	play_hit_squash()
	if cur_hp <= 0:
		kill_cube()

func play_hit_squash() -> void:
	#animation for clicking and damaging a cube
	if scale_tween:
		scale_tween.kill()
	model.scale = Vector3.ONE
	scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
	scale_tween.tween_property(model, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func kill_cube() -> void:
	#after taking sufficient damage, the cube breaks, and plays it's animation
	is_broken = true
	$CollisionShape3D.set_deferred("disabled", true)
	broken.emit(gold_reward)
	#play broken cube sound
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3.ZERO, 0.15)
	scale_tween.tween_callback(queue_free)
