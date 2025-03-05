extends Node

signal round_started(round_number)
signal wave_started(wave_number)
signal round_ended(round_number)
signal all_rounds_completed

# Wave spawning patterns
enum SpawnPattern { RANDOM, CIRCLE }

# Wave definition - contains data for a single wave of enemies
class Wave:
	var mob_scenes = [] # Array of preloaded mob scenes
	var mob_counts = [] # How many of each mob to spawn
	var spawn_pattern = SpawnPattern.RANDOM
	var spawn_delay = 1.0 # Time between spawns
	var circle_radius = 600.0 # Radius when using circle pattern
	var wave_cooldown = 10.0
	# for initial batch spawning
	var initial_batch = false
	var initial_batch_mobs = []
	var initial_batch_counts = []
	var initial_batch_pattern = SpawnPattern.RANDOM
	var initial_batch_radius = 700.0

# Round definition - contains multiple waves
class Round:
	var waves = [] # Array of Wave objects
	var round_number = 1

# Mob scene preloads
var goblin_scene = preload("res://scenes/mob_1.tscn")
var tnt_goblin_scene = preload("res://scenes/tnt_goblin.tscn")
var wizard_scene = preload("res://scenes/wizard_1.tscn")
var martial_hero_scene = preload("res://scenes/martial_hero.tscn")
var skeleton_boss_scene = preload("res://scenes/skeleton_boss.tscn")

# Nodes
@onready var player = get_node("/root/world/player")
@onready var ui = get_node("/root/world/UI")
@onready var pause_menu = get_node("/root/world/PauseMenu")
@onready var path_follow = get_node("/root/world/Mob1 Spawn Path/Mob1 PathFollow2D")
@onready var spawn_timer = $SpawnTimer
@onready var round_ending_popup = get_node("/root/world/UI/RoundEndingPopup")
@onready var round_ending_animation_player = get_node("/root/world/UI/RoundEndingPopup/AnimationPlayer")
@onready var player_coins_label = get_node("/root/world/PauseMenu/MainMargin/MainPanel/VBoxMain/TopRow/VBoxContainer/CoinsLabel")
# round ending
var round_ending_countdown = 5
var round_ending_timer = 0.0
var round_ending_in_progress = false
var previous_countdown_second = -1

# Round tracking
var rounds = []
var current_round_index = 0
var current_wave_index = 0
var current_mob_index = 0
var active_mobs = []
var spawning_in_progress = false
var round_in_progress = false
var wave_timer = 0.0
var wave_timer_active = false

func _ready():
	# Create the rounds and waves
	setup_rounds()
	
	## for testing, set round index
	#current_round_index = 3
	
	# Connect to necessary signals
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# Create the animation for round ending popup
	create_round_ending_animation()
	
	# Hide the popup initially
	round_ending_popup.visible = false
	
	# Start the first round immediately
	call_deferred("start_round")

func _process(delta):
	# Handle round ending countdown
	if round_ending_in_progress:
		round_ending_timer += delta
		
		# Update countdown every second
		var current_countdown = round_ending_countdown - floor(round_ending_timer)
		if current_countdown >= 0:
			round_ending_popup.text = "Round Ending in " + str(current_countdown) + "..."
			
			# Play animation on each second change
			var current_second = floor(round_ending_timer)
			if current_second != previous_countdown_second:
				previous_countdown_second = current_second
				round_ending_animation_player.stop()
				round_ending_animation_player.play("countdown")
		
		# When countdown finishes
		if round_ending_timer >= round_ending_countdown:
			round_ending_in_progress = false
			round_ending_popup.visible = false
			
			# Show pause menu
			show_pause_menu()
			return
	# If we're waiting for next wave
	elif wave_timer_active:
		wave_timer += delta
		var current_wave = rounds[current_round_index].waves[current_wave_index]
		if wave_timer >= current_wave.wave_cooldown:
			wave_timer = 0.0
			wave_timer_active = false
			
			# Progress to next wave or round
			progress_to_next_wave_or_round()
	
	# Check if all enemies defeated before timer runs out
	elif round_in_progress and !spawning_in_progress:
		# If no more active mobs, move to next wave/round immediately
		if active_mobs.size() == 0:
			if current_wave_index < rounds[current_round_index].waves.size() - 1:
				# More waves in this round, start next wave
				current_wave_index += 1
				start_wave()
			else:
				# Round complete
				round_in_progress = false
				emit_signal("round_ended", rounds[current_round_index].round_number)
				
				# Move to next round
				current_round_index += 1
				current_wave_index = 0
				
				if current_round_index < rounds.size():
					# Show pause menu between rounds
					start_round_ending_countdown()
				else:
					# All rounds complete
					emit_signal("all_rounds_completed")
		# Otherwise, start the wave timer if not already active
		elif !wave_timer_active and current_wave_index < rounds[current_round_index].waves.size() - 1:
			wave_timer_active = true
			wave_timer = 0.0


func setup_rounds():
	# ROUND 1
	var round1 = Round.new()
	round1.round_number = 1
	
	# Wave 1
	var wave1 = Wave.new()
	wave1.mob_scenes = [goblin_scene]
	wave1.mob_counts = [10]
	wave1.spawn_pattern = SpawnPattern.CIRCLE
	wave1.spawn_delay = 1.0
	wave1.wave_cooldown = 5.0
	wave1.circle_radius = 900.0
	
	wave1.initial_batch = true
	wave1.initial_batch_mobs = [goblin_scene]
	wave1.initial_batch_counts = [25]
	wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round1.waves.append(wave1)
	
	# Wave 2
	var wave2 = Wave.new()
	wave2.mob_scenes = [goblin_scene, tnt_goblin_scene]
	wave2.mob_counts = [12, 3]
	wave2.spawn_pattern = SpawnPattern.RANDOM
	wave2.spawn_delay = 0.5
	wave2.wave_cooldown = 15.0
	
	wave2.initial_batch = true
	wave2.initial_batch_mobs = [goblin_scene]
	wave2.initial_batch_counts = [7]
	wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round1.waves.append(wave2)
	
	# Wave 3
	var wave3 = Wave.new()
	wave3.mob_scenes = [goblin_scene, tnt_goblin_scene]
	wave3.mob_counts = [15, 5]
	wave3.spawn_pattern = SpawnPattern.RANDOM
	wave3.spawn_delay = 0.5
	wave3.wave_cooldown = 8.0
	wave3.circle_radius = 800.0
	
	wave3.initial_batch = true
	wave3.initial_batch_mobs = [tnt_goblin_scene]
	wave3.initial_batch_counts = [3]
	wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round1.waves.append(wave3)
	
	# Wave 4
	var wave4 = Wave.new()
	wave4.mob_scenes = [tnt_goblin_scene]
	wave4.mob_counts = [8]
	wave4.spawn_pattern = SpawnPattern.RANDOM
	wave4.spawn_delay = 0.5
	wave4.wave_cooldown = 10.0
	
	wave4.initial_batch = true
	wave4.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	wave4.initial_batch_counts = [12, 2]
	wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round1.waves.append(wave4)
	
	rounds.append(round1)
	
	# ROUND 2
	var round2 = Round.new()
	round2.round_number = 2
	
	# Wave 1
	var round2_wave1 = Wave.new()
	round2_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene]
	round2_wave1.mob_counts = [25, 5]
	round2_wave1.spawn_pattern = SpawnPattern.RANDOM
	round2_wave1.spawn_delay = 0.5
	round2_wave1.wave_cooldown = 5.0
	
	round2_wave1.initial_batch = true
	round2_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round2_wave1.initial_batch_counts = [30, 5]
	round2_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round2.waves.append(round2_wave1)
	
	# Wave 2
	var round2_wave2 = Wave.new()
	round2_wave2.mob_scenes = [wizard_scene]
	round2_wave2.mob_counts = [3]
	round2_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round2_wave2.spawn_delay = 0.5
	round2_wave2.wave_cooldown = 5.0
	round2_wave2.circle_radius = 900.0
	
	round2_wave2.initial_batch = true
	round2_wave2.initial_batch_mobs = [wizard_scene]
	round2_wave2.initial_batch_counts = [5]
	round2_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round2.waves.append(round2_wave2)
	
	# Wave 3
	var round2_wave3 = Wave.new()
	round2_wave3.mob_scenes = [goblin_scene, wizard_scene]
	round2_wave3.mob_counts = [20, 2]
	round2_wave3.spawn_pattern = SpawnPattern.RANDOM
	round2_wave3.spawn_delay = 0.6
	round2_wave3.wave_cooldown = 5.0
	round2_wave3.circle_radius = 1200.0
	
	round2_wave3.initial_batch = true
	round2_wave3.initial_batch_mobs = [goblin_scene, wizard_scene]
	round2_wave3.initial_batch_counts = [15, 1]
	round2_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round2.waves.append(round2_wave3)
	
	# Wave 4
	var round2_wave4 = Wave.new()
	round2_wave4.mob_scenes = [tnt_goblin_scene, wizard_scene]
	round2_wave4.mob_counts = [12, 3]
	round2_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round2_wave4.spawn_delay = 0.7
	round2_wave4.wave_cooldown = 5.0
	round2_wave4.circle_radius = 900.0
	
	round2_wave4.initial_batch = true
	round2_wave4.initial_batch_mobs = [tnt_goblin_scene]
	round2_wave4.initial_batch_counts = [5]
	round2_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round2.waves.append(round2_wave4)
	
	# Wave 5
	var round2_wave5 = Wave.new()
	round2_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round2_wave5.mob_counts = [15, 10, 5]
	round2_wave5.spawn_pattern = SpawnPattern.RANDOM
	round2_wave5.spawn_delay = 0.5
	round2_wave5.wave_cooldown = 5.0
	
	round2_wave5.initial_batch = true
	round2_wave5.initial_batch_mobs = [goblin_scene, wizard_scene]
	round2_wave5.initial_batch_counts = [7, 2]
	round2_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round2.waves.append(round2_wave5)
	
	rounds.append(round2)
	
	# ROUND 3
	var round3 = Round.new()
	round3.round_number = 3
	
	# Wave 1
	var round3_wave1 = Wave.new()
	round3_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round3_wave1.mob_counts = [50, 12, 2]
	round3_wave1.spawn_pattern = SpawnPattern.RANDOM
	round3_wave1.spawn_delay = 0.5
	round3_wave1.wave_cooldown = 0.3
	round3_wave1.circle_radius = 1000.0
	
	round3_wave1.initial_batch = true
	round3_wave1.initial_batch_mobs = [goblin_scene]
	round3_wave1.initial_batch_counts = [20]
	round3_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round3.waves.append(round3_wave1)
	
	# Wave 2
	var round3_wave2 = Wave.new()
	round3_wave2.mob_scenes = [wizard_scene]
	round3_wave2.mob_counts = [2]
	round3_wave2.spawn_pattern = SpawnPattern.RANDOM
	round3_wave2.spawn_delay = 1.0
	round3_wave2.wave_cooldown = 5.0
	round3_wave2.circle_radius = 1200.0
	
	round3_wave2.initial_batch = true
	round3_wave2.initial_batch_mobs = [goblin_scene]
	round3_wave2.initial_batch_counts = [25]
	round3_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round3.waves.append(round3_wave2)
	
	# Wave 3
	var round3_wave3 = Wave.new()
	round3_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round3_wave3.mob_counts = [30, 15, 3, 3]
	round3_wave3.spawn_pattern = SpawnPattern.RANDOM
	round3_wave3.spawn_delay = 0.6
	round3_wave3.wave_cooldown = 5.0
	round3_wave3.circle_radius = 850.0
	
	round3_wave3.initial_batch = true
	round3_wave3.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round3_wave3.initial_batch_counts = [5, 1]
	round3_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round3.waves.append(round3_wave3)
	
	# Wave 4
	var round3_wave4 = Wave.new()
	round3_wave4.mob_scenes = [goblin_scene, martial_hero_scene]
	round3_wave4.mob_counts = [25, 1]
	round3_wave4.spawn_pattern = SpawnPattern.RANDOM
	round3_wave4.spawn_delay = 0.5
	round3_wave4.wave_cooldown = 10.0
	
	round3_wave4.initial_batch = true
	round3_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	round3_wave4.initial_batch_counts = [8, 1]
	round3_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round3.waves.append(round3_wave4)
	
	# Wave 5
	var round3_wave5 = Wave.new()
	round3_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round3_wave5.mob_counts = [15, 8, 5, 2]
	round3_wave5.spawn_pattern = SpawnPattern.CIRCLE
	round3_wave5.spawn_delay = 0.4
	round3_wave5.wave_cooldown = 5.0
	round3_wave5.circle_radius = 1100.0
	
	round3_wave5.initial_batch = true
	round3_wave5.initial_batch_mobs = [goblin_scene, wizard_scene]
	round3_wave5.initial_batch_counts = [10, 2]
	round3_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round3.waves.append(round3_wave5)
	
	rounds.append(round3)
	
	var boss_round = Round.new()
	boss_round.round_number = 4
	
	# Wave 2: Boss fight!
	var boss_wave = Wave.new()
	boss_wave.mob_scenes = [skeleton_boss_scene]
	boss_wave.mob_counts = [1]  # Just one boss
	boss_wave.spawn_pattern = SpawnPattern.CIRCLE
	boss_wave.spawn_delay = 2.0  # Dramatic pause before boss spawns
	boss_wave.wave_cooldown = 0.0
	boss_wave.circle_radius = 800.0  # Spawn closer to player for dramatic effect
	
	# Optional: Add some minions with the boss
	boss_wave.initial_batch = true
	boss_wave.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	boss_wave.initial_batch_counts = [20, 4]
	boss_wave.initial_batch_pattern = SpawnPattern.CIRCLE
	boss_wave.initial_batch_radius = 1400.0  # Spawn around the boss
	
	boss_round.waves.append(boss_wave)
	
	rounds.append(boss_round)
	
	# ROUND 5
	var round5 = Round.new()
	round5.round_number = 5
	
	# Wave 1
	var round5_wave1 = Wave.new()
	round5_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round5_wave1.mob_counts = [60, 15, 5, 2]
	round5_wave1.spawn_pattern = SpawnPattern.RANDOM
	round5_wave1.spawn_delay = 0.4
	round5_wave1.wave_cooldown = 0.3
	
	round5_wave1.initial_batch = true
	round5_wave1.initial_batch_mobs = [goblin_scene, wizard_scene]
	round5_wave1.initial_batch_counts = [25, 2]
	round5_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round5.waves.append(round5_wave1)
	
	# Wave 2
	var round5_wave2 = Wave.new()
	round5_wave2.mob_scenes = [wizard_scene, martial_hero_scene]
	round5_wave2.mob_counts = [5, 3]
	round5_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round5_wave2.spawn_delay = 0.8
	round5_wave2.wave_cooldown = 5.0
	round5_wave2.circle_radius = 1300.0
	
	round5_wave2.initial_batch = true
	round5_wave2.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round5_wave2.initial_batch_counts = [30, 10]
	round5_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round5.waves.append(round5_wave2)
	
	# Wave 3
	var round5_wave3 = Wave.new()
	round5_wave3.mob_scenes = [tnt_goblin_scene, wizard_scene]
	round5_wave3.mob_counts = [30, 7]
	round5_wave3.spawn_pattern = SpawnPattern.RANDOM
	round5_wave3.spawn_delay = 0.4
	round5_wave3.wave_cooldown = 5.0
	
	round5_wave3.initial_batch = true
	round5_wave3.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round5_wave3.initial_batch_counts = [10, 3]
	round5_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round5.waves.append(round5_wave3)
	
	# Wave 4
	var round5_wave4 = Wave.new()
	round5_wave4.mob_scenes = [goblin_scene, martial_hero_scene]
	round5_wave4.mob_counts = [40, 4]
	round5_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round5_wave4.spawn_delay = 0.4
	round5_wave4.wave_cooldown = 10.0
	round5_wave4.circle_radius = 1000.0
	
	round5_wave4.initial_batch = true
	round5_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	round5_wave4.initial_batch_counts = [15, 2]
	round5_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round5.waves.append(round5_wave4)
	
	# Wave 5
	var round5_wave5 = Wave.new()
	round5_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round5_wave5.mob_counts = [30, 20, 10, 4]
	round5_wave5.spawn_pattern = SpawnPattern.RANDOM
	round5_wave5.spawn_delay = 0.3
	round5_wave5.wave_cooldown = 5.0
	
	round5_wave5.initial_batch = true
	round5_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round5_wave5.initial_batch_counts = [15, 5, 2]
	round5_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round5.waves.append(round5_wave5)
	
	rounds.append(round5)
	
	# ROUND 6
	var round6 = Round.new()
	round6.round_number = 6

	# Wave 1
	var round6_wave1 = Wave.new()
	round6_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round6_wave1.mob_counts = [75, 25, 10]
	round6_wave1.spawn_pattern = SpawnPattern.CIRCLE
	round6_wave1.spawn_delay = 0.3
	round6_wave1.wave_cooldown = 0.2
	round6_wave1.circle_radius = 1200.0

	round6_wave1.initial_batch = true
	round6_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round6_wave1.initial_batch_counts = [30, 10, 5]
	round6_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round6.waves.append(round6_wave1)

	# Wave 2
	var round6_wave2 = Wave.new()
	round6_wave2.mob_scenes = [martial_hero_scene, wizard_scene]
	round6_wave2.mob_counts = [5, 10]
	round6_wave2.spawn_pattern = SpawnPattern.RANDOM
	round6_wave2.spawn_delay = 0.7
	round6_wave2.wave_cooldown = 5.0

	round6_wave2.initial_batch = true
	round6_wave2.initial_batch_mobs = [martial_hero_scene, wizard_scene]
	round6_wave2.initial_batch_counts = [3, 5]
	round6_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round6.waves.append(round6_wave2)

	# Wave 3
	var round6_wave3 = Wave.new()
	round6_wave3.mob_scenes = [goblin_scene, wizard_scene, martial_hero_scene]
	round6_wave3.mob_counts = [80, 15, 5]
	round6_wave3.spawn_pattern = SpawnPattern.CIRCLE
	round6_wave3.spawn_delay = 0.3
	round6_wave3.wave_cooldown = 5.0
	round6_wave3.circle_radius = 1400.0

	round6_wave3.initial_batch = true
	round6_wave3.initial_batch_mobs = [goblin_scene, wizard_scene]
	round6_wave3.initial_batch_counts = [30, 7]
	round6_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round6.waves.append(round6_wave3)

	# Wave 4
	var round6_wave4 = Wave.new()
	round6_wave4.mob_scenes = [tnt_goblin_scene, wizard_scene]
	round6_wave4.mob_counts = [40, 15]
	round6_wave4.spawn_pattern = SpawnPattern.RANDOM
	round6_wave4.spawn_delay = 0.3
	round6_wave4.wave_cooldown = 8.0

	round6_wave4.initial_batch = true
	round6_wave4.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round6_wave4.initial_batch_counts = [15, 7]
	round6_wave4.initial_batch_pattern = SpawnPattern.CIRCLE
	round6.waves.append(round6_wave4)

	# Wave 5
	var round6_wave5 = Wave.new()
	round6_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round6_wave5.mob_counts = [50, 30, 20, 10]
	round6_wave5.spawn_pattern = SpawnPattern.CIRCLE
	round6_wave5.spawn_delay = 0.2
	round6_wave5.wave_cooldown = 0.0
	round6_wave5.circle_radius = 1500.0

	round6_wave5.initial_batch = true
	round6_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round6_wave5.initial_batch_counts = [25, 10, 5]
	round6_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round6.waves.append(round6_wave5)

	rounds.append(round6)

	# ROUND 7
	var round7 = Round.new()
	round7.round_number = 7

	# Wave 1
	var round7_wave1 = Wave.new()
	round7_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round7_wave1.mob_counts = [30, 15, 8, 2]
	round7_wave1.spawn_pattern = SpawnPattern.RANDOM
	round7_wave1.spawn_delay = 0.4
	round7_wave1.wave_cooldown = 5.0

	round7_wave1.initial_batch = true
	round7_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round7_wave1.initial_batch_counts = [15, 8, 4]
	round7_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round7.waves.append(round7_wave1)

	# Wave 2
	var round7_wave2 = Wave.new()
	round7_wave2.mob_scenes = [wizard_scene, martial_hero_scene]
	round7_wave2.mob_counts = [12, 3]
	round7_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round7_wave2.spawn_delay = 0.6
	round7_wave2.wave_cooldown = 5.0
	round7_wave2.circle_radius = 900.0

	round7_wave2.initial_batch = true
	round7_wave2.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round7_wave2.initial_batch_counts = [5, 1]
	round7_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round7.waves.append(round7_wave2)

	# Wave 3
	var round7_wave3 = Wave.new()
	round7_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene]
	round7_wave3.mob_counts = [40, 20]
	round7_wave3.spawn_pattern = SpawnPattern.RANDOM
	round7_wave3.spawn_delay = 0.3
	round7_wave3.wave_cooldown = 5.0

	round7_wave3.initial_batch = true
	round7_wave3.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round7_wave3.initial_batch_counts = [20, 10]
	round7_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round7.waves.append(round7_wave3)

	# Wave 4
	var round7_wave4 = Wave.new()
	round7_wave4.mob_scenes = [goblin_scene, martial_hero_scene]
	round7_wave4.mob_counts = [30, 6]
	round7_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round7_wave4.spawn_delay = 0.4
	round7_wave4.wave_cooldown = 5.0
	round7_wave4.circle_radius = 950.0

	round7_wave4.initial_batch = true
	round7_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	round7_wave4.initial_batch_counts = [15, 2]
	round7_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round7.waves.append(round7_wave4)

	# Wave 5
	var round7_wave5 = Wave.new()
	round7_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round7_wave5.mob_counts = [35, 20, 12, 6]
	round7_wave5.spawn_pattern = SpawnPattern.RANDOM
	round7_wave5.spawn_delay = 0.3
	round7_wave5.wave_cooldown = 5.0

	round7_wave5.initial_batch = true
	round7_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round7_wave5.initial_batch_counts = [15, 6, 3]
	round7_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round7.waves.append(round7_wave5)

	rounds.append(round7)

	# ROUND 8
	var round8 = Round.new()
	round8.round_number = 8

	# Wave 1
	var round8_wave1 = Wave.new()
	round8_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round8_wave1.mob_counts = [40, 20, 10]
	round8_wave1.spawn_pattern = SpawnPattern.CIRCLE
	round8_wave1.spawn_delay = 0.3
	round8_wave1.wave_cooldown = 5.0
	round8_wave1.circle_radius = 950.0

	round8_wave1.initial_batch = true
	round8_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round8_wave1.initial_batch_counts = [20, 10, 5]
	round8_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round8.waves.append(round8_wave1)

	# Wave 2
	var round8_wave2 = Wave.new()
	round8_wave2.mob_scenes = [martial_hero_scene]
	round8_wave2.mob_counts = [8]
	round8_wave2.spawn_pattern = SpawnPattern.RANDOM
	round8_wave2.spawn_delay = 1.0
	round8_wave2.wave_cooldown = 5.0

	round8_wave2.initial_batch = true
	round8_wave2.initial_batch_mobs = [martial_hero_scene]
	round8_wave2.initial_batch_counts = [3]
	round8_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round8.waves.append(round8_wave2)

	# Wave 3
	var round8_wave3 = Wave.new()
	round8_wave3.mob_scenes = [goblin_scene, wizard_scene, martial_hero_scene]
	round8_wave3.mob_counts = [45, 15, 5]
	round8_wave3.spawn_pattern = SpawnPattern.RANDOM
	round8_wave3.spawn_delay = 0.3
	round8_wave3.wave_cooldown = 5.0

	round8_wave3.initial_batch = true
	round8_wave3.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round8_wave3.initial_batch_counts = [20, 7, 2]
	round8_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round8.waves.append(round8_wave3)

	# Wave 4
	var round8_wave4 = Wave.new()
	round8_wave4.mob_scenes = [tnt_goblin_scene, wizard_scene]
	round8_wave4.mob_counts = [25, 15]
	round8_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round8_wave4.spawn_delay = 0.3
	round8_wave4.wave_cooldown = 5.0
	round8_wave4.circle_radius = 1000.0

	round8_wave4.initial_batch = true
	round8_wave4.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round8_wave4.initial_batch_counts = [12, 7]
	round8_wave4.initial_batch_pattern = SpawnPattern.CIRCLE
	round8.waves.append(round8_wave4)

	# Wave 5
	var round8_wave5 = Wave.new()
	round8_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round8_wave5.mob_counts = [40, 25, 15, 8]
	round8_wave5.spawn_pattern = SpawnPattern.RANDOM
	round8_wave5.spawn_delay = 0.25
	round8_wave5.wave_cooldown = 5.0

	round8_wave5.initial_batch = true
	round8_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round8_wave5.initial_batch_counts = [20, 7, 3]
	round8_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round8.waves.append(round8_wave5)

	rounds.append(round8)

	# ROUND 9
	var round9 = Round.new()
	round9.round_number = 9

	# Wave 1
	var round9_wave1 = Wave.new()
	round9_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round9_wave1.mob_counts = [45, 25, 15, 3]
	round9_wave1.spawn_pattern = SpawnPattern.RANDOM
	round9_wave1.spawn_delay = 0.25
	round9_wave1.wave_cooldown = 5.0

	round9_wave1.initial_batch = true
	round9_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round9_wave1.initial_batch_counts = [20, 10, 5]
	round9_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round9.waves.append(round9_wave1)

	# Wave 2
	var round9_wave2 = Wave.new()
	round9_wave2.mob_scenes = [wizard_scene, martial_hero_scene]
	round9_wave2.mob_counts = [18, 5]
	round9_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round9_wave2.spawn_delay = 0.4
	round9_wave2.wave_cooldown = 5.0
	round9_wave2.circle_radius = 1000.0

	round9_wave2.initial_batch = true
	round9_wave2.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round9_wave2.initial_batch_counts = [8, 2]
	round9_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round9.waves.append(round9_wave2)

	# Wave 3
	var round9_wave3 = Wave.new()
	round9_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene]
	round9_wave3.mob_counts = [50, 30]
	round9_wave3.spawn_pattern = SpawnPattern.RANDOM
	round9_wave3.spawn_delay = 0.2
	round9_wave3.wave_cooldown = 5.0

	round9_wave3.initial_batch = true
	round9_wave3.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round9_wave3.initial_batch_counts = [25, 10]
	round9_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round9.waves.append(round9_wave3)

	# Wave 4
	var round9_wave4 = Wave.new()
	round9_wave4.mob_scenes = [goblin_scene, martial_hero_scene]
	round9_wave4.mob_counts = [40, 10]
	round9_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round9_wave4.spawn_delay = 0.3
	round9_wave4.wave_cooldown = 5.0
	round9_wave4.circle_radius = 1050.0

	round9_wave4.initial_batch = true
	round9_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	round9_wave4.initial_batch_counts = [20, 4]
	round9_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round9.waves.append(round9_wave4)

	# Wave 5
	var round9_wave5 = Wave.new()
	round9_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round9_wave5.mob_counts = [45, 30, 20, 10]
	round9_wave5.spawn_pattern = SpawnPattern.RANDOM
	round9_wave5.spawn_delay = 0.2
	round9_wave5.wave_cooldown = 5.0

	round9_wave5.initial_batch = true
	round9_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round9_wave5.initial_batch_counts = [20, 8, 4]
	round9_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round9.waves.append(round9_wave5)

	rounds.append(round9)

	# ROUND 10
	var round10 = Round.new()
	round10.round_number = 10

	# Wave 1
	var round10_wave1 = Wave.new()
	round10_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round10_wave1.mob_counts = [50, 30, 20]
	round10_wave1.spawn_pattern = SpawnPattern.CIRCLE
	round10_wave1.spawn_delay = 0.2
	round10_wave1.wave_cooldown = 5.0
	round10_wave1.circle_radius = 1000.0

	round10_wave1.initial_batch = true
	round10_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round10_wave1.initial_batch_counts = [25, 15, 10]
	round10_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round10.waves.append(round10_wave1)

	# Wave 2
	var round10_wave2 = Wave.new()
	round10_wave2.mob_scenes = [martial_hero_scene]
	round10_wave2.mob_counts = [12]
	round10_wave2.spawn_pattern = SpawnPattern.RANDOM
	round10_wave2.spawn_delay = 0.8
	round10_wave2.wave_cooldown = 5.0

	round10_wave2.initial_batch = true
	round10_wave2.initial_batch_mobs = [martial_hero_scene]
	round10_wave2.initial_batch_counts = [5]
	round10_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round10.waves.append(round10_wave2)

	# Wave 3
	var round10_wave3 = Wave.new()
	round10_wave3.mob_scenes = [goblin_scene, wizard_scene, martial_hero_scene]
	round10_wave3.mob_counts = [55, 25, 8]
	round10_wave3.spawn_pattern = SpawnPattern.RANDOM
	round10_wave3.spawn_delay = 0.2
	round10_wave3.wave_cooldown = 5.0

	round10_wave3.initial_batch = true
	round10_wave3.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round10_wave3.initial_batch_counts = [25, 10, 3]
	round10_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round10.waves.append(round10_wave3)

	# Wave 4
	var round10_wave4 = Wave.new()
	round10_wave4.mob_scenes = [tnt_goblin_scene, wizard_scene]
	round10_wave4.mob_counts = [35, 25]
	round10_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round10_wave4.spawn_delay = 0.2
	round10_wave4.wave_cooldown = 5.0
	round10_wave4.circle_radius = 1100.0

	round10_wave4.initial_batch = true
	round10_wave4.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round10_wave4.initial_batch_counts = [15, 10]
	round10_wave4.initial_batch_pattern = SpawnPattern.CIRCLE
	round10.waves.append(round10_wave4)

	# Wave 5
	var round10_wave5 = Wave.new()
	round10_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round10_wave5.mob_counts = [50, 35, 25, 12]
	round10_wave5.spawn_pattern = SpawnPattern.RANDOM
	round10_wave5.spawn_delay = 0.15
	round10_wave5.wave_cooldown = 5.0

	round10_wave5.initial_batch = true
	round10_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round10_wave5.initial_batch_counts = [25, 10, 5]
	round10_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round10.waves.append(round10_wave5)

	rounds.append(round10)

	# ROUND 11 (Final Boss Round)
	var round11 = Round.new()
	round11.round_number = 11

	# Wave 1
	var round11_wave1 = Wave.new()
	round11_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round11_wave1.mob_counts = [60, 40, 20, 5]
	round11_wave1.spawn_pattern = SpawnPattern.RANDOM
	round11_wave1.spawn_delay = 0.15
	round11_wave1.wave_cooldown = 5.0

	round11_wave1.initial_batch = true
	round11_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round11_wave1.initial_batch_counts = [30, 15, 10]
	round11_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round11.waves.append(round11_wave1)

	# Wave 2
	var round11_wave2 = Wave.new()
	round11_wave2.mob_scenes = [wizard_scene, martial_hero_scene]
	round11_wave2.mob_counts = [25, 10]
	round11_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round11_wave2.spawn_delay = 0.3
	round11_wave2.wave_cooldown = 5.0
	round11_wave2.circle_radius = 1100.0

	round11_wave2.initial_batch = true
	round11_wave2.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round11_wave2.initial_batch_counts = [10, 5]
	round11_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round11.waves.append(round11_wave2)

	# Wave 3
	var round11_wave3 = Wave.new()
	round11_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene]
	round11_wave3.mob_counts = [70, 45]
	round11_wave3.spawn_pattern = SpawnPattern.RANDOM
	round11_wave3.spawn_delay = 0.15
	round11_wave3.wave_cooldown = 5.0

	round11_wave3.initial_batch = true
	round11_wave3.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round11_wave3.initial_batch_counts = [35, 20]
	round11_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round11.waves.append(round11_wave3)

	# Wave 4
	var round11_wave4 = Wave.new()
	round11_wave4.mob_scenes = [wizard_scene, martial_hero_scene]
	round11_wave4.mob_counts = [30, 15]
	round11_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round11_wave4.spawn_delay = 0.25
	round11_wave4.wave_cooldown = 5.0
	round11_wave4.circle_radius = 1200.0

	round11_wave4.initial_batch = true
	round11_wave4.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round11_wave4.initial_batch_counts = [15, 8]
	round11_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round11.waves.append(round11_wave4)

	# Wave 5 (Final Boss Wave)
	var round11_wave5 = Wave.new()
	round11_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene]
	round11_wave5.mob_counts = [75, 50, 30, 20]
	round11_wave5.spawn_pattern = SpawnPattern.RANDOM
	round11_wave5.spawn_delay = 0.1
	round11_wave5.wave_cooldown = 5.0

	round11_wave5.initial_batch = true
	round11_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round11_wave5.initial_batch_counts = [30, 15, 10]
	round11_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round11.waves.append(round11_wave5)

	rounds.append(round11)

# Start the current round
func start_round():
	if current_round_index < rounds.size():
		round_in_progress = true
		current_wave_index = 0
		emit_signal("round_started", rounds[current_round_index].round_number)
		start_wave()

# Start the current wave
func start_wave():
	if current_round_index < rounds.size() and current_wave_index < rounds[current_round_index].waves.size():
		var wave = rounds[current_round_index].waves[current_wave_index]
		
		# Reset the mob index for the new wave
		current_mob_index = 0
		spawning_in_progress = true
		
		# Reset wave timer
		wave_timer = 0.0
		wave_timer_active = false
		
		if wave.initial_batch and wave.initial_batch_mobs.size() > 0:
			spawn_initial_batch(wave)
		
		# Set the timer interval
		spawn_timer.wait_time = wave.spawn_delay
		spawn_timer.start()
		
		emit_signal("wave_started", current_wave_index + 1)

# Handle spawning mobs
func _on_spawn_timer_timeout():
	var round = rounds[current_round_index]
	var wave = round.waves[current_wave_index]
	
	# Calculate total mobs to spawn for this wave
	var total_to_spawn = 0
	for count in wave.mob_counts:
		total_to_spawn += count
	
	# For CIRCLE pattern, spawn all mobs at once
	if wave.spawn_pattern == SpawnPattern.CIRCLE:
		var mob_index = 0
		var current_type_index = 0
		var mobs_spawned_of_current_type = 0
		
		for i in range(total_to_spawn):
			# Check if we need to move to the next mob type
			if mobs_spawned_of_current_type >= wave.mob_counts[current_type_index]:
				current_type_index += 1
				mobs_spawned_of_current_type = 0
				
			# Spawn the current mob type
			var mob = wave.mob_scenes[current_type_index].instantiate()
			
			# Position evenly in circle
			var angle = (2 * PI / total_to_spawn) * i
			var spawn_position = player.global_position + Vector2(
				cos(angle) * wave.circle_radius,
				sin(angle) * wave.circle_radius
			)
			mob.global_position = spawn_position
			
			# Add the mob to the scene
			add_child(mob)
			
			# Track active mobs
			active_mobs.append(mob)
			mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
			
			mobs_spawned_of_current_type += 1
		
		# All circle mobs spawned at once, so we're done
		spawn_timer.stop()
		spawning_in_progress = false
		return
	
	# For RANDOM pattern, spawn one mob at a time
	if wave.spawn_pattern == SpawnPattern.RANDOM:
		# Determine which mob type to spawn
		var mob_type_index = 0
		var total_spawned = 0
		
		# Find which mob type we're currently spawning
		for i in range(wave.mob_scenes.size()):
			if current_mob_index < total_spawned + wave.mob_counts[i]:
				mob_type_index = i
				break
			total_spawned += wave.mob_counts[i]
		
		# Spawn the mob
		var mob = wave.mob_scenes[mob_type_index].instantiate()
		
		# Position on the random path
		if path_follow != null:
			path_follow.progress_ratio = randf()
			mob.global_position = path_follow.global_position
		else:
			# Fallback if path_follow is null
			print("Warning: PathFollow2D not found.")

		
		# Add the mob to the scene
		add_child(mob)
		
		# Track active mobs
		active_mobs.append(mob)
		mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
		
		# Increment the mob index
		current_mob_index += 1
		
		# Check if we're done spawning for this wave
		if current_mob_index >= total_to_spawn:
			spawn_timer.stop()
			spawning_in_progress = false

# Handle mob being removed from the scene
func _on_mob_tree_exiting(mob):
	if active_mobs.has(mob):
		active_mobs.erase(mob)

# Show pause menu between rounds
func show_pause_menu():
	player_coins_label.text = "Coins: " + str(ui.coins_collected)
	get_tree().paused = true
	pause_menu.visible = true
	# Add a "Continue to next round" button in the UI

# Called from UI when player is ready to continue
func continue_to_next_round():
	get_tree().paused = false
	pause_menu.visible = false
	start_round()
	
	
#func spawn_mob_in_line(mob, line_start, line_end, progress):
	## progress is 0.0 to 1.0, representing position along the line
	#var spawn_position = line_start.lerp(line_end, progress)
	#mob.global_position = spawn_position
	
	
func spawn_all_mobs_in_circle(wave):
	var total_mob_count = 0
	for count in wave.mob_counts:
		total_mob_count += count
		
	var mob_index = 0
	var current_type_index = 0
	var mobs_spawned_of_current_type = 0
	
	for i in range(total_mob_count):
		# Check if we need to move to the next mob type
		if mobs_spawned_of_current_type >= wave.mob_counts[current_type_index]:
			current_type_index += 1
			mobs_spawned_of_current_type = 0
			
		# Spawn the current mob type
		var mob = wave.mob_scenes[current_type_index].instantiate()
		
		# Position in circle
		var angle = (2 * PI / total_mob_count) * i
		var spawn_position = player.global_position + Vector2(
			cos(angle) * wave.circle_radius,
			sin(angle) * wave.circle_radius
		)
		mob.global_position = spawn_position
		
		# Add the mob to the scene
		add_child(mob)
		
		# Track active mobs
		active_mobs.append(mob)
		mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
		
		mobs_spawned_of_current_type += 1
		

# Add this helper function
func progress_to_next_wave_or_round():
	# If there are more waves, start the next one
	if current_wave_index < rounds[current_round_index].waves.size() - 1:
		current_wave_index += 1
		start_wave()
	else:
		# Round complete
		round_in_progress = false
		emit_signal("round_ended", rounds[current_round_index].round_number)
		
		# Move to next round
		current_round_index += 1
		current_wave_index = 0
		
		if current_round_index < rounds.size():
			# Start countdown before showing pause menu
			start_round_ending_countdown()
		else:
			# All rounds complete
			emit_signal("all_rounds_completed")
			
			
func create_round_ending_animation():
	var animation_library = AnimationLibrary.new()
	var animation = Animation.new()
	
	# Scale track
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":scale")
	animation.track_insert_key(track_index, 0.0, Vector2(1, 1))
	animation.track_insert_key(track_index, 0.5, Vector2(1.3, 1.3))
	animation.track_insert_key(track_index, 1.0, Vector2(1, 1))
	
	# Alpha track
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":modulate:a")
	animation.track_insert_key(track_index, 0.0, 1.0)
	animation.track_insert_key(track_index, 0.8, 1.0)
	animation.track_insert_key(track_index, 1.0, 0.0)
	
	animation.length = 1.0
	
	animation_library.add_animation("countdown", animation)
	round_ending_animation_player.add_animation_library("", animation_library)


func start_round_ending_countdown():
	round_ending_countdown = 5  # 5 seconds countdown
	round_ending_timer = 0.0
	round_ending_in_progress = true
	round_ending_popup.text = "Round Ending in 5..."
	round_ending_popup.visible = true
	round_ending_popup.modulate.a = 1.0
	round_ending_animation_player.play("countdown")
	
	
func spawn_initial_batch(wave):
	# Calculate total mobs to spawn in initial batch
	var total_batch_mobs = 0
	for count in wave.initial_batch_counts:
		total_batch_mobs += count
	
	# For RANDOM pattern in initial batch, spawn all along the path
	if wave.initial_batch_pattern == SpawnPattern.RANDOM:
		var current_type_index = 0
		var mobs_spawned_of_current_type = 0
		
		for i in range(total_batch_mobs):
			# Check if we need to move to the next mob type
			if mobs_spawned_of_current_type >= wave.initial_batch_counts[current_type_index]:
				current_type_index += 1
				mobs_spawned_of_current_type = 0
			
			# Spawn the current mob type
			var mob = wave.initial_batch_mobs[current_type_index].instantiate()
			
			# Position randomly along the path
			if path_follow != null:
				path_follow.progress_ratio = randf()
				mob.global_position = path_follow.global_position
			else:
				# Fallback if path_follow is null
				print("Warning: PathFollow2D not found for initial batch spawn.")
				mob.global_position = Vector2(
					randf_range(100, 1000), 
					randf_range(100, 600)
				)
			
			# Add the mob to the scene
			add_child(mob)
			
			# Track active mobs
			active_mobs.append(mob)
			mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
			
			mobs_spawned_of_current_type += 1
	
	# For CIRCLE pattern in initial batch, spawn in a circle
	elif wave.initial_batch_pattern == SpawnPattern.CIRCLE:
		var current_type_index = 0
		var mobs_spawned_of_current_type = 0
		
		# Use the initial_batch_radius if available, otherwise fallback to circle_radius
		var spawn_radius = wave.initial_batch_radius
		
		for i in range(total_batch_mobs):
			# Check if we need to move to the next mob type
			if mobs_spawned_of_current_type >= wave.initial_batch_counts[current_type_index]:
				current_type_index += 1
				mobs_spawned_of_current_type = 0
			
			# Spawn the current mob type
			var mob = wave.initial_batch_mobs[current_type_index].instantiate()
			
			# Position evenly in circle
			var angle = (2 * PI / total_batch_mobs) * i
			var spawn_position = player.global_position + Vector2(
				cos(angle) * spawn_radius,
				sin(angle) * spawn_radius
			)
			mob.global_position = spawn_position
			
			# Add the mob to the scene
			add_child(mob)
			
			# Track active mobs
			active_mobs.append(mob)
			mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
			
			mobs_spawned_of_current_type += 1
