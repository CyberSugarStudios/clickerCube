extends StaticBody3D

@export var max_hp: float = 10
@export var cur_hp: float = 10
@export var gold_reward: float = 10

signal broken

func take_damage(amount):
	cur_hp -= amount
	if cur_hp <= 0:
		KillCube()

func KillCube():
	emit_signal("broken")
	queue_free()
