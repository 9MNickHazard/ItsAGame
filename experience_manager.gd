extends Node

@onready var stats_manager = get_node("/root/world/StatsManager")

signal level_up(new_level)
signal experience_gained(current_xp, xp_for_next_level)

var current_level = 1
var current_xp = 0
var xp_table = {
	1: 500,
	2: 1100,
	3: 1800,
	4: 2600,
	5: 3500,
	6: 4500,
	7: 5600,
	8: 6800,
	9: 8100,
	10: 9500,
	11: 11000,
	12: 12600,
	13: 14300,
	14: 16100,
	15: 18000,
	16: 20000,
	17: 22100,
	18: 24300,
	19: 26600,
	20: 29000,
	21: 32000,
	22: 35200,
	23: 38600,
	24: 42200,
	25: 46000,
	26: 50000,
	27: 55000,
	28: 60000,
	29: 65000,
	30: 70000,
	31: 75000,
	32: 80000,
	33: 85000,
	34: 90000,
	35: 95000,
	36: 100000,
	37: 105000,
	38: 110000,
	39: 115000,
	40: 120000,
	41: 130000,
	42: 140000,
	43: 150000,
	44: 160000,
	45: 170000,
	46: 180000,
	47: 190000,
	48: 200000,
	49: 210000,
	50: 220000
}

func add_experience(amount: int):
	current_xp += amount
	
	while current_level < 50 and current_xp >= xp_table[current_level]:
		current_level += 1
		level_up.emit(current_level)
		
		if current_level > stats_manager.highest_level_reached:
			stats_manager.highest_level_reached = current_level
	
	var xp_needed = xp_table[current_level] if current_level < 50 else 0
	experience_gained.emit(current_xp, xp_needed)

func get_current_level() -> int:
	return current_level

func get_xp_for_next_level() -> int:
	return xp_table[current_level] if current_level < 50 else 0

func get_current_xp() -> int:
	return current_xp
