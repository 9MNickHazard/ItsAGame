extends Node

@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

signal level_up(new_level: int)
signal experience_gained(current_xp: int, xp_for_next_level: int)

var current_level: int = 1
var current_xp: int = 0
var xp_table: Dictionary = {
	2: 3500,
	3: 9500,
	4: 18000,
	5: 29000,
	6: 46000,
	7: 70000,
	8: 95000,
	9: 120000,
	10: 170000,
	11: 230000,
	12: 300000
}

static var xp_bonus_multiplier: float = 1.0

func add_experience(amount: int) -> void:
	amount = int(ceil(amount * xp_bonus_multiplier))
	current_xp += amount
	
	var level_up_occurred: bool = false
	while current_level < 12 and current_xp >= xp_table[current_level + 1]:
		current_level += 1
		level_up_occurred = true
		level_up.emit(current_level)
		
		if current_level > stats_manager.highest_level_reached:
			stats_manager.highest_level_reached = current_level
	
	var xp_needed: int = xp_table[current_level + 1] if current_level < 12 else 0
	experience_gained.emit(current_xp, xp_needed)

func get_current_level() -> int:
	return current_level

func get_xp_for_next_level() -> int:
	return xp_table[current_level + 1] if current_level < 12 else 0

func get_current_xp() -> int:
	return current_xp

func get_xp_bonus() -> float:
	return xp_bonus_multiplier

static func change_xp_bonus(bonus) -> void:
	xp_bonus_multiplier = bonus
