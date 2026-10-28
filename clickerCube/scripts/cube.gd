extends StaticBody3D
class_name Cube

#region - INIT
signal broken(gold_reward: float)

#region - VARS
var is_broken: bool = false
var cur_hp: float
var hit_tween: Tween

#region - EXPORT VARS
@export var max_hp: float = 10
@export var gold_reward: float = 10
#endregion

#region - ONREADY VARS
@onready var model: Node3D = $Model
#endregion
#endregion
#endregion

func _ready() -> void:
	model.scale = Vector3.ZERO
	var grow_tween := create_tween()
	grow_tween.tween_property(model, "scale", Vector3.ONE, 0.2)
	cur_hp = max_hp

func take_damage(amount: float) -> void:
	if is_broken:
		return
	cur_hp -= amount
	play_hit_squash()
	if cur_hp <= 0:
		kill_cube()

func play_hit_squash() -> void:
	if hit_tween:
		hit_tween.kill()
	model.scale = Vector3.ONE
	hit_tween = create_tween()
	hit_tween.tween_property(model, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
	hit_tween.tween_property(model, "scale", Vector3.ONE, 0.5)

func kill_cube() -> void:
	is_broken = true
	$CollisionShape3D.set_deferred("disabled", true)
	broken.emit(gold_reward)
	if hit_tween:
		hit_tween.kill()
	var break_tween := create_tween()
	break_tween.tween_property(model, "scale", Vector3.ZERO, 0.1)
	break_tween.tween_callback(queue_free)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var damage := GameState.get_click_damage()
		take_damage(damage)
		print("Hit for: ", damage, " | HP: ", cur_hp)
