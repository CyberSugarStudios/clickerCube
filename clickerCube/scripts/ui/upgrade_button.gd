extends Button

@export var upgrade: UpgradeData

func _ready() -> void:
	pressed.connect(_on_pressed)
	GameState.gold_changed.connect(refresh.unbind(1))
	GameState.upgrades_changed.connect(refresh)
	refresh()

func refresh() -> void:
	var level := GameState.get_level(upgrade)
	if upgrade.is_maxed(level):
		text = "%s (Lv %d)\nMAX" % [upgrade.display_name, level]
		disabled = true
		return
	var cost := upgrade.get_cost(level)
	text = "%s (Lv %d)\nCost: %d" % [upgrade.display_name, level, cost]
	disabled = GameState.gold < cost

func _on_pressed() -> void:
	GameState.try_buy(upgrade)
