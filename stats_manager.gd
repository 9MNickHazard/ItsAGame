extends Node2D

@onready var play_time_timer = $PlayTimeTimer

var total_play_time_seconds: float = 0.0

# item collection
var total_coins_collected = 0
var total_hearts_collected = 0
var total_mana_balls_collected = 0
var total_diamonds_collected = 0

# combat stats
var damage_dealt_to_enemies = 0
var damage_taken_from_enemies = 0
var total_enemies_killed = 0
var enemy_kills_by_type = {}

# ability usage
var total_blinks_used = 0
var total_shockwaves_used = 0
var total_gravity_wells_used = 0
var total_shots_fired = 0
var shots_fired_by_weapon = {}

# progress stats
var rounds_completed = 0
var highest_round_reached = 0
var highest_level_reached = 1

func _ready():
	play_time_timer.timeout.connect(_on_timer_timeout)
	reset_stats()

func _on_timer_timeout():
	total_play_time_seconds += 1.0

func reset_stats():
	total_play_time_seconds = 0.0
	play_time_timer.stop()
	
	total_coins_collected = 0
	total_hearts_collected = 0
	total_mana_balls_collected = 0
	total_diamonds_collected = 0
	damage_dealt_to_enemies = 0
	damage_taken_from_enemies = 0
	total_enemies_killed = 0
	enemy_kills_by_type = {}
	total_blinks_used = 0
	total_shockwaves_used = 0
	total_gravity_wells_used = 0
	total_shots_fired = 0
	shots_fired_by_weapon = {}
	rounds_completed = 0
	highest_round_reached = 0
	highest_level_reached = 1

func start_tracking():
	play_time_timer.start()

func stop_tracking():
	play_time_timer.stop()

func get_formatted_time() -> String:
	var seconds = int(total_play_time_seconds) % 60
	var minutes = (int(total_play_time_seconds) / 60) % 60
	var hours = int(total_play_time_seconds) / 3600
	
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, seconds]
	else:
		return "%d:%02d" % [minutes, seconds]

func add_enemy_kill(enemy_type: String):
	total_enemies_killed += 1
	
	if enemy_kills_by_type.has(enemy_type):
		enemy_kills_by_type[enemy_type] += 1
	else:
		enemy_kills_by_type[enemy_type] = 1
