extends CanvasLayer

@onready var glass_cannon_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/HBoxContainer/GridContainer/GlassCannon/VBoxContainer/CenterContainer2/GlassCannonButton
@onready var semi_pacifist_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/HBoxContainer/GridContainer/SemiPacifist/VBoxContainer/CenterContainer2/SemiPacifistButton
@onready var run_forrest_run_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/HBoxContainer/GridContainer/RunForrestRun/VBoxContainer/CenterContainer2/RunForrestRunButton
@onready var normal_mode_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer2/NormalModeButton
@onready var playtest_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/PlaytestButton


func _on_glass_cannon_button_pressed():
	apply_glass_cannon()
	start_game()

func _on_semi_pacifist_button_pressed():
	apply_semi_pacifist()
	start_game()

func _on_run_forrest_run_button_pressed():
	apply_run_forrest_run()
	start_game()

func _on_normal_mode_button_pressed():
	start_game()

func start_game():
	get_tree().paused = false
	visible = false
	queue_free()

func apply_glass_cannon():
	var PlayerScript = load("res://scripts/player.gd")
	PlayerScript.damage_multiplier = true
	
	var Bullet1Script = load("res://scripts/bullet.gd")
	var Bullet2Script = load("res://scripts/bullet_2.gd")
	var RocketAmmoScript = load("res://scripts/rocket_ammo.gd")
	var Sniper1BulletScript = load("res://scripts/sniper_1_bullet.gd")
	
	Bullet1Script.glass_cannon_multiplier = true
	Bullet2Script.glass_cannon_multiplier = true
	RocketAmmoScript.glass_cannon_multiplier = true
	Sniper1BulletScript.glass_cannon_multiplier = true

func apply_semi_pacifist():
	var PlayerScript = load("res://scripts/player.gd")
	var PauseMenuScript = load("res://scripts/pause_menu.gd")
	
	PlayerScript.weapon_restriction = true
	PlayerScript.ability_mana_reduction = true
	PauseMenuScript.semi_pacifist = true

func apply_run_forrest_run():
	var PlayerScript = load("res://scripts/player.gd")
	PlayerScript.speed = 675.0
	
	var Bullet1Script = load("res://scripts/bullet.gd")
	var Bullet2Script = load("res://scripts/bullet_2.gd")
	var RocketAmmoScript = load("res://scripts/rocket_ammo.gd")
	var Sniper1BulletScript = load("res://scripts/sniper_1_bullet.gd")
	
	Bullet1Script.runforrestrun_multiplier = true
	Bullet2Script.runforrestrun_multiplier = true
	RocketAmmoScript.runforrestrun_multiplier = true
	Sniper1BulletScript.runforrestrun_multiplier = true


func _on_playtest_button_pressed() -> void:
	visible = false
	
	var playtest_screen = get_node("/root/world/PlaytestScreen")
	if playtest_screen:
		playtest_screen.visible = true
	else:
		print("Error: PlaytestScreen node not found")
