extends Node

#signal mobs_remaining_changed(remaining_count: int)
signal difficulty_increased(new_difficulty: float)

enum SpawnPattern { RANDOM, CIRCLE }

@onready var player: CharacterBody2D = get_node("/root/world/player")
@onready var ui: CanvasLayer = get_node("/root/world/UI")
@onready var pause_menu: CanvasLayer = get_node("/root/world/PauseMenu")
@onready var path_follow: PathFollow2D = get_node("/root/world/Mob1 Spawn Path/Mob1 PathFollow2D")
@onready var spawn_timer: Timer = $SpawnTimer
@onready var difficulty_timer: Timer = $DifficultyTimer
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

var goblin_scene: PackedScene = preload("res://scenes/mob_1.tscn")
var tnt_goblin_scene: PackedScene = preload("res://scenes/tnt_goblin.tscn")
var wizard_scene: PackedScene = preload("res://scenes/wizard_1.tscn")
var martial_hero_scene: PackedScene = preload("res://scenes/martial_hero.tscn")
var skeleton_boss_scene: PackedScene = preload("res://scenes/skeleton_boss.tscn")
var minotaur_scene: PackedScene = preload("res://scenes/minotaur.tscn")
var healer_scene: PackedScene = preload("res://scenes/healer.tscn")
var skeleton_archer_scene: PackedScene = preload("res://scenes/skeleton_archer.tscn")

# Difficulty settings
var base_difficulty: float = 1.0
var current_difficulty: float = 1.0
var difficulty_increment: float = 0.1
var difficulty_increment_time: float = 20.0  # Seconds between difficulty increases
var max_difficulty: float = 10.0

# Spawn settings
var base_spawn_delay: float = 0.6
var min_spawn_delay: float = 0.05
var active_mobs: Array[Node] = []
var spawning_in_progress: bool = false
var game_paused: bool = false

# Enemy weights based on difficulty
# Structure: {scene: {min_difficulty: X, max_difficulty: Y, weight_at_min: W1, weight_at_max: W2}}
var enemy_weights: Dictionary = {
	"goblin": {"scene": goblin_scene, "min_difficulty": 1.0, "max_difficulty": 10.0, "weight_at_min": 100, "weight_at_max": 30},
	"tnt_goblin": {"scene": tnt_goblin_scene, "min_difficulty": 1.1, "max_difficulty": 10.0, "weight_at_min": 15, "weight_at_max": 30},
	"wizard": {"scene": wizard_scene, "min_difficulty": 1.5, "max_difficulty": 10.0, "weight_at_min": 10, "weight_at_max": 25},
	"martial_hero": {"scene": martial_hero_scene, "min_difficulty": 2.0, "max_difficulty": 10.0, "weight_at_min": 5, "weight_at_max": 20},
	"skeleton_archer": {"scene": skeleton_archer_scene, "min_difficulty": 2.2, "max_difficulty": 10.0, "weight_at_min": 10, "weight_at_max": 25},
	"healer": {"scene": healer_scene, "min_difficulty": 3.0, "max_difficulty": 10.0, "weight_at_min": 5, "weight_at_max": 15},
	"minotaur": {"scene": minotaur_scene, "min_difficulty": 3.5, "max_difficulty": 10.0, "weight_at_min": 5, "weight_at_max": 15}
}

# Special spawn events (mini-bosses, boss waves, etc.)
var special_spawns: Array[Dictionary] = [
	{"type": "horde", "difficulty_trigger": 1.0, "enemies": [
		{"scene": "goblin", "count": 10}
	], "pattern": SpawnPattern.CIRCLE, "radius": 900.0},
	
	{"type": "horde", "difficulty_trigger": 1.3, "enemies": [
		{"scene": "goblin", "count": 25}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1100.0},
	# Difficulty 1.5 - Basic goblin horde
	{"type": "horde", "difficulty_trigger": 1.5, "enemies": [
		{"scene": "goblin", "count": 30}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1000.0},
	
	# Difficulty 2.0 - Goblins with TNT goblins
	{"type": "horde", "difficulty_trigger": 2.0, "enemies": [
		{"scene": "goblin", "count": 30},
		{"scene": "tnt_goblin", "count": 10}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1100.0},
	
	# Difficulty 2.5 - Goblins with archers
	{"type": "horde", "difficulty_trigger": 2.5, "enemies": [
		{"scene": "goblin", "count": 30},
		{"scene": "skeleton_archer", "count": 6}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1200.0},
	
	# Difficulty 3.0 - Mixed horde with minotaur
	{"type": "horde", "difficulty_trigger": 3.0, "enemies": [
		{"scene": "goblin", "count": 35},
		{"scene": "tnt_goblin", "count": 8},
		{"scene": "skeleton_archer", "count": 6},
		{"scene": "minotaur", "count": 2}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1100.0},
	
	# Difficulty 3.5 - First double circle (inner/outer)
	{"type": "double_circle", "difficulty_trigger": 3.5, "circles": [
		{"enemies": [
			{"scene": "goblin", "count": 25}
		], "radius": 800.0},
		{"enemies": [
			{"scene": "tnt_goblin", "count": 10},
			{"scene": "skeleton_archer", "count": 10}
		], "radius": 1300.0}
	]},
	
	# Difficulty 4.0 - Stronger mixed horde with wizard
	{"type": "horde", "difficulty_trigger": 4.0, "enemies": [
		{"scene": "goblin", "count": 35},
		{"scene": "tnt_goblin", "count": 10},
		{"scene": "wizard", "count": 4}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1200.0},
	
	# Difficulty 4.5 - First boss appearance
	{"type": "boss_wave", "difficulty_trigger": 4.5, "enemies": [
		{"scene": "goblin", "count": 30},
		{"scene": "skeleton_boss", "count": 1}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1100.0},
	
	# Difficulty 5.0 - Mixed martial horde
	{"type": "horde", "difficulty_trigger": 5.0, "enemies": [
		{"scene": "goblin", "count": 40},
		{"scene": "martial_hero", "count": 3},
		{"scene": "wizard", "count": 2}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1200.0},
	
	# Difficulty 5.5 - Double circle with minotaurs and archers
	{"type": "double_circle", "difficulty_trigger": 5.5, "circles": [
		{"enemies": [
			{"scene": "minotaur", "count": 2}
		], "radius": 600.0},
		{"enemies": [
			{"scene": "skeleton_archer", "count": 12}
		], "radius": 1400.0}
	]},
	
	# Difficulty 6.0 - Advanced mixed horde
	{"type": "horde", "difficulty_trigger": 6.0, "enemies": [
		{"scene": "goblin", "count": 45},
		{"scene": "tnt_goblin", "count": 15},
		{"scene": "martial_hero", "count": 4},
		{"scene": "wizard", "count": 3}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1200.0},
	
	# Difficulty 6.5 - Healer introduction
	{"type": "horde", "difficulty_trigger": 6.5, "enemies": [
		{"scene": "goblin", "count": 40},
		{"scene": "tnt_goblin", "count": 10},
		{"scene": "healer", "count": 2}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1100.0},
	
	# Difficulty 7.0 - Double boss wave
	{"type": "boss_wave", "difficulty_trigger": 7.0, "enemies": [
		{"scene": "goblin", "count": 35},
		{"scene": "minotaur", "count": 3},
		{"scene": "skeleton_boss", "count": 1}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1200.0},
	
	# Difficulty 7.5 - Triple circle hardcore wave
	{"type": "triple_circle", "difficulty_trigger": 7.5, "circles": [
		{"enemies": [
			{"scene": "martial_hero", "count": 6}
		], "radius": 700.0},
		{"enemies": [
			{"scene": "wizard", "count": 5}
		], "radius": 1200.0},
		{"enemies": [
			{"scene": "skeleton_archer", "count": 8}
		], "radius": 1600.0}
	]},
	
	# Difficulty 8.0 - Advanced boss with healers
	{"type": "boss_wave", "difficulty_trigger": 8.0, "enemies": [
		{"scene": "goblin", "count": 50},
		{"scene": "healer", "count": 3},
		{"scene": "skeleton_boss", "count": 1}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1300.0},
	
	# Difficulty 8.5 - Double circle mixed elite
	{"type": "double_circle", "difficulty_trigger": 8.5, "circles": [
		{"enemies": [
			{"scene": "minotaur", "count": 4},
			{"scene": "healer", "count": 2}
		], "radius": 800.0},
		{"enemies": [
			{"scene": "martial_hero", "count": 8},
			{"scene": "wizard", "count": 4}
		], "radius": 1400.0}
	]},
	
	# Difficulty 9.0 - Elite horde
	{"type": "horde", "difficulty_trigger": 9.0, "enemies": [
		{"scene": "goblin", "count": 55},
		{"scene": "tnt_goblin", "count": 20},
		{"scene": "martial_hero", "count": 8},
		{"scene": "wizard", "count": 5},
		{"scene": "minotaur", "count": 5},
		{"scene": "skeleton_archer", "count": 10}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1500.0},
	
	# Difficulty 9.5 - Double boss wave 
	{"type": "boss_wave", "difficulty_trigger": 9.5, "enemies": [
		{"scene": "goblin", "count": 40},
		{"scene": "healer", "count": 3},
		{"scene": "skeleton_boss", "count": 2}
	], "pattern": SpawnPattern.CIRCLE, "radius": 1300.0},
	
	# Difficulty 10.0 - Ultimate double circle challenge
	{"type": "double_circle", "difficulty_trigger": 10.0, "circles": [
		{"enemies": [
			{"scene": "goblin", "count": 25},
			{"scene": "tnt_goblin", "count": 10},
			{"scene": "minotaur", "count": 4},
			{"scene": "martial_hero", "count": 5},
			{"scene": "skeleton_boss", "count": 1}
		], "radius": 900.0},
		{"enemies": [
			{"scene": "goblin", "count": 35},
			{"scene": "wizard", "count": 4},
			{"scene": "skeleton_archer", "count": 10},
			{"scene": "minotaur", "count": 4},
			{"scene": "martial_hero", "count": 5},
			{"scene": "healer", "count": 4},
			{"scene": "skeleton_boss", "count": 1}
		], "radius": 1600.0}
	]}
]

var triggered_special_spawns: Array[int] = []
var total_mobs_spawned: int = 0

func _ready() -> void:
	spawn_timer.wait_time = base_spawn_delay
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	difficulty_timer.wait_time = difficulty_increment_time
	difficulty_timer.timeout.connect(_on_difficulty_timer_timeout)
	
	# Connect to player level up signal
	if ui and ui.experience_manager:
		ui.experience_manager.level_up.connect(_on_player_level_up)
	
	call_deferred("start_game")

func _process(delta: float) -> void:
	if game_paused:
		return
	
	# Check for special spawn events
	check_special_spawns()
	
	## Update UI if needed
	#if active_mobs.size() % 5 == 0:  # Only update every 5 mob changes to reduce overhead
		#emit_signal("mobs_remaining_changed", active_mobs.size())

func start_game() -> void:
	spawn_timer.wait_time = calculate_spawn_delay()
	spawn_timer.start()
	difficulty_timer.start()
	game_paused = false
	
	triggered_special_spawns.clear()
	total_mobs_spawned = 0
	
	emit_signal("difficulty_increased", current_difficulty)

func pause_game() -> void:
	game_paused = true
	spawn_timer.paused = true
	difficulty_timer.paused = true

func resume_game() -> void:
	game_paused = false
	spawn_timer.paused = false
	difficulty_timer.paused = false

func _on_difficulty_timer_timeout() -> void:
	if current_difficulty < max_difficulty:
		current_difficulty += difficulty_increment
		current_difficulty = min(current_difficulty, max_difficulty)
		
		# Adjust spawn rate based on new difficulty
		spawn_timer.wait_time = calculate_spawn_delay()
		
		emit_signal("difficulty_increased", current_difficulty)
		
		print("Difficulty increased to: ", current_difficulty)
		print("New spawn delay: ", spawn_timer.wait_time)

func calculate_spawn_delay() -> float:
	# Logarithmic decrease in spawn delay as difficulty increases
	var difficulty_factor: float = (current_difficulty - base_difficulty) / (max_difficulty - base_difficulty)
	return max(min_spawn_delay, base_spawn_delay * (1.0 - 0.7 * difficulty_factor))

func _on_spawn_timer_timeout() -> void:
	if game_paused:
		return
	
	var mob_scene: PackedScene = select_enemy_based_on_difficulty()
	if mob_scene:
		spawn_enemy(mob_scene, SpawnPattern.RANDOM)

func select_enemy_based_on_difficulty() -> PackedScene:
	var total_weight: float = 0.0
	var available_enemies: Array[Dictionary] = []
	
	# Calculate weights for all enemies at current difficulty
	for enemy_key in enemy_weights:
		var enemy: Dictionary = enemy_weights[enemy_key]
		
		if current_difficulty >= enemy["min_difficulty"]:
			var weight: float = calculate_weight(enemy, current_difficulty)
			if weight > 0:
				available_enemies.append({"scene": enemy["scene"], "weight": weight})
				total_weight += weight
	
	# Select an enemy based on weight
	if total_weight > 0:
		var random_value: float = randf() * total_weight
		var cumulative_weight: float = 0.0
		
		for enemy in available_enemies:
			cumulative_weight += enemy["weight"]
			if random_value <= cumulative_weight:
				return enemy["scene"]
	
	# Fallback to goblin if something went wrong
	return goblin_scene

func calculate_weight(enemy_config: Dictionary, difficulty: float) -> float:
	var min_diff: float = enemy_config["min_difficulty"]
	var max_diff: float = enemy_config["max_difficulty"]
	
	if difficulty < min_diff:
		return 0.0
	
	var clamped_diff: float = clamp(difficulty, min_diff, max_diff)
	var difficulty_ratio: float = (clamped_diff - min_diff) / (max_diff - min_diff)
	
	var min_weight: float = enemy_config["weight_at_min"]
	var max_weight: float = enemy_config["weight_at_max"]
	
	return min_weight + (max_weight - min_weight) * difficulty_ratio

func spawn_enemy(enemy_scene: PackedScene, pattern: int, radius: float = 900.0) -> void:
	var new_mob: Node = enemy_scene.instantiate()
	
	if pattern == SpawnPattern.RANDOM:
		if path_follow != null:
			path_follow.progress_ratio = randf()
			new_mob.global_position = path_follow.global_position
		else:
			push_error("Path follow node not found!")
			new_mob.global_position = Vector2(randf_range(-1000, 1000), randf_range(-600, 600))
	elif pattern == SpawnPattern.CIRCLE:
		var angle: float = randf() * 2 * PI
		var spawn_position: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * radius
		new_mob.global_position = spawn_position
	
	add_child(new_mob)
	#active_mobs.append(new_mob)
	#new_mob.tree_exiting.connect(_on_mob_tree_exiting.bind(new_mob))
	total_mobs_spawned += 1

func spawn_group(pattern: int, enemies: Array, radius: float = 900.0) -> void:
	var total_enemies: int = 0
	for enemy_config in enemies:
		var scene_key: String = enemy_config["scene"]
		var count: int = enemy_config["count"]
		total_enemies += count
	
	if pattern == SpawnPattern.CIRCLE:
		# Spawn in a circle around the player
		for i in range(total_enemies):
			var enemy_index: int = 0
			var enemy_count: int = 0
			var current_count: int = 0
			
			# Find which enemy type to spawn based on the current index
			for enemy_idx in range(enemies.size()):
				var count: int = enemies[enemy_idx]["count"]
				if i >= current_count && i < (current_count + count):
					enemy_index = enemy_idx
					enemy_count = i - current_count
					break
				current_count += count
			
			var scene_key: String = enemies[enemy_index]["scene"]
			var enemy_scene: PackedScene = get_enemy_scene_by_key(scene_key)
			
			var angle: float = (2 * PI / total_enemies) * i
			var spawn_position: Vector2 = player.global_position + Vector2(cos(angle), sin(angle)) * radius
			
			var new_mob: Node = enemy_scene.instantiate()
			new_mob.global_position = spawn_position
			add_child(new_mob)
			#active_mobs.append(new_mob)
			#new_mob.tree_exiting.connect(_on_mob_tree_exiting.bind(new_mob))
			total_mobs_spawned += 1
	else:
		# Spawn randomly
		for enemy_config in enemies:
			var scene_key: String = enemy_config["scene"]
			var count: int = enemy_config["count"]
			var enemy_scene: PackedScene = get_enemy_scene_by_key(scene_key)
			
			for i in range(count):
				if path_follow != null:
					path_follow.progress_ratio = randf()
					var new_mob: Node = enemy_scene.instantiate()
					new_mob.global_position = path_follow.global_position
					add_child(new_mob)
					#active_mobs.append(new_mob)
					#new_mob.tree_exiting.connect(_on_mob_tree_exiting.bind(new_mob))
					total_mobs_spawned += 1

func get_enemy_scene_by_key(key: String) -> PackedScene:
	match key:
		"goblin": return goblin_scene
		"tnt_goblin": return tnt_goblin_scene
		"wizard": return wizard_scene
		"martial_hero": return martial_hero_scene
		"skeleton_boss": return skeleton_boss_scene
		"minotaur": return minotaur_scene
		"healer": return healer_scene
		"skeleton_archer": return skeleton_archer_scene
		_: return goblin_scene # Default fallback

func check_special_spawns() -> void:
	for i in range(special_spawns.size()):
		var spawn_event: Dictionary = special_spawns[i]
		
		if not triggered_special_spawns.has(i) and current_difficulty >= spawn_event["difficulty_trigger"]:
			print("Triggering special spawn: ", spawn_event["type"])
			spawn_group(spawn_event["pattern"], spawn_event["enemies"], spawn_event["radius"])
			triggered_special_spawns.append(i)

func _on_player_level_up(new_level: int) -> void:
	# Pause the game
	pause_game()
	
	get_tree().paused = true
	
	# Update needed statistics
	if stats_manager:
		if new_level > stats_manager.highest_level_reached:
			stats_manager.highest_level_reached = new_level
	
	if pause_menu:
		pause_menu.update_cost_labels()
		pause_menu.player_coins_label.text = "Coins: " + str(ui.coins_collected)
		pause_menu.continue_button.visible = true
		pause_menu.visible = true

#func _on_mob_tree_exiting(mob: Node) -> void:
	#if active_mobs.has(mob):
		#active_mobs.erase(mob)
		##emit_signal("mobs_remaining_changed", active_mobs.size())
