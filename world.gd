extends Node2D

@onready var player: CharacterBody2D = $player
@onready var ui = get_node("/root/world/UI")
@onready var round_manager = $RoundManager
@onready var stats_manager = get_node("/root/world/StatsManager")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	get_tree().paused = true
	
	$StatsManager.start_tracking()
	

func _on_player_health_depleted() -> void:
	$StatsManager.stop_tracking()
	get_tree().paused = true
	%GameOver.visible = true
	player.visible = false
	player.set_process(false)
	player.set_physics_process(false)
	#player.get_node("CollisionShape2D").disabled = true
	#player.get_node("player_hurtbox").get_node("CollisionShape2D").disabled = true
	round_manager.active_mobs.clear()
	round_manager.round_in_progress = false
	round_manager.spawning_in_progress = false
	
	if round_manager.spawn_timer.is_inside_tree():
		round_manager.spawn_timer.stop()
		
	var stats_ui = load("res://scenes/game_stats_ui.tscn").instantiate()
	add_child(stats_ui)
