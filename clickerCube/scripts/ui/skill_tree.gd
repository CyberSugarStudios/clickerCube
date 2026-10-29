extends Control

const LINE_OWNED := Color(1.0, 0.82, 0.3, 0.9)
const LINE_UNOWNED := Color(0.5, 0.5, 0.6, 0.5)
const LINE_WIDTH: float = 3.0

func _ready() -> void:
	GameState.skills_changed.connect(queue_redraw)
	resized.connect(queue_redraw)

func _draw() -> void:
	var tree_center := size / 2.0
	for child in get_children():
		var pip := child as SkillPip
		if pip == null:
			continue
		var pip_center := pip.position + pip.size / 2.0
		if pip.skill.prereqs.is_empty():
			draw_line(tree_center, pip_center, line_color(pip.skill), LINE_WIDTH)
			continue
		for reqs: SkillNodeData in pip.skill.prereqs:
			var other := find_pip(reqs)
			if other:
				draw_line(other.position + other.size / 2.0, pip_center, line_color(pip.skill), LINE_WIDTH)

func find_pip(skill: SkillNodeData) -> SkillPip:
	for child in get_children():
		var pip := child as SkillPip
		if pip and pip.skill == skill:
			return pip
	return null

func line_color(skill: SkillNodeData) -> Color:
	return LINE_OWNED if GameState.has_skill(skill) else LINE_UNOWNED
