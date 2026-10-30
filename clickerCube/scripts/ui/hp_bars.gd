extends VBoxContainer

@export var grid: CubeGrid

@onready var cube_bar: ProgressBar = $CubeBar
@onready var layer_bar: ProgressBar = $LayerBar
@onready var block_bar: ProgressBar = $BlockBar

func _ready() -> void:
	grid.hp_changed.connect(refresh)
	refresh()

func refresh() -> void:
	set_bar(cube_bar, "Cube", grid.total_hp, grid.total_max_hp)
	set_bar(layer_bar, "Layer", grid.get_active_layer_hp(), grid.get_active_layer_max_hp())
	var target := grid.player_target
	if is_instance_valid(target):
		set_bar(block_bar, "Block", maxf(target.cur_hp, 0.0), target.max_hp)
	else:
		set_bar(block_bar, "Block", 0.0, 0.0)

func set_bar(bar: ProgressBar, label_name: String, value: float, max_value: float) -> void:
	bar.max_value = maxf(max_value, 1.0)
	bar.value = value
	var label := bar.get_node("Text") as Label
	label.text = "%s: %d / %d" % [label_name, ceilf(value), max_value]
