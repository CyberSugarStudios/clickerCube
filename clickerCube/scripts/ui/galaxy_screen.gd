extends Control
class_name GalaxyScreen

@onready var choices: VBoxContainer = $Choices
@onready var black_hole_button: Button = $BlackHoleButton
@onready var continue_button: Button = $Choices/ContinueButton
@onready var collapse_button: Button = $Choices/CollapseButton

func _ready() -> void:
	hide()
	black_hole_button.pressed.connect(_on_black_hole_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	collapse_button.pressed.connect(_on_collapse_pressed)

func open() -> void:
	choices.hide()
	show()

func _on_black_hole_pressed() -> void:
	choices.visible = not choices.visible

func _on_continue_pressed() -> void:
	hide()
	GameState.start_next_run()

func _on_collapse_pressed() -> void:
	#later implement collapse "rebirth" gameplay loop
	pass
