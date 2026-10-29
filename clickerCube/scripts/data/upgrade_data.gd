extends Resource
class_name UpgradeData

#region - VARS
#region - EXPORTS
@export var id: StringName
@export var display_name: String
@export var base_cost: float = 10.0
@export var cost_growth: float = 1.15
@export var effect_per_level: float = 1.0
@export var max_level: int = 0
@export var required_skill: SkillNodeData
#endregion
#endregion

func get_cost(level: int) -> float:
	return base_cost * pow(cost_growth, level)

func is_maxed(level: int) -> bool:
	return max_level > 0 and level >= max_level
