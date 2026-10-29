extends Button

@export var galaxy_screen: GalaxyScreen

func _ready() -> void:
	hide()
	pressed.connect(_on_pressed)
	GameState.run_completed.connect(show.unbind(1))
	GameState.run_started.connect(hide)

func _on_pressed() -> void:
	galaxy_screen.open()
