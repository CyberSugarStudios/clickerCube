extends Label

func _ready() -> void:
	GameState.gold_changed.connect(_on_gold_changed)
	_on_gold_changed(GameState.gold)

func _on_gold_changed(new_amount: float) -> void:
	text = "Gold: " + NumFormat.short(new_amount)
