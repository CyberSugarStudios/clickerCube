extends Node

#region - INIT
signal gold_changed(new_amount: float)

#region - VARS
var gold: float = 0.0
var click_damage: float = 1.0
var crit_chance: float = 0.05
var crit_mult: float = 2
#endregion
#endregion

func add_gold(amount: float) -> void:
	gold += amount
	gold_changed.emit(gold)

func get_click_damage() -> float:
	if randf() < crit_chance:
		return click_damage * crit_mult
	return click_damage
