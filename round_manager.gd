extends Node

signal round_started(round_number)
signal wave_started(wave_number)
signal round_ended(round_number)
signal all_rounds_completed
signal mobs_remaining_changed(remaining_count)

enum SpawnPattern { RANDOM, CIRCLE }

class Wave:
	var mob_scenes = []
	var mob_counts = []
	var spawn_pattern = SpawnPattern.RANDOM
	var spawn_delay = 1.0
	var circle_radius = 600.0
	var wave_cooldown = 10.0

	var initial_batch = false
	var initial_batch_mobs = []
	var initial_batch_counts = []
	var initial_batch_pattern = SpawnPattern.RANDOM
	var initial_batch_radius = 700.0


class Round:
	var waves = []
	var round_number = 1

var goblin_scene = preload("res://scenes/mob_1.tscn")
var tnt_goblin_scene = preload("res://scenes/tnt_goblin.tscn")
var wizard_scene = preload("res://scenes/wizard_1.tscn")
var martial_hero_scene = preload("res://scenes/martial_hero.tscn")
var skeleton_boss_scene = preload("res://scenes/skeleton_boss.tscn")
var minotaur_scene = preload("res://scenes/minotaur.tscn")
var healer_scene = preload("res://scenes/healer.tscn")

@onready var player = get_node("/root/world/player")
@onready var ui = get_node("/root/world/UI")
@onready var pause_menu = get_node("/root/world/PauseMenu")
@onready var path_follow = get_node("/root/world/Mob1 Spawn Path/Mob1 PathFollow2D")
@onready var spawn_timer = $SpawnTimer
@onready var round_ending_popup = get_node("/root/world/UI/RoundEndingPopup")
@onready var round_ending_animation_player = get_node("/root/world/UI/RoundEndingPopup/AnimationPlayer")
@onready var player_coins_label = get_node("/root/world/PauseMenu/MainMargin/MainPanel/VBoxMain/TopRow/VBoxContainer/CoinsLabel")
@onready var stats_manager = get_node("/root/world/StatsManager")

var round_ending_countdown = 5
var round_ending_timer = 0.0
var round_ending_in_progress = false
var previous_countdown_second = -1

var rounds = []
var current_round_index = 0
var current_wave_index = 0
var current_mob_index = 0
var active_mobs = []
var spawning_in_progress = false
var round_in_progress = false
var wave_timer = 0.0
var wave_timer_active = false
var total_mobs_in_current_round = 0
var mobs_killed_in_current_round = 0

func _ready():
	setup_rounds()
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	round_ended.connect(_on_round_ended)
	all_rounds_completed.connect(_on_all_rounds_completed)
	
	create_round_ending_animation()
	
	round_ending_popup.visible = false
	
	call_deferred("start_round")

func _process(delta):
	if round_ending_in_progress:
		round_ending_timer += delta
		
		var current_countdown = round_ending_countdown - floor(round_ending_timer)
		if current_countdown >= 0:
			round_ending_popup.text = "Round Ending in " + str(int(current_countdown)) + "..."
			
			var current_second = floor(round_ending_timer)
			if current_second != previous_countdown_second:
				previous_countdown_second = current_second
				round_ending_animation_player.stop()
				round_ending_animation_player.play("countdown")
		
		if round_ending_timer >= round_ending_countdown:
			round_ending_in_progress = false
			round_ending_popup.visible = false
			
			pause_menu.update_cost_labels()
			show_pause_menu()
			return
	elif wave_timer_active:
		wave_timer += delta
		var current_wave = rounds[current_round_index].waves[current_wave_index]
		if wave_timer >= current_wave.wave_cooldown:
			wave_timer = 0.0
			wave_timer_active = false
			
			progress_to_next_wave_or_round()
	
	elif round_in_progress and !spawning_in_progress:
		if active_mobs.size() == 0:
			if current_wave_index < rounds[current_round_index].waves.size() - 1:
				current_wave_index += 1
				start_wave()
			else:
				round_in_progress = false
				emit_signal("round_ended", rounds[current_round_index].round_number)
				
				current_round_index += 1
				current_wave_index = 0
				
				if current_round_index < rounds.size():
					start_round_ending_countdown()
				else:
					emit_signal("all_rounds_completed")
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
	wave1.wave_cooldown = 2.0
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
	wave3.wave_cooldown = 1.0
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
	round2_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, healer_scene]
	round2_wave1.mob_counts = [25, 5, 1]
	round2_wave1.spawn_pattern = SpawnPattern.RANDOM
	round2_wave1.spawn_delay = 0.5
	round2_wave1.wave_cooldown = 10.0
	
	round2_wave1.initial_batch = true
	round2_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round2_wave1.initial_batch_counts = [30, 5]
	round2_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round2.waves.append(round2_wave1)
	
	# Wave 2
	var round2_wave2 = Wave.new()
	round2_wave2.mob_scenes = [wizard_scene, healer_scene]
	round2_wave2.mob_counts = [3, 1]
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
	round2_wave3.mob_scenes = [goblin_scene, wizard_scene, martial_hero_scene]
	round2_wave3.mob_counts = [20, 2, 2]
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
	round2_wave4.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round2_wave4.mob_counts = [30, 12, 3]
	round2_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round2_wave4.spawn_delay = 0.7
	round2_wave4.wave_cooldown = 10.0
	round2_wave4.circle_radius = 900.0
	
	round2_wave4.initial_batch = true
	round2_wave4.initial_batch_mobs = [tnt_goblin_scene, martial_hero_scene]
	round2_wave4.initial_batch_counts = [8, 5]
	round2_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round2.waves.append(round2_wave4)
	
	# Wave 5
	var round2_wave5 = Wave.new()
	round2_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, minotaur_scene, healer_scene]
	round2_wave5.mob_counts = [15, 10, 5, 1, 1]
	round2_wave5.spawn_pattern = SpawnPattern.RANDOM
	round2_wave5.spawn_delay = 0.5
	round2_wave5.wave_cooldown = 5.0
	
	round2_wave5.initial_batch = true
	round2_wave5.initial_batch_mobs = [goblin_scene, wizard_scene]
	round2_wave5.initial_batch_counts = [40, 2]
	round2_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round2.waves.append(round2_wave5)
	
	rounds.append(round2)
	
	# ROUND 3
	var round3 = Round.new()
	round3.round_number = 3
	
	# Wave 1
	var round3_wave1 = Wave.new()
	round3_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, healer_scene]
	round3_wave1.mob_counts = [50, 12, 2, 2]
	round3_wave1.spawn_pattern = SpawnPattern.RANDOM
	round3_wave1.spawn_delay = 0.5
	round3_wave1.wave_cooldown = 15.0
	round3_wave1.circle_radius = 1000.0
	
	round3_wave1.initial_batch = true
	round3_wave1.initial_batch_mobs = [goblin_scene]
	round3_wave1.initial_batch_counts = [20]
	round3_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round3.waves.append(round3_wave1)
	
	# Wave 2
	var round3_wave2 = Wave.new()
	round3_wave2.mob_scenes = [wizard_scene, healer_scene]
	round3_wave2.mob_counts = [2, 1]
	round3_wave2.spawn_pattern = SpawnPattern.RANDOM
	round3_wave2.spawn_delay = 1.0
	round3_wave2.wave_cooldown = 15.0
	round3_wave2.circle_radius = 1200.0
	
	round3_wave2.initial_batch = true
	round3_wave2.initial_batch_mobs = [goblin_scene, minotaur_scene]
	round3_wave2.initial_batch_counts = [25, 2]
	round3_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round3.waves.append(round3_wave2)
	
	# Wave 3
	var round3_wave3 = Wave.new()
	round3_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round3_wave3.mob_counts = [30, 15, 3, 3, 2]
	round3_wave3.spawn_pattern = SpawnPattern.RANDOM
	round3_wave3.spawn_delay = 0.6
	round3_wave3.wave_cooldown = 20.0
	round3_wave3.circle_radius = 850.0
	
	round3_wave3.initial_batch = true
	round3_wave3.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round3_wave3.initial_batch_counts = [15, 5, 1]
	round3_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round3.waves.append(round3_wave3)
	
	# Wave 4
	var round3_wave4 = Wave.new()
	round3_wave4.mob_scenes = [goblin_scene, martial_hero_scene, healer_scene]
	round3_wave4.mob_counts = [25, 2, 2]
	round3_wave4.spawn_pattern = SpawnPattern.RANDOM
	round3_wave4.spawn_delay = 0.5
	round3_wave4.wave_cooldown = 10.0
	
	round3_wave4.initial_batch = true
	round3_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene, minotaur_scene]
	round3_wave4.initial_batch_counts = [20, 4, 3]
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
	round3_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, minotaur_scene]
	round3_wave5.initial_batch_counts = [10, 2, 6]
	round3_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round3.waves.append(round3_wave5)
	
	rounds.append(round3)
	
	# boss round 1
	var boss_round = Round.new()
	boss_round.round_number = 4
	
	# Wave 2: Boss fight!
	var boss_wave = Wave.new()
	boss_wave.mob_scenes = [skeleton_boss_scene]
	boss_wave.mob_counts = [1]
	boss_wave.spawn_pattern = SpawnPattern.CIRCLE
	boss_wave.spawn_delay = 2.0
	boss_wave.wave_cooldown = 0.0
	boss_wave.circle_radius = 800.0
	
	boss_wave.initial_batch = true
	boss_wave.initial_batch_mobs = [goblin_scene, martial_hero_scene, minotaur_scene, healer_scene]
	boss_wave.initial_batch_counts = [20, 4, 2, 2]
	boss_wave.initial_batch_pattern = SpawnPattern.CIRCLE
	boss_wave.initial_batch_radius = 1400.0
	
	boss_round.waves.append(boss_wave)
	
	rounds.append(boss_round)
	
	# ROUND 5
	var round5 = Round.new()
	round5.round_number = 5
	
	# Wave 1
	var round5_wave1 = Wave.new()
	round5_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round5_wave1.mob_counts = [60, 15, 5, 2, 3]
	round5_wave1.spawn_pattern = SpawnPattern.RANDOM
	round5_wave1.spawn_delay = 0.4
	round5_wave1.wave_cooldown = 10.0
	
	round5_wave1.initial_batch = true
	round5_wave1.initial_batch_mobs = [goblin_scene, wizard_scene, minotaur_scene]
	round5_wave1.initial_batch_counts = [25, 2, 2]
	round5_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round5.waves.append(round5_wave1)
	
	# Wave 2
	var round5_wave2 = Wave.new()
	round5_wave2.mob_scenes = [wizard_scene, martial_hero_scene, healer_scene]
	round5_wave2.mob_counts = [5, 3, 2]
	round5_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round5_wave2.spawn_delay = 0.8
	round5_wave2.wave_cooldown = 10.0
	round5_wave2.circle_radius = 1300.0
	
	round5_wave2.initial_batch = true
	round5_wave2.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, minotaur_scene]
	round5_wave2.initial_batch_counts = [30, 10, 3]
	round5_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round5.waves.append(round5_wave2)
	
	# Wave 3
	var round5_wave3 = Wave.new()
	round5_wave3.mob_scenes = [tnt_goblin_scene, wizard_scene, healer_scene]
	round5_wave3.mob_counts = [30, 7, 2]
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
	round5_wave4.mob_scenes = [goblin_scene, martial_hero_scene, healer_scene]
	round5_wave4.mob_counts = [40, 4, 3]
	round5_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round5_wave4.spawn_delay = 0.4
	round5_wave4.wave_cooldown = 20.0
	round5_wave4.circle_radius = 1000.0
	
	round5_wave4.initial_batch = true
	round5_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	round5_wave4.initial_batch_counts = [15, 2]
	round5_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round5.waves.append(round5_wave4)
	
	# Wave 5
	var round5_wave5 = Wave.new()
	round5_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round5_wave5.mob_counts = [30, 20, 10, 4, 3]
	round5_wave5.spawn_pattern = SpawnPattern.RANDOM
	round5_wave5.spawn_delay = 0.3
	round5_wave5.wave_cooldown = 5.0
	
	round5_wave5.initial_batch = true
	round5_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene, minotaur_scene]
	round5_wave5.initial_batch_counts = [15, 5, 2, 4]
	round5_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round5.waves.append(round5_wave5)
	
	rounds.append(round5)
	
	# ROUND 6
	var round6 = Round.new()
	round6.round_number = 6

	# Wave 1
	var round6_wave1 = Wave.new()
	round6_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, healer_scene]
	round6_wave1.mob_counts = [75, 25, 10, 3]
	round6_wave1.spawn_pattern = SpawnPattern.CIRCLE
	round6_wave1.spawn_delay = 0.3
	round6_wave1.wave_cooldown = 30.0
	round6_wave1.circle_radius = 1500.0

	round6_wave1.initial_batch = true
	round6_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round6_wave1.initial_batch_counts = [30, 10, 5]
	round6_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round6.waves.append(round6_wave1)

	# Wave 2
	var round6_wave2 = Wave.new()
	round6_wave2.mob_scenes = [martial_hero_scene, wizard_scene, minotaur_scene, healer_scene]
	round6_wave2.mob_counts = [5, 10, 6, 3]
	round6_wave2.spawn_pattern = SpawnPattern.RANDOM
	round6_wave2.spawn_delay = 0.7
	round6_wave2.wave_cooldown = 15.0

	round6_wave2.initial_batch = true
	round6_wave2.initial_batch_mobs = [martial_hero_scene, wizard_scene]
	round6_wave2.initial_batch_counts = [3, 5]
	round6_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round6.waves.append(round6_wave2)

	# Wave 3
	var round6_wave3 = Wave.new()
	round6_wave3.mob_scenes = [goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round6_wave3.mob_counts = [80, 15, 5, 3]
	round6_wave3.spawn_pattern = SpawnPattern.CIRCLE
	round6_wave3.spawn_delay = 0.3
	round6_wave3.wave_cooldown = 20.0
	round6_wave3.circle_radius = 1400.0

	round6_wave3.initial_batch = true
	round6_wave3.initial_batch_mobs = [goblin_scene, wizard_scene, minotaur_scene]
	round6_wave3.initial_batch_counts = [30, 7, 4]
	round6_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round6.waves.append(round6_wave3)

	# Wave 4
	var round6_wave4 = Wave.new()
	round6_wave4.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, healer_scene]
	round6_wave4.mob_counts = [40, 20, 15, 3]
	round6_wave4.spawn_pattern = SpawnPattern.RANDOM
	round6_wave4.spawn_delay = 0.3
	round6_wave4.wave_cooldown = 25.0

	round6_wave4.initial_batch = true
	round6_wave4.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round6_wave4.initial_batch_counts = [15, 7]
	round6_wave4.initial_batch_pattern = SpawnPattern.CIRCLE
	round6.waves.append(round6_wave4)

	# Wave 5
	var round6_wave5 = Wave.new()
	round6_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, minotaur_scene, healer_scene]
	round6_wave5.mob_counts = [50, 30, 20, 10, 10, 4]
	round6_wave5.spawn_pattern = SpawnPattern.RANDOM
	round6_wave5.spawn_delay = 0.2
	round6_wave5.wave_cooldown = 0.0
	round6_wave5.circle_radius = 1500.0

	round6_wave5.initial_batch = true
	round6_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round6_wave5.initial_batch_counts = [25, 10, 5]
	round6_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round6.waves.append(round6_wave5)

	rounds.append(round6)
	
	# boss round 2
	var boss_round2 = Round.new()
	boss_round2.round_number = 7
	
	# Boss fight
	var boss_wave2 = Wave.new()
	boss_wave2.mob_scenes = [skeleton_boss_scene]
	boss_wave2.mob_counts = [2]
	boss_wave2.spawn_pattern = SpawnPattern.CIRCLE
	boss_wave2.spawn_delay = 2.0
	boss_wave2.wave_cooldown = 0.0
	boss_wave2.circle_radius = 800.0
	
	boss_wave2.initial_batch = true
	boss_wave2.initial_batch_mobs = [goblin_scene, martial_hero_scene, minotaur_scene, healer_scene]
	boss_wave2.initial_batch_counts = [30, 6, 3, 4]
	boss_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	boss_wave2.initial_batch_radius = 1400.0
	
	boss_round2.waves.append(boss_wave2)
	
	rounds.append(boss_round2)
	
	
	# ROUND 8
	var round8 = Round.new()
	round8.round_number = 8

	# Wave 1
	var round8_wave1 = Wave.new()
	round8_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round8_wave1.mob_counts = [30, 15, 8, 2, 4]
	round8_wave1.spawn_pattern = SpawnPattern.RANDOM
	round8_wave1.spawn_delay = 0.4
	round8_wave1.wave_cooldown = 10.0

	round8_wave1.initial_batch = true
	round8_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round8_wave1.initial_batch_counts = [15, 8, 4]
	round8_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round8.waves.append(round8_wave1)

	# Wave 2
	var round8_wave2 = Wave.new()
	round8_wave2.mob_scenes = [wizard_scene, martial_hero_scene, healer_scene]
	round8_wave2.mob_counts = [12, 3, 4]
	round8_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round8_wave2.spawn_delay = 0.6
	round8_wave2.wave_cooldown = 5.0
	round8_wave2.circle_radius = 900.0

	round8_wave2.initial_batch = true
	round8_wave2.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round8_wave2.initial_batch_counts = [5, 1]
	round8_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round8.waves.append(round8_wave2)

	# Wave 3
	var round8_wave3 = Wave.new()
	round8_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene, healer_scene]
	round8_wave3.mob_counts = [40, 20, 4]
	round8_wave3.spawn_pattern = SpawnPattern.RANDOM
	round8_wave3.spawn_delay = 0.3
	round8_wave3.wave_cooldown = 5.0

	round8_wave3.initial_batch = true
	round8_wave3.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round8_wave3.initial_batch_counts = [20, 10]
	round8_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round8.waves.append(round8_wave3)

	# Wave 4
	var round8_wave4 = Wave.new()
	round8_wave4.mob_scenes = [goblin_scene, martial_hero_scene, healer_scene]
	round8_wave4.mob_counts = [30, 6, 4]
	round8_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round8_wave4.spawn_delay = 0.4
	round8_wave4.wave_cooldown = 5.0
	round8_wave4.circle_radius = 950.0

	round8_wave4.initial_batch = true
	round8_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	round8_wave4.initial_batch_counts = [15, 2]
	round8_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round8.waves.append(round8_wave4)

	# Wave 5
	var round8_wave5 = Wave.new()
	round8_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round8_wave5.mob_counts = [35, 20, 12, 6, 4]
	round8_wave5.spawn_pattern = SpawnPattern.RANDOM
	round8_wave5.spawn_delay = 0.3
	round8_wave5.wave_cooldown = 5.0

	round8_wave5.initial_batch = true
	round8_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round8_wave5.initial_batch_counts = [15, 6, 3]
	round8_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round8.waves.append(round8_wave5)

	rounds.append(round8)

	# ROUND 9
	var round9 = Round.new()
	round9.round_number = 9

	# Wave 1
	var round9_wave1 = Wave.new()
	round9_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, healer_scene]
	round9_wave1.mob_counts = [40, 20, 10, 5]
	round9_wave1.spawn_pattern = SpawnPattern.CIRCLE
	round9_wave1.spawn_delay = 0.3
	round9_wave1.wave_cooldown = 5.0
	round9_wave1.circle_radius = 950.0

	round9_wave1.initial_batch = true
	round9_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round9_wave1.initial_batch_counts = [20, 10, 5]
	round9_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round9.waves.append(round9_wave1)

	# Wave 2
	var round9_wave2 = Wave.new()
	round9_wave2.mob_scenes = [martial_hero_scene, healer_scene]
	round9_wave2.mob_counts = [8, 5]
	round9_wave2.spawn_pattern = SpawnPattern.RANDOM
	round9_wave2.spawn_delay = 1.0
	round9_wave2.wave_cooldown = 5.0

	round9_wave2.initial_batch = true
	round9_wave2.initial_batch_mobs = [martial_hero_scene]
	round9_wave2.initial_batch_counts = [3]
	round9_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round9.waves.append(round9_wave2)

	# Wave 3
	var round9_wave3 = Wave.new()
	round9_wave3.mob_scenes = [goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round9_wave3.mob_counts = [45, 15, 5, 5]
	round9_wave3.spawn_pattern = SpawnPattern.RANDOM
	round9_wave3.spawn_delay = 0.3
	round9_wave3.wave_cooldown = 5.0

	round9_wave3.initial_batch = true
	round9_wave3.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round9_wave3.initial_batch_counts = [20, 7, 2]
	round9_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round9.waves.append(round9_wave3)

	# Wave 4
	var round9_wave4 = Wave.new()
	round9_wave4.mob_scenes = [tnt_goblin_scene, wizard_scene, healer_scene]
	round9_wave4.mob_counts = [25, 15, 5]
	round9_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round9_wave4.spawn_delay = 0.3
	round9_wave4.wave_cooldown = 5.0
	round9_wave4.circle_radius = 1000.0

	round9_wave4.initial_batch = true
	round9_wave4.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round9_wave4.initial_batch_counts = [12, 7]
	round9_wave4.initial_batch_pattern = SpawnPattern.CIRCLE
	round9.waves.append(round9_wave4)

	# Wave 5
	var round9_wave5 = Wave.new()
	round9_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round9_wave5.mob_counts = [40, 25, 15, 8, 5]
	round9_wave5.spawn_pattern = SpawnPattern.RANDOM
	round9_wave5.spawn_delay = 0.25
	round9_wave5.wave_cooldown = 5.0

	round9_wave5.initial_batch = true
	round9_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round9_wave5.initial_batch_counts = [20, 7, 3]
	round9_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round9.waves.append(round9_wave5)

	rounds.append(round9)

	# ROUND 10
	var round10 = Round.new()
	round10.round_number = 10

	# Wave 1
	var round10_wave1 = Wave.new()
	round10_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round10_wave1.mob_counts = [45, 25, 15, 3, 5]
	round10_wave1.spawn_pattern = SpawnPattern.RANDOM
	round10_wave1.spawn_delay = 0.25
	round10_wave1.wave_cooldown = 5.0

	round10_wave1.initial_batch = true
	round10_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round10_wave1.initial_batch_counts = [20, 10, 5]
	round10_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round10.waves.append(round10_wave1)

	# Wave 2
	var round10_wave2 = Wave.new()
	round10_wave2.mob_scenes = [wizard_scene, martial_hero_scene, healer_scene]
	round10_wave2.mob_counts = [18, 5, 5]
	round10_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round10_wave2.spawn_delay = 0.4
	round10_wave2.wave_cooldown = 5.0
	round10_wave2.circle_radius = 1000.0

	round10_wave2.initial_batch = true
	round10_wave2.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round10_wave2.initial_batch_counts = [8, 2]
	round10_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round10.waves.append(round10_wave2)

	# Wave 3
	var round10_wave3 = Wave.new()
	round10_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene, healer_scene]
	round10_wave3.mob_counts = [50, 30, 5]
	round10_wave3.spawn_pattern = SpawnPattern.RANDOM
	round10_wave3.spawn_delay = 0.2
	round10_wave3.wave_cooldown = 5.0

	round10_wave3.initial_batch = true
	round10_wave3.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round10_wave3.initial_batch_counts = [25, 10]
	round10_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round10.waves.append(round10_wave3)

	# Wave 4
	var round10_wave4 = Wave.new()
	round10_wave4.mob_scenes = [goblin_scene, martial_hero_scene, healer_scene]
	round10_wave4.mob_counts = [40, 10, 5]
	round10_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round10_wave4.spawn_delay = 0.3
	round10_wave4.wave_cooldown = 5.0
	round10_wave4.circle_radius = 1050.0

	round10_wave4.initial_batch = true
	round10_wave4.initial_batch_mobs = [goblin_scene, martial_hero_scene]
	round10_wave4.initial_batch_counts = [20, 4]
	round10_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round10.waves.append(round10_wave4)

	# Wave 5
	var round10_wave5 = Wave.new()
	round10_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round10_wave5.mob_counts = [45, 30, 20, 10, 6]
	round10_wave5.spawn_pattern = SpawnPattern.RANDOM
	round10_wave5.spawn_delay = 0.2
	round10_wave5.wave_cooldown = 5.0

	round10_wave5.initial_batch = true
	round10_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round10_wave5.initial_batch_counts = [20, 8, 4]
	round10_wave5.initial_batch_pattern = SpawnPattern.CIRCLE
	round10.waves.append(round10_wave5)

	rounds.append(round10)

	# ROUND 11
	var round11 = Round.new()
	round11.round_number = 11

	# Wave 1
	var round11_wave1 = Wave.new()
	round11_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, healer_scene]
	round11_wave1.mob_counts = [50, 30, 20, 6]
	round11_wave1.spawn_pattern = SpawnPattern.CIRCLE
	round11_wave1.spawn_delay = 0.2
	round11_wave1.wave_cooldown = 5.0
	round11_wave1.circle_radius = 1000.0

	round11_wave1.initial_batch = true
	round11_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round11_wave1.initial_batch_counts = [25, 15, 10]
	round11_wave1.initial_batch_pattern = SpawnPattern.RANDOM
	round11.waves.append(round11_wave1)

	# Wave 2
	var round11_wave2 = Wave.new()
	round11_wave2.mob_scenes = [martial_hero_scene, healer_scene]
	round11_wave2.mob_counts = [12, 6]
	round11_wave2.spawn_pattern = SpawnPattern.RANDOM
	round11_wave2.spawn_delay = 0.8
	round11_wave2.wave_cooldown = 5.0

	round11_wave2.initial_batch = true
	round11_wave2.initial_batch_mobs = [martial_hero_scene]
	round11_wave2.initial_batch_counts = [5]
	round11_wave2.initial_batch_pattern = SpawnPattern.CIRCLE
	round11.waves.append(round11_wave2)

	# Wave 3
	var round11_wave3 = Wave.new()
	round11_wave3.mob_scenes = [goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round11_wave3.mob_counts = [55, 25, 8, 6]
	round11_wave3.spawn_pattern = SpawnPattern.RANDOM
	round11_wave3.spawn_delay = 0.2
	round11_wave3.wave_cooldown = 5.0

	round11_wave3.initial_batch = true
	round11_wave3.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round11_wave3.initial_batch_counts = [25, 10, 3]
	round11_wave3.initial_batch_pattern = SpawnPattern.RANDOM
	round11.waves.append(round11_wave3)

	# Wave 4
	var round11_wave4 = Wave.new()
	round11_wave4.mob_scenes = [tnt_goblin_scene, wizard_scene, healer_scene]
	round11_wave4.mob_counts = [35, 25, 6]
	round11_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round11_wave4.spawn_delay = 0.2
	round11_wave4.wave_cooldown = 5.0
	round11_wave4.circle_radius = 1100.0

	round11_wave4.initial_batch = true
	round11_wave4.initial_batch_mobs = [tnt_goblin_scene, wizard_scene]
	round11_wave4.initial_batch_counts = [15, 10]
	round11_wave4.initial_batch_pattern = SpawnPattern.CIRCLE
	round11.waves.append(round11_wave4)

	# Wave 5
	var round11_wave5 = Wave.new()
	round11_wave5.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round11_wave5.mob_counts = [50, 35, 25, 12, 7]
	round11_wave5.spawn_pattern = SpawnPattern.RANDOM
	round11_wave5.spawn_delay = 0.15
	round11_wave5.wave_cooldown = 5.0

	round11_wave5.initial_batch = true
	round11_wave5.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene]
	round11_wave5.initial_batch_counts = [25, 10, 5]
	round11_wave5.initial_batch_pattern = SpawnPattern.RANDOM
	round11.waves.append(round11_wave5)

	rounds.append(round11)

	# ROUND 12 (Final Boss Round)
	var round12 = Round.new()
	round12.round_number = 12

	# Wave 1
	var round12_wave1 = Wave.new()
	round12_wave1.mob_scenes = [goblin_scene, tnt_goblin_scene, wizard_scene, martial_hero_scene, healer_scene]
	round12_wave1.mob_counts = [60, 40, 20, 5, 7]
	round12_wave1.spawn_pattern = SpawnPattern.RANDOM
	round12_wave1.spawn_delay = 0.15
	round12_wave1.wave_cooldown = 5.0

	round12_wave1.initial_batch = true
	round12_wave1.initial_batch_mobs = [goblin_scene, tnt_goblin_scene, wizard_scene]
	round12_wave1.initial_batch_counts = [30, 15, 10]
	round12_wave1.initial_batch_pattern = SpawnPattern.CIRCLE
	round12.waves.append(round12_wave1)

	# Wave 2
	var round12_wave2 = Wave.new()
	round12_wave2.mob_scenes = [wizard_scene, martial_hero_scene, healer_scene]
	round12_wave2.mob_counts = [25, 10, 7]
	round12_wave2.spawn_pattern = SpawnPattern.CIRCLE
	round12_wave2.spawn_delay = 0.3
	round12_wave2.wave_cooldown = 5.0
	round12_wave2.circle_radius = 1100.0

	round12_wave2.initial_batch = true
	round12_wave2.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round12_wave2.initial_batch_counts = [10, 5]
	round12_wave2.initial_batch_pattern = SpawnPattern.RANDOM
	round12.waves.append(round12_wave2)

	# Wave 3
	var round12_wave3 = Wave.new()
	round12_wave3.mob_scenes = [goblin_scene, tnt_goblin_scene, healer_scene]
	round12_wave3.mob_counts = [70, 45, 7]
	round12_wave3.spawn_pattern = SpawnPattern.RANDOM
	round12_wave3.spawn_delay = 0.15
	round12_wave3.wave_cooldown = 5.0

	round12_wave3.initial_batch = true
	round12_wave3.initial_batch_mobs = [goblin_scene, tnt_goblin_scene]
	round12_wave3.initial_batch_counts = [35, 20]
	round12_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	round12.waves.append(round12_wave3)

	# Wave 4
	var round12_wave4 = Wave.new()
	round12_wave4.mob_scenes = [wizard_scene, martial_hero_scene, healer_scene]
	round12_wave4.mob_counts = [30, 15, 8]
	round12_wave4.spawn_pattern = SpawnPattern.CIRCLE
	round12_wave4.spawn_delay = 0.25
	round12_wave4.wave_cooldown = 5.0
	round12_wave4.circle_radius = 1200.0

	round12_wave4.initial_batch = true
	round12_wave4.initial_batch_mobs = [wizard_scene, martial_hero_scene]
	round12_wave4.initial_batch_counts = [15, 8]
	round12_wave4.initial_batch_pattern = SpawnPattern.RANDOM
	round12.waves.append(round12_wave4)
	
	# Final Boss fight
	var boss_wave3 = Wave.new()
	boss_wave3.mob_scenes = [skeleton_boss_scene]
	boss_wave3.mob_counts = [3]
	boss_wave3.spawn_pattern = SpawnPattern.CIRCLE
	boss_wave3.spawn_delay = 2.0
	boss_wave3.wave_cooldown = 0.0
	boss_wave3.circle_radius = 1000.0
	
	boss_wave3.initial_batch = true
	boss_wave3.initial_batch_mobs = [goblin_scene, wizard_scene, martial_hero_scene, minotaur_scene, healer_scene]
	boss_wave3.initial_batch_counts = [20, 6, 8, 4, 8]
	boss_wave3.initial_batch_pattern = SpawnPattern.CIRCLE
	boss_wave3.initial_batch_radius = 1400.0  # Spawn around the boss
	
	round12.waves.append(boss_wave3)
	

	rounds.append(round12)

func start_round():
	if current_round_index < rounds.size():
		round_in_progress = true
		current_wave_index = 0
		
		total_mobs_in_current_round = calculate_total_mobs_in_round(current_round_index)
		mobs_killed_in_current_round = 0
		
		emit_signal("mobs_remaining_changed", total_mobs_in_current_round)
		emit_signal("round_started", rounds[current_round_index].round_number)
		start_wave()

func start_wave():
	if current_round_index < rounds.size() and current_wave_index < rounds[current_round_index].waves.size():
		var wave = rounds[current_round_index].waves[current_wave_index]
		
		current_mob_index = 0
		spawning_in_progress = true
		
		wave_timer = 0.0
		wave_timer_active = false
		
		if wave.initial_batch and wave.initial_batch_mobs.size() > 0:
			spawn_initial_batch(wave)
		
		spawn_timer.wait_time = wave.spawn_delay
		spawn_timer.start()
		
		emit_signal("wave_started", current_wave_index + 1)

func _on_spawn_timer_timeout():
	var round = rounds[current_round_index]
	var wave = round.waves[current_wave_index]
	
	var total_to_spawn = 0
	for count in wave.mob_counts:
		total_to_spawn += count
	
	if wave.spawn_pattern == SpawnPattern.CIRCLE:
		var mob_index = 0
		var current_type_index = 0
		var mobs_spawned_of_current_type = 0
		
		for i in range(total_to_spawn):
			if mobs_spawned_of_current_type >= wave.mob_counts[current_type_index]:
				current_type_index += 1
				mobs_spawned_of_current_type = 0
				
			var mob = wave.mob_scenes[current_type_index].instantiate()
			
			var angle = (2 * PI / total_to_spawn) * i
			var spawn_position = player.global_position + Vector2(
				cos(angle) * wave.circle_radius,
				sin(angle) * wave.circle_radius
			)
			mob.global_position = spawn_position
			
			add_child(mob)
			
			active_mobs.append(mob)
			mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
			
			mobs_spawned_of_current_type += 1
		
		spawn_timer.stop()
		spawning_in_progress = false
		return
	
	if wave.spawn_pattern == SpawnPattern.RANDOM:
		var mob_type_index = 0
		var total_spawned = 0
		
		for i in range(wave.mob_scenes.size()):
			if current_mob_index < total_spawned + wave.mob_counts[i]:
				mob_type_index = i
				break
			total_spawned += wave.mob_counts[i]
		
		var mob = wave.mob_scenes[mob_type_index].instantiate()
		
		if path_follow != null:
			path_follow.progress_ratio = randf()
			mob.global_position = path_follow.global_position
		else:
			print("Warning: PathFollow2D not found.")

		
		add_child(mob)
		
		active_mobs.append(mob)
		mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
		
		current_mob_index += 1
		
		if current_mob_index >= total_to_spawn:
			spawn_timer.stop()
			spawning_in_progress = false

func _on_mob_tree_exiting(mob):
	if active_mobs.has(mob):
		active_mobs.erase(mob)
		
		if round_in_progress:
			mobs_killed_in_current_round += 1
			emit_signal("mobs_remaining_changed", total_mobs_in_current_round - mobs_killed_in_current_round)

func show_pause_menu():
	player_coins_label.text = "Coins: " + str(ui.coins_collected)
	get_tree().paused = true
	pause_menu.visible = true

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
		if mobs_spawned_of_current_type >= wave.mob_counts[current_type_index]:
			current_type_index += 1
			mobs_spawned_of_current_type = 0
			
		var mob = wave.mob_scenes[current_type_index].instantiate()
		
		var angle = (2 * PI / total_mob_count) * i
		var spawn_position = player.global_position + Vector2(
			cos(angle) * wave.circle_radius,
			sin(angle) * wave.circle_radius
		)
		mob.global_position = spawn_position
		
		add_child(mob)
		
		active_mobs.append(mob)
		mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
		
		mobs_spawned_of_current_type += 1
		

func progress_to_next_wave_or_round():
	if current_wave_index < rounds[current_round_index].waves.size() - 1:
		current_wave_index += 1
		start_wave()
	else:
		round_in_progress = false
		emit_signal("round_ended", rounds[current_round_index].round_number)
		
		current_round_index += 1
		current_wave_index = 0
		
		if current_round_index < rounds.size():
			start_round_ending_countdown()
		else:
			emit_signal("all_rounds_completed")
			
			
func create_round_ending_animation():
	var animation_library = AnimationLibrary.new()
	var animation = Animation.new()
	
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":scale")
	animation.track_insert_key(track_index, 0.0, Vector2(1, 1))
	animation.track_insert_key(track_index, 0.5, Vector2(1.3, 1.3))
	animation.track_insert_key(track_index, 1.0, Vector2(1, 1))
	
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":modulate:a")
	animation.track_insert_key(track_index, 0.0, 1.0)
	animation.track_insert_key(track_index, 0.8, 1.0)
	animation.track_insert_key(track_index, 1.0, 0.0)
	
	animation.length = 1.0
	
	animation_library.add_animation("countdown", animation)
	round_ending_animation_player.add_animation_library("", animation_library)


func start_round_ending_countdown():
	round_ending_countdown = 5
	round_ending_timer = 0.0
	round_ending_in_progress = true
	round_ending_popup.text = "Round Ending in 5..."
	round_ending_popup.visible = true
	round_ending_popup.modulate.a = 1.0
	round_ending_animation_player.play("countdown")
	
	
func spawn_initial_batch(wave):
	var total_batch_mobs = 0
	for count in wave.initial_batch_counts:
		total_batch_mobs += count
	
	if wave.initial_batch_pattern == SpawnPattern.RANDOM:
		var current_type_index = 0
		var mobs_spawned_of_current_type = 0
		
		for i in range(total_batch_mobs):
			if mobs_spawned_of_current_type >= wave.initial_batch_counts[current_type_index]:
				current_type_index += 1
				mobs_spawned_of_current_type = 0
			
			var mob = wave.initial_batch_mobs[current_type_index].instantiate()
			
			if path_follow != null:
				path_follow.progress_ratio = randf()
				mob.global_position = path_follow.global_position
			else:
				print("Warning: PathFollow2D not found for initial batch spawn.")
				mob.global_position = Vector2(
					randf_range(100, 1000), 
					randf_range(100, 600)
				)
			
			add_child(mob)
			
			active_mobs.append(mob)
			mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
			
			mobs_spawned_of_current_type += 1
	
	elif wave.initial_batch_pattern == SpawnPattern.CIRCLE:
		var current_type_index = 0
		var mobs_spawned_of_current_type = 0
		
		var spawn_radius = wave.initial_batch_radius
		
		for i in range(total_batch_mobs):
			if mobs_spawned_of_current_type >= wave.initial_batch_counts[current_type_index]:
				current_type_index += 1
				mobs_spawned_of_current_type = 0
			
			var mob = wave.initial_batch_mobs[current_type_index].instantiate()
			
			var angle = (2 * PI / total_batch_mobs) * i
			var spawn_position = player.global_position + Vector2(
				cos(angle) * spawn_radius,
				sin(angle) * spawn_radius
			)
			mob.global_position = spawn_position
			
			add_child(mob)
			
			active_mobs.append(mob)
			mob.tree_exiting.connect(_on_mob_tree_exiting.bind(mob))
			
			mobs_spawned_of_current_type += 1
			
func calculate_total_mobs_in_round(round_idx):
	var total = 0
	var round = rounds[round_idx]
	
	for wave in round.waves:
		for count in wave.mob_counts:
			total += count
		
		if wave.initial_batch:
			for count in wave.initial_batch_counts:
				total += count
	
	return total
	
func _on_round_ended(round_number):
	stats_manager.rounds_completed += 1
	
	if round_number > stats_manager.highest_round_reached:
		stats_manager.highest_round_reached = round_number
	
   
func _on_all_rounds_completed():
	stats_manager.stop_tracking()
	get_tree().paused = true
	
	var win_screen = load("res://scenes/win_screen.tscn").instantiate()
	add_child(win_screen)
	
	var stats_ui = load("res://scenes/game_stats_ui.tscn").instantiate()
	add_child(stats_ui)
	
	#var stats_ui = load("res://scenes/game_stats_ui.tscn").instantiate()
	#get_tree().current_scene.add_child(stats_ui)
