extends Node

@onready var save_manager = get_node("/root/SaveManager")
@onready var difficulty_maanger = get_node_or_null("/root/world/DifficultyManager")

func _ready() -> void:
	var player = get_node_or_null("/root/world/player")
	if player:
		player.health_depleted.connect(_on_player_died)
	
	var pause_menu = get_node_or_null("/root/world/PauseMenu")
	if pause_menu:
		pause_menu.connect("return_to_main_menu", _on_return_to_main_menu)
	
	if difficulty_maanger:
		difficulty_maanger.connect("difficulty_mode_completed", _on_difficulty_completed)

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
