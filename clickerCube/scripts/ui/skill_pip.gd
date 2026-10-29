extends Button
class_name SkillPip

const COLOR_OWNED := Color(1.0, 0.82, 0.3)
const COLOR_AVAILABLLE := Color.WHITE
const COLOR_TOO_EXPENSIVE := Color(0.6, 0.6, 0.6)
const COLOR_LOCKED := Color(0.3, 0.3, 0.35)

@export var skill: SkillNodeData

func _ready() -> void:
	text = skill.display_name
	pressed.connect(_on_pressed)
	GameState.skills_changed.connect(refresh)
	GameState.core_shards_changed.connect(refresh.unbind(1))
	refresh()

func refresh() -> void:
	tooltip_text = "%s\n%s\nCost: %d Core Shards" % [skill.display_name, skill.description, skill.cost]
	if GameState.has_skill(skill):
		modulate = COLOR_OWNED
		disabled = true
	elif not GameState.prereqs_met(skill):
		modulate = COLOR_LOCKED
		disabled = true
	else:
		modulate = COLOR_AVAILABLLE if GameState.can_buy_skill(skill) else COLOR_TOO_EXPENSIVE
		disabled = not GameState.can_buy_skill(skill)

func _on_pressed() -> void:
	GameState.try_buy_skill(skill)
