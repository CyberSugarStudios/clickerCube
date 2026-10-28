extends StaticBody3D

var maxHP
var curHP
var goldReward

signal broken

func _ready() -> void:
	maxHP = 10
	curHP = 10
	goldReward = 10

func CubeClicked():
	#curHP -= clickPower?
	if curHP <= 0:
		KillCube()
	pass

func KillCube():
	self.broken
	#self.get_tree().quit()?
