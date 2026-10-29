extends Node

#region - INIT
signal gold_changed(new_amount: float)
signal upgrades_changed
signal core_shards_changed(new_amount: int)
signal run_completed(shards_earned: int)
signal run_started

#region - CONSTS
const BASE_CLICK_DAMAGE: float = 1.0
const BASE_CRIT_CHANCE: float = 0.05
const BASE_CRIT_MULT: float = 2.0

const CLICK_DAMAGE_UPGRADE: UpgradeData = preload("res://resources/upgrades/click_damage.tres")
const CRIT_CHANCE_UPGRADE: UpgradeData = preload("res://resources/upgrades/crit_chance.tres")
const CRIT_MULT_UPGRADE: UpgradeData = preload("res://resources/upgrades/crit_mult.tres")
#endregion

#region - VARS
var upgrade_levels: Dictionary[StringName, int] = {}

var gold: float = 0.0
var click_damage: float = 1.0
var crit_chance: float = 0.05
var crit_mult: float = 2.0

var core_shards: int = 0
var run_number: int = 1
#endregion
#endregion

#region - GAMEPLAY LOOP
func get_max_grid_size() -> int:
	return run_number * 2 + 1

func complete_run() -> void:
	var earned := run_number
	core_shards += earned
	core_shards_changed.emit(core_shards)
	run_completed.emit(earned)

func start_next_run() -> void:
	run_number += 1
	run_started.emit()
#endregion

func add_gold(amount: float) -> void:
	gold += amount
	gold_changed.emit(gold)

func get_click_damage() -> float:
	if randf() < crit_chance:
		return click_damage * crit_mult
	return click_damage

func get_level(upgrade: UpgradeData) -> int:
	return upgrade_levels.get(upgrade.id, 0)

func recalc_stats() -> void:
	click_damage = BASE_CLICK_DAMAGE + get_level(CLICK_DAMAGE_UPGRADE) * CLICK_DAMAGE_UPGRADE.effect_per_level
	crit_chance = BASE_CRIT_CHANCE + get_level(CRIT_CHANCE_UPGRADE) * CRIT_CHANCE_UPGRADE.effect_per_level
	crit_mult = BASE_CRIT_MULT + get_level(CRIT_MULT_UPGRADE) * CRIT_MULT_UPGRADE.effect_per_level

func _ready() -> void:
	recalc_stats()

func try_buy(upgrade: UpgradeData) -> bool:
	var level := get_level(upgrade)
	if upgrade.is_maxed(level):
		return false
	var cost := upgrade.get_cost(level)
	if gold < cost:
		return false
	gold -= cost
	upgrade_levels[upgrade.id] = level + 1
	recalc_stats()
	gold_changed.emit(gold)
	upgrades_changed.emit()
	return true
