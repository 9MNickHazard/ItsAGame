extends CanvasLayer

@onready var start_game_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/StartGameButton
@onready var upgrades_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/UpgradesButton
@onready var settings_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/SettingsButton
@onready var quit_game_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/QuitGameButton


func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_quit_game_button_pressed() -> void:
	get_tree().quit()


func _on_upgrades_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrades_menu.tscn")
