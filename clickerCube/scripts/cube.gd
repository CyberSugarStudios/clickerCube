extends StaticBody3D
class_name Cube

#region - INIT
signal broken(gold_reward: float)

#region - EXPORTS
@export var max_hp: float = 10
@export var gold_reward: float = 10
#endregion

#region - VARS
var is_broken: bool = false

var cur_hp: float
#endregion
#endregion

func _ready() -> void:
	cur_hp = max_hp

func take_damage(amount: float) -> void:
	if is_broken:
		return
	cur_hp -= amount
	#tween a slight shrink and return to normal size
	if cur_hp <= 0:
		#cur_hp = max_hp #infinite testing
		kill_cube()

func kill_cube() -> void:
	is_broken = true
	#tween a rapid shrink
	broken.emit(gold_reward)
	queue_free()

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var damage := GameState.get_click_damage()
		take_damage(damage)
		print("Hit for: ", damage, " | HP: ", cur_hp)
