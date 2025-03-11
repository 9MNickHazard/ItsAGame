extends Node2D

@onready var player: CharacterBody2D = $player
@onready var ui: CanvasLayer = get_node("/root/world/UI")
@onready var difficulty_manager: Node2D = get_node("/root/world/DifficultyManager")


func _ready() -> void:
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
	if difficulty_manager:
		difficulty_manager.active_mobs.clear()
		difficulty_manager.game_paused = true
		difficulty_manager.spawning_in_progress = false
		
		if difficulty_manager.spawn_timer:
			difficulty_manager.spawn_timer.stop()
		if difficulty_manager.difficulty_timer:
			difficulty_manager.difficulty_timer.stop()
		
	var stats_ui: CanvasLayer = load("res://scenes/game_stats_ui.tscn").instantiate()
	add_child(stats_ui)
