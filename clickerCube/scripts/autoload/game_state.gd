extends Node

#region - INIT
signal gold_changed(new_amount: float)
signal upgrades_changed
signal core_shards_changed(new_amount: int)
signal run_completed(shards_earned: int)
signal run_started
signal skills_changed

#region - CONSTS
const DEBUG_GOLD_MULT: float = 1.0

const BASE_CLICK_DAMAGE: float = 1.0
const BASE_CRIT_CHANCE: float = 0.05
const BASE_CRIT_MULT: float = 2.0

const CLICK_DAMAGE_UPGRADE: UpgradeData = preload("res://resources/upgrades/click_damage.tres")
const CRIT_CHANCE_UPGRADE: UpgradeData = preload("res://resources/upgrades/crit_chance.tres")
const CRIT_MULT_UPGRADE: UpgradeData = preload("res://resources/upgrades/crit_mult.tres")

const BASE_DRONE_DAMAGE_MULT: float = 0.5
const CLICKER_DRONE_SKILL: SkillNodeData = preload("res://resources/skills/clicker_drone.tres")
const BUY_DRONE_UPGRADE: UpgradeData = preload("res://resources/upgrades/buy_new_drone.tres")
const DRONE_DAMAGE_UPGRADE: UpgradeData = preload("res://resources/upgrades/drone_damage.tres")
const BASE_DRONE_CLICK_INTERVAL: float = 2.0
const DRONE_SPEED_UPGRADE: UpgradeData = preload("res://resources/upgrades/drone_speed.tres")

const BASE_GOLD_CUBE_CHANCE: float = 0.015
const GOLD_CUBE_SKILL: SkillNodeData = preload("res://resources/skills/gold_cubes.tres")
const GOLDEN_TYPE: CubeTypeData = preload("res://resources/cube_types/golden.tres")
const GOLD_CHANCE_UPGRADE: UpgradeData = preload("res://resources/upgrades/gold_cube_chance.tres")
const GOLD_PAYOUT_UPGRADE: UpgradeData = preload("res://resources/upgrades/gold_cube_payout.tres")

const BASE_EXPLOSIVE_CHANCE: float = 0.02
const BASE_EXPLOSION_DAMAGE_MULT: float = 5.0
const BASE_EXPLOSION_RADIUS: int = 1
const EXPLOSIVE_CUBES_SKILL: SkillNodeData = preload("res://resources/skills/explosive_cubes.tres")
const EXPLOSIVE_TYPE: CubeTypeData = preload("res://resources/cube_types/explosive.tres")
const EXPLOSIVE_CHANCE_UPGRADE: UpgradeData = preload("res://resources/upgrades/explosive_chance.tres")
const EXPLOSIVE_DAMAGE_UPGRADE: UpgradeData = preload("res://resources/upgrades/explosion_damage.tres")
const EXPLOSIVE_RADIUS_UPGRADE: UpgradeData = preload("res://resources/upgrades/explosive_radius.tres")

const BASE_SPLASH_FRACTION: float = 0.1
const SPLASH_SKILL: SkillNodeData = preload("res://resources/skills/splash_damage.tres")
const SPLASH_UPGRADE: UpgradeData = preload("res://resources/upgrades/splash_strength.tres")

const DRONE_SPLASH_INTERVAL_MULT: float = 1.5
const DRONE_SPLASH_SKILL: SkillNodeData = preload("res://resources/skills/drone_splash.tres")

const GOLDEN_BURST_GOLD_MULT: float = 1.5
const GOLDEN_BURST_SKILL: SkillNodeData = preload("res://resources/skills/gold_explode.tres")

#endregion

#region - VARS
var upgrade_levels: Dictionary[StringName, int] = {}

var gold: float = 0.0
var click_damage: float = 1.0
var crit_chance: float = 0.05
var crit_mult: float = 2.0

var core_shards: int = 0
var run_number: int = 1

var unlocked_skills: Array[StringName] = []

var drone_damage_mult: float = BASE_DRONE_DAMAGE_MULT
var drone_click_interval: float = BASE_DRONE_CLICK_INTERVAL

var gold_cube_chance: float = BASE_GOLD_CUBE_CHANCE
var gold_payout_bonus: float = 0.0

var explosive_chance: float = BASE_EXPLOSIVE_CHANCE
var explosion_damage_mult: float = BASE_EXPLOSION_DAMAGE_MULT
var explosion_radius: int = BASE_EXPLOSION_RADIUS

var splash_fraction: float = BASE_SPLASH_FRACTION
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

#region - SKILLS
func has_skill(skill: SkillNodeData) -> bool:
	return skill.id in unlocked_skills

func prereqs_met(skill: SkillNodeData) -> bool:
	for required: SkillNodeData in skill.prereqs:
		if not has_skill(required):
			return false
	return true

func can_buy_skill(skill: SkillNodeData) -> bool:
	return not has_skill(skill) and prereqs_met(skill) and core_shards >= skill.cost

func try_buy_skill(skill: SkillNodeData) -> bool:
	if not can_buy_skill(skill):
		return false
	core_shards -= skill.cost
	unlocked_skills.append(skill.id)
	recalc_stats()
	core_shards_changed.emit(core_shards)
	skills_changed.emit()
	return true
#endregion

func add_gold(amount: float) -> void:
	gold += amount * DEBUG_GOLD_MULT
	gold_changed.emit(gold)

func roll_crit() -> bool:
	return  randf() < crit_chance

func get_click_damage(is_crit: bool) -> float:
	return click_damage * crit_mult if is_crit else click_damage

func get_level(upgrade: UpgradeData) -> int:
	return upgrade_levels.get(upgrade.id, 0)

func recalc_stats() -> void:
	click_damage = BASE_CLICK_DAMAGE + get_level(CLICK_DAMAGE_UPGRADE) * CLICK_DAMAGE_UPGRADE.effect_per_level
	crit_chance = BASE_CRIT_CHANCE + get_level(CRIT_CHANCE_UPGRADE) * CRIT_CHANCE_UPGRADE.effect_per_level
	crit_mult = BASE_CRIT_MULT + get_level(CRIT_MULT_UPGRADE) * CRIT_MULT_UPGRADE.effect_per_level
	
	drone_damage_mult = BASE_DRONE_DAMAGE_MULT + get_level(DRONE_DAMAGE_UPGRADE) * DRONE_DAMAGE_UPGRADE.effect_per_level
	drone_click_interval = BASE_DRONE_CLICK_INTERVAL / (1.0 + get_level(DRONE_SPEED_UPGRADE) * DRONE_SPEED_UPGRADE.effect_per_level)
	if has_skill(DRONE_SPLASH_SKILL):
		drone_click_interval *= DRONE_SPLASH_INTERVAL_MULT
	
	gold_cube_chance = BASE_GOLD_CUBE_CHANCE + get_level(GOLD_CHANCE_UPGRADE) * GOLD_CHANCE_UPGRADE.effect_per_level
	gold_payout_bonus = get_level(GOLD_PAYOUT_UPGRADE) * GOLD_PAYOUT_UPGRADE.effect_per_level
	
	explosive_chance = BASE_EXPLOSIVE_CHANCE + get_level(EXPLOSIVE_CHANCE_UPGRADE) * EXPLOSIVE_CHANCE_UPGRADE.effect_per_level
	explosion_damage_mult = BASE_EXPLOSION_DAMAGE_MULT + get_level(EXPLOSIVE_DAMAGE_UPGRADE) * EXPLOSIVE_DAMAGE_UPGRADE.effect_per_level
	explosion_radius = BASE_EXPLOSION_RADIUS + int(get_level(EXPLOSIVE_RADIUS_UPGRADE) * EXPLOSIVE_RADIUS_UPGRADE.effect_per_level)
	
	splash_fraction = BASE_SPLASH_FRACTION + get_level(SPLASH_UPGRADE) * SPLASH_UPGRADE.effect_per_level

func _ready() -> void:
	if DEBUG_GOLD_MULT > 1.0:
		push_warning("DEBUG_GOLD_MULT is %s" % DEBUG_GOLD_MULT)
	recalc_stats()

func try_buy(upgrade: UpgradeData) -> bool:
	if upgrade.required_skill and not has_skill(upgrade.required_skill):
		return false
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

#region - DRONES
func get_drone_count() -> int:
	if not has_skill(CLICKER_DRONE_SKILL):
		return 0
	return 1 + get_level(BUY_DRONE_UPGRADE)

func get_drone_damage() -> float:
	return click_damage * drone_damage_mult
#endregion
