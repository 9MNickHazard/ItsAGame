extends CanvasLayer

@onready var start_game_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/StartGameButton
@onready var upgrades_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/UpgradesButton
@onready var settings_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/SettingsButton
@onready var quit_game_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/QuitGameButton
@onready var start_heroic_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/StartHeroicButton
@onready var start_legendary_button: Button = $MarginContainer/CenterContainer/PanelContainer/VBoxContainer/CenterContainer/VBoxContainer/StartLegendaryButton
@onready var locked_label: Label = $MarginContainer/CenterContainer/PanelContainer/CenterContainer/LockedLabel
@onready var save_manager = get_node("/root/SaveManager")

func _ready() -> void:
	if locked_label:
		locked_label.hide()
	
	if save_manager:
		update_difficulty_buttons()


func update_difficulty_buttons() -> void:
	var heroic_unlocked: bool = save_manager.get_difficulty("heroic")
	start_heroic_button.self_modulate = Color.WHITE if heroic_unlocked else Color.RED
	
	var legendary_unlocked: bool = save_manager.get_difficulty("legendary")
	start_legendary_button.self_modulate = Color.WHITE if legendary_unlocked else Color.RED

func _on_start_game_button_pressed() -> void:
	start_game_with_difficulty(0)

func _on_start_heroic_button_pressed() -> void:
	var heroic_unlocked: bool = save_manager.get_difficulty("heroic")
	
	if heroic_unlocked:
		start_game_with_difficulty(1)
	else:
		show_locked_message()

func _on_start_legendary_button_pressed() -> void:
	var legendary_unlocked: bool = save_manager.get_difficulty("legendary")
	
	if legendary_unlocked:
		start_game_with_difficulty(2)
	else:
		show_locked_message()

func start_game_with_difficulty(difficulty_mode: int) -> void:
	save_manager.set_selected_difficulty(difficulty_mode)
	
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func show_locked_message() -> void:
	disable_buttons(true)
	
	locked_label.show()
	
	var timer = get_tree().create_timer(1.2)
	await timer.timeout 

	locked_label.hide()
	disable_buttons(false)

func disable_buttons(disabled: bool) -> void:
	start_game_button.disabled = disabled
	upgrades_button.disabled = disabled
	settings_button.disabled = disabled
	quit_game_button.disabled = disabled
	start_heroic_button.disabled = disabled
	start_legendary_button.disabled = disabled

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()

func _on_upgrades_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrades_menu.tscn")
