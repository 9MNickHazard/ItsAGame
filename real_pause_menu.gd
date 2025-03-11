extends CanvasLayer

@onready var volume_slider: HSlider = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/VolumeSlider
@onready var restart_button: Button = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/CenterContainer/RestartButton
@onready var quit_button: Button = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/CenterContainer2/QuitButton
@onready var real_pause_menu: CanvasLayer = $"."
@onready var keybind_container: VBoxContainer = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/Controls/ScrollContainer/VBoxContainer
@onready var default_button: Button = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/VBoxContainer/TabContainer/Controls/ResetControls
@onready var stats_container: VBoxContainer = $MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/VBoxContainer/ScrollContainer/StatsContainer
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

var pixel_font: FontFile = preload("res://assets/fonts/PixelOperator8.ttf")

var actions: Array = ["left", "right", "up", "down", "left_click", "Blink", "Ability 1", "Ability 2", "pause", "scroll_up", "scroll_down"]
var action_display_names: Dictionary = {
	"left": "Move Left",
	"right": "Move Right", 
	"up": "Move Up",
	"down": "Move Down",
	"left_click": "Shoot",
	"Blink": "Blink",
	"Ability 1": "Shockwave",
	"Ability 2": "Gravity Well",
	"pause": "Pause",
	"scroll_up": "Next Weapon",
	"scroll_down": "Previous Weapon"
}

var waiting_for_input: bool = false
var action_to_remap = null
var original_events: Dictionary = {}

func _ready() -> void:
	real_pause_menu.hide()
	
	volume_slider.value = 1
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	default_button.pressed.connect(_reset_to_defaults)
	
	_backup_original_keybinds()
	
	_create_keybind_ui()

func _backup_original_keybinds():
	for action in actions:
		original_events[action] = InputMap.action_get_events(action).duplicate()
	
func _create_keybind_ui():
	for child in keybind_container.get_children():
		child.queue_free()
	
	for action in actions:
		var hbox = HBoxContainer.new()
		hbox.set_h_size_flags(Control.SIZE_FILL)
		
		var label = Label.new()
		label.text = action_display_names[action]
		label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		var button = Button.new()
		button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			if events[0] is InputEventKey:
				button.text = events[0].as_text()
			elif events[0] is InputEventMouseButton:
				button.text = _get_mouse_button_string(events[0].button_index)
		else:
			button.text = "None"
		
		button.pressed.connect(_on_button_pressed.bind(action, button))
		
		hbox.add_child(label)
		hbox.add_child(button)
		keybind_container.add_child(hbox)

func _get_mouse_button_string(button_index):
	match button_index:
		MOUSE_BUTTON_LEFT: return "Left Mouse Button"
		MOUSE_BUTTON_RIGHT: return "Right Mouse Button"
		MOUSE_BUTTON_MIDDLE: return "Middle Mouse Button"
		MOUSE_BUTTON_WHEEL_UP: return "Mouse Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN: return "Mouse Wheel Down"
		_: return "Mouse Button " + str(button_index)

func _on_button_pressed(action, button):
	waiting_for_input = true
	action_to_remap = action
	button.text = "Press any key..."

func _input(event):
	if event.is_action_pressed("pause") and not waiting_for_input:
		toggle_pause()
	
	elif waiting_for_input:
		if event is InputEventKey or event is InputEventMouseButton:
			if event is InputEventKey and event.keycode == KEY_ESCAPE:
				waiting_for_input = false
				_create_keybind_ui()
				return
			
			if event.pressed:
				var old_events = InputMap.action_get_events(action_to_remap).duplicate()
				
				InputMap.action_erase_events(action_to_remap)
				
				InputMap.action_add_event(action_to_remap, event)
				
				if InputMap.action_get_events(action_to_remap).size() == 0:
					print("ERROR: Failed to set new keybind for ", action_to_remap)
					for old_event in old_events:
						InputMap.action_add_event(action_to_remap, old_event)
				
				waiting_for_input = false
				action_to_remap = null
				_create_keybind_ui()
				
				get_viewport().set_input_as_handled()

func _reset_to_defaults():
	for action in actions:
		if original_events.has(action):
			InputMap.action_erase_events(action)
			
			for event in original_events[action]:
				InputMap.action_add_event(action, event)
	
	_create_keybind_ui()
	
func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func toggle_pause():
	var normal_pause_menu = get_node("/root/world/PauseMenu")
	var starting_powerups_menu = get_node_or_null("/root/world/StartingPowerUps")
	var playtest_screen_menu = get_node_or_null("/root/world/PlaytestScreen")
	
	if normal_pause_menu and normal_pause_menu.visible:
		return
		
	if starting_powerups_menu and starting_powerups_menu.visible:
		return
		
	if playtest_screen_menu and playtest_screen_menu.visible:
		return
	
	if real_pause_menu.visible:
		real_pause_menu.hide()
		get_tree().paused = false
	else:
		update_stats_display()
		real_pause_menu.show()
		get_tree().paused = true
		
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_restart_button_pressed() -> void:
	var BulletScript: GDScript = load("res://scripts/bullet.gd")
	BulletScript.damage_min_bonus = 0
	BulletScript.damage_max_bonus = 0
	BulletScript.speed_bonus = 0.0
	BulletScript.range_bonus = 0.0
	BulletScript.glass_cannon_multiplier = false
	BulletScript.runforrestrun_multiplier = false
	
	var Bullet2Script: GDScript = load("res://scripts/bullet_2.gd")
	Bullet2Script.damage_min_bonus = 0
	Bullet2Script.damage_max_bonus = 0
	Bullet2Script.speed_bonus = 0.0
	Bullet2Script.range_bonus = 0.0
	Bullet2Script.glass_cannon_multiplier = false
	Bullet2Script.runforrestrun_multiplier = false
	
	var SniperBulletScript: GDScript = load("res://scripts/sniper_1_bullet.gd")
	SniperBulletScript.damage_min_bonus = 0
	SniperBulletScript.damage_max_bonus = 0
	SniperBulletScript.speed_bonus = 0.0
	SniperBulletScript.range_bonus = 0.0
	SniperBulletScript.glass_cannon_multiplier = false
	SniperBulletScript.runforrestrun_multiplier = false
	
	var FireBlinkScript: GDScript = load("res://scripts/fire_blink.gd")
	FireBlinkScript.damage_min_bonus = 0
	FireBlinkScript.damage_max_bonus = 0
	
	var RocketAmmoScript: GDScript = load("res://scripts/rocket_ammo.gd")
	RocketAmmoScript.damage_min_bonus = 0
	RocketAmmoScript.damage_max_bonus = 0
	RocketAmmoScript.speed_bonus = 0.0
	RocketAmmoScript.range_bonus = 0.0
	RocketAmmoScript.glass_cannon_multiplier = false
	RocketAmmoScript.runforrestrun_multiplier = false
	
	var ShockwaveScript: GDScript = load("res://scripts/shockwave.gd")
	ShockwaveScript.damage = 10
	ShockwaveScript.knockback_amount = 200.0
	
	var PlayerScript: GDScript = load("res://scripts/player.gd")
	PlayerScript.max_mana = 100.0
	PlayerScript.max_health = 100
	PlayerScript.damage_multiplier = false
	PlayerScript.weapon_restriction = false
	PlayerScript.ability_mana_reduction = false
	PlayerScript.speed = 450.0
	
	var GravityWellScript: GDScript = load("res://scripts/gravity_well.gd")
	GravityWellScript.damage_bonus = 0
	GravityWellScript.duration_bonus = 0.0
	GravityWellScript.pull_radius_bonus = 0.0
	GravityWellScript.damage_radius_bonus = 0.0
	
	var PauseMenuScript: GDScript = load("res://scripts/pause_menu.gd")
	PauseMenuScript.semi_pacifist = false
	
	stats_manager.reset_stats()
	
	CoinPoolManager.reset_for_new_game()
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func update_stats_display() -> void:
	for child in stats_container.get_children():
		child.queue_free()
	
	add_stat_label("Game Statistics", true)
	add_stat_label("")
	
	# Time stats
	add_stat_label("Time Stats", true)
	add_stat_label("Total Play Time: " + stats_manager.get_formatted_time())
	add_stat_label("")
	
	# Collection stats
	add_stat_label("Collection Stats", true)
	add_stat_label("Total Coins Collected: " + str(stats_manager.total_coins_collected))
	add_stat_label("Total Hearts Collected: " + str(stats_manager.total_hearts_collected))
	add_stat_label("Total Mana Balls Collected: " + str(stats_manager.total_mana_balls_collected))
	add_stat_label("Total Diamonds Collected: " + str(stats_manager.total_diamonds_collected))
	add_stat_label("")
	
	# Combat stats
	add_stat_label("Combat Stats", true)
	add_stat_label("Damage Dealt to Mobs: " + str(round(stats_manager.damage_dealt_to_enemies)))
	add_stat_label("Damage Taken from Mobs: " + str(round(stats_manager.damage_taken_from_enemies)))
	add_stat_label("Total Mobs Killed: " + str(stats_manager.total_enemies_killed))
	add_stat_label("")
	
	# Enemy kill breakdown
	if not stats_manager.enemy_kills_by_type.is_empty():
		add_stat_label("Kills by Enemy Type", true)
		for enemy_type in stats_manager.enemy_kills_by_type:
			add_stat_label(enemy_type + ": " + str(stats_manager.enemy_kills_by_type[enemy_type]))
		add_stat_label("")
	
	# Ability usage
	add_stat_label("Ability Usage", true)
	add_stat_label("Total Blinks Used: " + str(stats_manager.total_blinks_used))
	add_stat_label("Total Shockwaves Used: " + str(stats_manager.total_shockwaves_used))
	add_stat_label("Total Gravity Wells Used: " + str(stats_manager.total_gravity_wells_used))
	add_stat_label("Total Shots Fired: " + str(stats_manager.total_shots_fired))
	add_stat_label("")
	
	# Shots by weapon
	if not stats_manager.shots_fired_by_weapon.is_empty():
		add_stat_label("Shots by Weapon", true)
		for weapon in stats_manager.shots_fired_by_weapon:
			add_stat_label(weapon + ": " + str(stats_manager.shots_fired_by_weapon[weapon]))
		add_stat_label("")
	
	# Progress stats
	add_stat_label("Progress Stats", true)
	add_stat_label("Highest Difficulty Reached: " + str(snappedf(stats_manager.highest_difficulty_reached, 0.1)))
	add_stat_label("Highest Level Reached: " + str(stats_manager.highest_level_reached))
	
	# Additional Stats
	add_stat_label("")
	add_stat_label("Additional Stats", true)
	
	# DPS (Damage Per Second)
	if stats_manager.total_play_time_seconds > 0:
		var dps = stats_manager.damage_dealt_to_enemies / stats_manager.total_play_time_seconds
		add_stat_label("Damage Per Second: " + str(snapped(dps, 0.01)))
	
	# Average coins per kill
	if stats_manager.total_enemies_killed > 0:
		var coins_per_kill = float(stats_manager.total_coins_collected) / stats_manager.total_enemies_killed
		add_stat_label("Average Coins Per Kill: " + str(snapped(coins_per_kill, 0.1)))


func add_stat_label(text: String, is_header: bool = false):
	var label = Label.new()
	label.text = text
	
	var font_settings = FontVariation.new()
	font_settings.set_base_font(pixel_font)
	
	label.add_theme_font_override("font", font_settings)
	
	if is_header:
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	else:
		label.add_theme_font_size_override("font_size", 16)
	
	stats_container.add_child(label)
