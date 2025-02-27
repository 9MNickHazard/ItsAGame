extends Node2D


@onready var player: CharacterBody2D = $player
@onready var ui = get_node("/root/world/UI")
@onready var spawn_timer: Timer = $"Mob1 Spawn Timer"

var spawning_mobs = true
var player_level = 1

var spawn_times = {
	"1-3": 0.70,
	"4-5": 0.65,
	"6-7": 0.55,
	"8-10": 0.45,
	"11-15": 0.4,
	"16-20": 0.30,
	"21-30": 0.25,
	"31-40": 0.20,
	"41-50": 0.15
}

func _ready():
    if ui and ui.experience_manager:
		ui.experience_manager.level_up.connect(_on_level_up)
	update_spawn_timer()
	
func _on_level_up(new_level: int):
	player_level = new_level
	update_spawn_timer()
	
func update_spawn_timer():
	var new_wait_time = 0.9
	
	if player_level <= 3:
		new_wait_time = spawn_times["1-3"]
	elif player_level <= 5:
		new_wait_time = spawn_times["4-5"]
	elif player_level <= 7:
		new_wait_time = spawn_times["6-7"]
	elif player_level <= 10:
		new_wait_time = spawn_times["8-10"]
	elif player_level <= 15:
		new_wait_time = spawn_times["11-15"]
	elif player_level <= 20:
		new_wait_time = spawn_times["16-20"]
	elif player_level <= 30:
		new_wait_time = spawn_times["21-30"]
	elif player_level <= 40:
		new_wait_time = spawn_times["31-40"]
	elif player_level <= 50:
		new_wait_time = spawn_times["41-50"]
	
	spawn_timer.wait_time = new_wait_time

func spawn_mob(running: bool, mob1_percentage: float, tntgoblin_percentage: float, wizard1_percentage: float):
	if running:
		var percentage = randf()
		if percentage <= mob1_percentage:
			var goblin_mob = preload("res://scenes/mob_1.tscn").instantiate()
			%"Mob1 PathFollow2D".progress_ratio = randf()
			goblin_mob.global_position = %"Mob1 PathFollow2D".global_position
			add_child(goblin_mob)
		elif percentage > mob1_percentage and percentage <= tntgoblin_percentage:
			var tntgoblin_mob = preload("res://scenes/tnt_goblin.tscn").instantiate()
			%"Mob1 PathFollow2D".progress_ratio = randf()
			tntgoblin_mob.global_position = %"Mob1 PathFollow2D".global_position
			add_child(tntgoblin_mob)
		elif percentage > tntgoblin_percentage and percentage <= wizard1_percentage:
			var wizard1_mob = preload("res://scenes/wizard_1.tscn").instantiate()
			%"Mob1 PathFollow2D".progress_ratio = randf()
			wizard1_mob.global_position = %"Mob1 PathFollow2D".global_position
			add_child(wizard1_mob)
		else:
			var martial_hero_mob = preload("res://scenes/martial_hero.tscn").instantiate()
			%"Mob1 PathFollow2D".progress_ratio = randf()
			martial_hero_mob.global_position = %"Mob1 PathFollow2D".global_position
			add_child(martial_hero_mob)


func _on_timer_timeout() -> void:
	if ui and ui.experience_manager:
		player_level = ui.experience_manager.get_current_level()
	
	if player_level <= 3:
		spawn_mob(spawning_mobs, 1.0, 0.0, 0.0)
	elif player_level <= 5:
		spawn_mob(spawning_mobs, 0.7, 1.0, 0.0)
	elif player_level <= 7:
		spawn_mob(spawning_mobs, 0.7, 0.95, 0.0)
	elif player_level <= 10:
		spawn_mob(spawning_mobs, 0.6, 0.80, 0.95)
	elif player_level <= 15:
		spawn_mob(spawning_mobs, 0.4, 0.65, 0.85)
	elif player_level <= 20:
		spawn_mob(spawning_mobs, 0.3, 0.50, 0.75)
	elif player_level <= 30:
		spawn_mob(spawning_mobs, 0.25, 0.45, 0.70)
	elif player_level <= 40:
		spawn_mob(spawning_mobs, 0.25, 0.45, 0.70)
	elif player_level <= 50:
		spawn_mob(spawning_mobs, 0.25, 0.45, 0.70)

func _on_player_health_depleted() -> void:
	%GameOver.visible = true
	player.visible = false
	player.set_process(false)
	player.set_physics_process(false)
	spawning_mobs = false


func _on_button_pressed() -> void:
	get_tree().reload_current_scene()



# NEW WORLD SCRIPT WITH ROUNDS

var current_round = 1
var round_active = false
var round_completed = false
var round_data = {}
var spawn_events_triggered = 0
var total_spawn_events = 0