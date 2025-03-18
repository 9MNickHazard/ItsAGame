extends Node

@onready var save_manager = get_node("/root/SaveManager")
@onready var difficulty_manager = get_node_or_null("/root/world/DifficultyManager")

func _ready() -> void:
	var player = get_node_or_null("/root/world/player")
	if player:
		player.health_depleted.connect(_on_player_died)
	
	var pause_menu = get_node_or_null("/root/world/PauseMenu")
	if pause_menu:
		pause_menu.connect("return_to_main_menu", _on_return_to_main_menu)
	
	var real_pause_menu = get_node_or_null("/root/world/RealPauseMenu")
	if real_pause_menu:
		real_pause_menu.connect("return_to_main_menu", _on_return_to_main_menu)
		
	var game_stats_ui = get_node_or_null("/root/world/GameStatsUI")
	if game_stats_ui:
		game_stats_ui.connect("return_to_main_menu", _on_return_to_main_menu)
	
	if difficulty_manager:
		difficulty_manager.connect("difficulty_mode_completed", _on_difficulty_completed)

func _on_player_died() -> void:
	save_game()

func _on_return_to_main_menu() -> void:
	save_game()

func _on_difficulty_completed(difficulty_mode: int) -> void:
	save_game()

func save_game() -> void:
	if save_manager:
		save_manager.save_game()
		print("Game saved successfully")
