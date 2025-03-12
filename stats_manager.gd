extends Node2D

@onready var play_time_timer: Timer = $PlayTimeTimer

var total_play_time_seconds: float = 0.0

# item collection
var total_coins_collected: int = 0
var total_hearts_collected: int = 0
var total_mana_balls_collected: int = 0
var total_diamonds_collected: int = 0

# combat stats
var damage_dealt_to_enemies: float = 0.0
var damage_taken_from_enemies: float = 0.0
var total_enemies_killed: int = 0
var enemy_kills_by_type: Dictionary = {}

# ability usage
var total_blinks_used: int = 0
var total_shockwaves_used: int = 0
var total_gravity_wells_used: int = 0
var total_orbital_abilities_used: int = 0
var total_shots_fired: int = 0
var shots_fired_by_weapon: Dictionary = {}

# progress stats
var highest_difficulty_reached: float = 1.0
var highest_level_reached: int = 1

func _ready() -> void:
	play_time_timer.timeout.connect(_on_timer_timeout)
	reset_stats()
	
	# Connect to difficulty manager if it exists
	var difficulty_manager = get_node_or_null("/root/world/DifficultyManager")
	if difficulty_manager:
		difficulty_manager.difficulty_increased.connect(_on_difficulty_increased)

func _on_timer_timeout() -> void:
	total_play_time_seconds += 1.0

func reset_stats() -> void:
	total_play_time_seconds = 0.0
	play_time_timer.stop()
	
	total_coins_collected = 0
	total_hearts_collected = 0
	total_mana_balls_collected = 0
	total_diamonds_collected = 0
	damage_dealt_to_enemies = 0.0
	damage_taken_from_enemies = 0.0
	total_enemies_killed = 0
	enemy_kills_by_type = {}
	total_blinks_used = 0
	total_shockwaves_used = 0
	total_gravity_wells_used = 0
	total_orbital_abilities_used = 0
	total_shots_fired = 0
	shots_fired_by_weapon = {}
	highest_difficulty_reached = 1.0
	highest_level_reached = 1

func start_tracking() -> void:
	play_time_timer.start()

func stop_tracking() -> void:
	play_time_timer.stop()

func get_formatted_time() -> String:
	var seconds: int = int(total_play_time_seconds) % 60
	var minutes: int = (int(total_play_time_seconds) / 60) % 60
	var hours: int = int(total_play_time_seconds) / 3600
	
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%d:%02d" % [minutes, seconds]

func add_enemy_kill(enemy_type: String) -> void:
	total_enemies_killed += 1
	
	if enemy_kills_by_type.has(enemy_type):
		enemy_kills_by_type[enemy_type] += 1
	else:
		enemy_kills_by_type[enemy_type] = 1

func _on_difficulty_increased(new_difficulty: float) -> void:
	if new_difficulty > highest_difficulty_reached:
		highest_difficulty_reached = new_difficulty
