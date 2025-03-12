extends CanvasLayer

@onready var glass_cannon_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/HBoxContainer/GridContainer/GlassCannon/VBoxContainer/CenterContainer2/GlassCannonButton
@onready var semi_pacifist_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/HBoxContainer/GridContainer/SemiPacifist/VBoxContainer/CenterContainer2/SemiPacifistButton
@onready var run_forrest_run_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/HBoxContainer/GridContainer/RunForrestRun/VBoxContainer/CenterContainer2/RunForrestRunButton
@onready var normal_mode_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer2/NormalModeButton
@onready var playtest_button: Button = $MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/MarginContainer/PlaytestButton


func _on_glass_cannon_button_pressed() -> void:
	apply_glass_cannon()
	start_game()

func _on_semi_pacifist_button_pressed() -> void:
	apply_semi_pacifist()
	start_game()

func _on_run_forrest_run_button_pressed() -> void:
	apply_run_forrest_run()
	start_game()

func _on_normal_mode_button_pressed() -> void:
	start_game()

func start_game() -> void:
	get_tree().paused = false
	visible = false
	queue_free()

func apply_glass_cannon() -> void:
	var PlayerScript: GDScript = load("res://scripts/player.gd")
	PlayerScript.damage_multiplier = true
	
	var Bullet1Script: GDScript = load("res://scripts/bullet.gd")
	var Bullet2Script: GDScript = load("res://scripts/bullet_2.gd")
	var RocketAmmoScript: GDScript = load("res://scripts/rocket_ammo.gd")
	var Sniper1BulletScript: GDScript = load("res://scripts/sniper_1_bullet.gd")
	var ShockwaveScript: GDScript = load("res://scripts/shockwave.gd")
	var GravityWellScript: GDScript = load("res://scripts/gravity_well.gd")
	var OrbitalAbilityScript: GDScript = load("res://scripts/orbital_ability.gd")
	
	Bullet1Script.glass_cannon_multiplier = true
	Bullet2Script.glass_cannon_multiplier = true
	RocketAmmoScript.glass_cannon_multiplier = true
	Sniper1BulletScript.glass_cannon_multiplier = true
	ShockwaveScript.glass_cannon_multiplier = true
	GravityWellScript.glass_cannon_multiplier = true
	OrbitalAbilityScript.glass_cannon_multiplier = true

func apply_semi_pacifist() -> void:
	var PlayerScript: GDScript = load("res://scripts/player.gd")
	var PauseMenuScript: GDScript = load("res://scripts/pause_menu.gd")
	
	PlayerScript.weapon_restriction = true
	PlayerScript.ability_mana_reduction = true
	PauseMenuScript.semi_pacifist = true

func apply_run_forrest_run() -> void:
	var PlayerScript: GDScript = load("res://scripts/player.gd")
	PlayerScript.speed = 675.0
	
	var Bullet1Script: GDScript = load("res://scripts/bullet.gd")
	var Bullet2Script: GDScript = load("res://scripts/bullet_2.gd")
	var RocketAmmoScript: GDScript = load("res://scripts/rocket_ammo.gd")
	var Sniper1BulletScript: GDScript = load("res://scripts/sniper_1_bullet.gd")
	var ShockwaveScript: GDScript = load("res://scripts/shockwave.gd")
	var GravityWellScript: GDScript = load("res://scripts/gravity_well.gd")
	var OrbitalAbilityScript: GDScript = load("res://scripts/orbital_ability.gd")
	
	Bullet1Script.runforrestrun_multiplier = true
	Bullet2Script.runforrestrun_multiplier = true
	RocketAmmoScript.runforrestrun_multiplier = true
	Sniper1BulletScript.runforrestrun_multiplier = true
	ShockwaveScript.runforrestrun_multiplier = true
	GravityWellScript.runforrestrun_multiplier = true
	OrbitalAbilityScript.runforrestrun_multiplier = true


func _on_playtest_button_pressed() -> void:
	visible = false
	
	var playtest_screen: CanvasLayer = get_node("/root/world/PlaytestScreen")
	if playtest_screen:
		playtest_screen.visible = true
	else:
		print("Error: PlaytestScreen node not found")
