extends Resource
class_name SkillNodeData

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var cost: int = 1
@export var prereqs: Array[SkillNodeData] = []
