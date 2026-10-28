extends StaticBody3D
class_name Cube

#region - INIT
signal broken(gold_reward: float)

#region - VARS
var is_broken: bool = false
var cur_hp: float
var scale_tween: Tween

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
	scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3.ONE, 0.5)
	cur_hp = max_hp

func take_damage(amount: float) -> void:
	if is_broken:
		return
	cur_hp -= amount
	play_hit_squash()
	if cur_hp <= 0:
		kill_cube()

func play_hit_squash() -> void:
	if scale_tween:
		scale_tween.kill()
	model.scale = Vector3.ONE
	scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3(0.9, 0.9, 0.9), 0.05)
	scale_tween.tween_property(model, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func kill_cube() -> void:
	is_broken = true
	$CollisionShape3D.set_deferred("disabled", true)
	broken.emit(gold_reward)
	if scale_tween:
		scale_tween.kill()
	scale_tween = create_tween()
	scale_tween.tween_property(model, "scale", Vector3.ZERO, 0.15)
	scale_tween.tween_callback(queue_free)

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var damage := GameState.get_click_damage()
		take_damage(damage)
