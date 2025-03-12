extends CanvasLayer

@onready var upgrade_pistol_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/Pistol/VBoxContainer/UpgradePistolButton

@onready var get_gun_2_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/MultishotGun/VBoxContainer/GetGun2Button
@onready var upgrade_gun_2_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/MultishotGun/VBoxContainer/UpgradeGun2Button

@onready var get_sniper_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/Sniper/VBoxContainer/GetSniperButton
@onready var upgrade_sniper_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/Sniper/VBoxContainer/UpgradeSniperButton

@onready var get_rocket_launcher_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/RocketLauncher/VBoxContainer/GetRocketLauncherButton
@onready var upgrade_rocket_launcher_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/RocketLauncher/VBoxContainer/UpgradeRocketLauncherButton

@onready var upgrade_blink_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/Blink/VBoxContainer/UpgradeBlinkButton

@onready var get_fire_blink_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/FireBlink/VBoxContainer/GetFireBlinkButton
@onready var upgrade_fire_blink_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/FireBlink/VBoxContainer/UpgradeFireBlinkButton

@onready var upgrade_shockwave_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/Shockwave/VBoxContainer/UpgradeShockwaveButton

@onready var upgrade_hp_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/HP/VBoxContainer/UpgradeHpButton

@onready var upgrade_mana_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/Mana/VBoxContainer/UpgradeManaButton

@onready var get_gravity_well_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/GravityWell/VBoxContainer/GetGravityWellButton
@onready var upgrade_gravity_well_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/GravityWell/VBoxContainer/UpgradeGravityWellButton

@onready var get_magic_orbital_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/MagicOrbital/VBoxContainer/GetMagicOrbitalButton
@onready var upgrade_magic_orbital_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/MagicOrbital/VBoxContainer/UpgradeMagicOrbitalButton

@onready var previous_difficulty_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer/PreviousDifficultyButton
@onready var difficulty_label: Label = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer2/VBoxContainer/DifficultyLabel
@onready var next_difficulty_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer2/VBoxContainer/HBoxContainer/NextDifficultyButton

@onready var glass_cannon_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/CursedUpgrades/VBoxContainer/GlassCannonButton
@onready var semi_pacifist_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/CursedUpgrades/VBoxContainer/SemiPacifistButton
@onready var run_forrest_run_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer/MarginContainer/GridContainer/CursedUpgrades/VBoxContainer/RunForrestRunButton

@onready var start_button: Button = $MarginContainer/PanelContainer/VBoxContainer/CenterContainer3/StartButton

@onready var starting_power_ups: CanvasLayer = $"."

var player

const MAX_GUN1_LEVEL = 5
const MAX_GUN2_LEVEL = 5
const MAX_SNIPER_LEVEL = 5
const MAX_ROCKET_LAUNCHER_LEVEL = 5
const MAX_BLINK_LEVEL = 5
const MAX_FIRE_BLINK_LEVEL = 5
const MAX_SHOCKWAVE_LEVEL = 5
const MAX_HP_LEVEL = 11
const MAX_MANA_LEVEL = 7
const MAX_GRAVITY_WELL_LEVEL = 5
const MAX_MAGIC_ORBITAL_LEVEL = 8

var gun1_improvements = {
	"fire_rate": 0.02,
	"damage_min": 3,
	"damage_max": 5,
	"bullet_speed": 100.0,
	"range": 100.0
}

var gun2_improvements = {
	"fire_rate": 0.015,
	"damage_min": 2,
	"damage_max": 4,
	"bullet_speed": 125.0,
	"range": 50.0
}

var sniper_improvements = {
	"fire_rate": 0.03,
	"damage_min": 5,
	"damage_max": 10,
	"bullet_speed": 200.0,
	"range": 200.0
}

var rocket_launcher_improvements = {
	"fire_rate": 0.01,
	"damage_min": 10,
	"damage_max": 20,
	"bullet_speed": 100.0,
	"range": 100.0
}

var fire_blink_improvements = {
	"damage_min": 8,
	"damage_max": 14
}

var gravity_well_improvements = {
	"damage": 2,
	"duration": 2.0,
	"pull_radius": 15.0,
	"damage_radius": 10.0
}

var blink_cooldown_upgrade = {
	2: 4,
	3: 3,
	4: 2,
	5: 1.5
}

var gun1_level = 1
var gun2_level = 1
var sniper_level = 1
var rocket_launcher_level = 1
var blink_level = 1
var fire_blink_level = 1
var shockwave_level = 1
var hp_level = 1
var mana_level = 1
var gravity_well_level = 1
var magic_orbital_level = 1

var has_gun2 = false
var has_sniper = false
var has_rocket_launcher = false
var has_fire_blink = false
var has_gravity_well = false
var has_magic_orbital = false

var selected_difficulty: float = 1.0
var min_difficulty: float = 1.0
var max_difficulty: float = 10.0
var difficulty_increment: float = 0.5

var active_cursed_powerup = "none"

func _ready():
	starting_power_ups.hide()
	
	upgrade_gun_2_button.disabled = true
	upgrade_sniper_button.disabled = true
	upgrade_rocket_launcher_button.disabled = true
	upgrade_fire_blink_button.disabled = true
	upgrade_gravity_well_button.disabled = true
	upgrade_magic_orbital_button.disabled = true
	
	update_difficulty_label()

func _on_upgrade_pistol_button_pressed():
	if gun1_level < MAX_GUN1_LEVEL:
		gun1_level += 1
		if gun1_level == MAX_GUN1_LEVEL:
			upgrade_pistol_button.text = "MAX LEVEL"
			upgrade_pistol_button.disabled = true
		else:
			upgrade_pistol_button.text = "Upgrade to Level " + str(gun1_level + 1)

func _on_get_gun_2_button_pressed():
	has_gun2 = true
	get_gun_2_button.text = "ACQUIRED"
	get_gun_2_button.disabled = true
	upgrade_gun_2_button.disabled = false

func _on_upgrade_gun_2_button_pressed():
	if gun2_level < MAX_GUN2_LEVEL:
		gun2_level += 1
		if gun2_level == MAX_GUN2_LEVEL:
			upgrade_gun_2_button.text = "MAX LEVEL"
			upgrade_gun_2_button.disabled = true
		else:
			upgrade_gun_2_button.text = "Upgrade to Level " + str(gun2_level + 1)

func _on_get_sniper_button_pressed():
	has_sniper = true
	get_sniper_button.text = "ACQUIRED"
	get_sniper_button.disabled = true
	upgrade_sniper_button.disabled = false

func _on_upgrade_sniper_button_pressed():
	if sniper_level < MAX_SNIPER_LEVEL:
		sniper_level += 1
		if sniper_level == MAX_SNIPER_LEVEL:
			upgrade_sniper_button.text = "MAX LEVEL"
			upgrade_sniper_button.disabled = true
		else:
			upgrade_sniper_button.text = "Upgrade to Level " + str(sniper_level + 1)

func _on_get_rocket_launcher_button_pressed():
	has_rocket_launcher = true
	get_rocket_launcher_button.text = "ACQUIRED"
	get_rocket_launcher_button.disabled = true
	upgrade_rocket_launcher_button.disabled = false

func _on_upgrade_rocket_launcher_button_pressed():
	if rocket_launcher_level < MAX_ROCKET_LAUNCHER_LEVEL:
		rocket_launcher_level += 1
		if rocket_launcher_level == MAX_ROCKET_LAUNCHER_LEVEL:
			upgrade_rocket_launcher_button.text = "MAX LEVEL"
			upgrade_rocket_launcher_button.disabled = true
		else:
			upgrade_rocket_launcher_button.text = "Upgrade to Level " + str(rocket_launcher_level + 1)

func _on_upgrade_blink_button_pressed():
	if blink_level < MAX_BLINK_LEVEL:
		blink_level += 1
		if blink_level == MAX_BLINK_LEVEL:
			upgrade_blink_button.text = "MAX LEVEL"
			upgrade_blink_button.disabled = true
		else:
			upgrade_blink_button.text = "Cooldown " + str(blink_cooldown_upgrade[blink_level + 1]) + "s"

func _on_get_fire_blink_button_pressed():
	has_fire_blink = true
	get_fire_blink_button.text = "ACQUIRED"
	get_fire_blink_button.disabled = true
	upgrade_fire_blink_button.disabled = false

func _on_upgrade_fire_blink_button_pressed():
	if fire_blink_level < MAX_FIRE_BLINK_LEVEL:
		fire_blink_level += 1
		if fire_blink_level == MAX_FIRE_BLINK_LEVEL:
			upgrade_fire_blink_button.text = "MAX LEVEL"
			upgrade_fire_blink_button.disabled = true
		else:
			upgrade_fire_blink_button.text = "Upgrade to Level " + str(fire_blink_level + 1)

func _on_upgrade_shockwave_button_pressed():
	if shockwave_level < MAX_SHOCKWAVE_LEVEL:
		shockwave_level += 1
		if shockwave_level == MAX_SHOCKWAVE_LEVEL:
			upgrade_shockwave_button.text = "MAX LEVEL"
			upgrade_shockwave_button.disabled = true
		else:
			upgrade_shockwave_button.text = "Upgrade to Level " + str(shockwave_level + 1)

func _on_upgrade_hp_button_pressed():
	if hp_level < MAX_HP_LEVEL:
		hp_level += 1
		if hp_level == MAX_HP_LEVEL:
			upgrade_hp_button.text = "MAX LEVEL"
			upgrade_hp_button.disabled = true
		else:
			upgrade_hp_button.text = "Upgrade to Level " + str(hp_level + 1)

func _on_upgrade_mana_button_pressed():
	if mana_level < MAX_MANA_LEVEL:
		mana_level += 1
		if mana_level == MAX_MANA_LEVEL:
			upgrade_mana_button.text = "MAX LEVEL"
			upgrade_mana_button.disabled = true
		else:
			upgrade_mana_button.text = "Upgrade to Level " + str(mana_level + 1)

func _on_get_gravity_well_button_pressed():
	has_gravity_well = true
	get_gravity_well_button.text = "ACQUIRED"
	get_gravity_well_button.disabled = true
	upgrade_gravity_well_button.disabled = false

func _on_upgrade_gravity_well_button_pressed():
	if gravity_well_level < MAX_GRAVITY_WELL_LEVEL:
		gravity_well_level += 1
		if gravity_well_level == MAX_GRAVITY_WELL_LEVEL:
			upgrade_gravity_well_button.text = "MAX LEVEL"
			upgrade_gravity_well_button.disabled = true
		else:
			upgrade_gravity_well_button.text = "Upgrade to Level " + str(gravity_well_level + 1)

func _on_get_magic_orbital_button_pressed() -> void:
	has_magic_orbital = true
	get_magic_orbital_button.text = "ACQUIRED"
	get_magic_orbital_button.disabled = true
	upgrade_magic_orbital_button.disabled = false


func _on_upgrade_magic_orbital_button_pressed() -> void:
	if magic_orbital_level < MAX_MAGIC_ORBITAL_LEVEL:
		magic_orbital_level += 1
		if magic_orbital_level == MAX_MAGIC_ORBITAL_LEVEL:
			upgrade_magic_orbital_button.text = "MAX LEVEL"
			upgrade_magic_orbital_button.disabled = true
		else:
			upgrade_magic_orbital_button.text = "Upgrade to Level " + str(magic_orbital_level + 1)

func update_difficulty_label():
	difficulty_label.text = "Difficulty (1-10) you will start on: " + str(selected_difficulty)



func _on_glass_cannon_button_pressed():
	if active_cursed_powerup == "glass_cannon":
		active_cursed_powerup = "none"
		glass_cannon_button.text = "Glass Cannon"
	else:
		reset_cursed_powerup_buttons()
		active_cursed_powerup = "glass_cannon"
		glass_cannon_button.text = "APPLIED"

func _on_semi_pacifist_button_pressed():
	if active_cursed_powerup == "semi_pacifist":
		active_cursed_powerup = "none"
		semi_pacifist_button.text = "Semi-Pacifist"
	else:
		reset_cursed_powerup_buttons()
		active_cursed_powerup = "semi_pacifist"
		semi_pacifist_button.text = "APPLIED"

func _on_run_forrest_run_button_pressed():
	if active_cursed_powerup == "run_forrest_run":
		active_cursed_powerup = "none"
		run_forrest_run_button.text = "Run, Forrest, Run!"
	else:
		reset_cursed_powerup_buttons()
		active_cursed_powerup = "run_forrest_run"
		run_forrest_run_button.text = "APPLIED"

func reset_cursed_powerup_buttons():
	glass_cannon_button.text = "Glass Cannon"
	semi_pacifist_button.text = "Semi-Pacifist"
	run_forrest_run_button.text = "Run, Forrest, Run!"
	active_cursed_powerup = "none"


func _on_start_button_pressed():
	apply_upgrades()
	
	apply_cursed_powerup()
	
	var difficulty_manager = get_node("/root/world/DifficultyManager")
	if difficulty_manager:
		difficulty_manager.current_difficulty = selected_difficulty
		difficulty_manager.start_game()
	
	get_tree().paused = false
	queue_free()

func apply_upgrades():
	var bullet_script = load("res://scripts/bullet.gd")
	var bullet2_script = load("res://scripts/bullet_2.gd")
	var sniper_bullet_script = load("res://scripts/sniper_1_bullet.gd")
	var rocket_ammo_script = load("res://scripts/rocket_ammo.gd")
	var fire_blink_script = load("res://scripts/fire_blink.gd")
	var player_script = load("res://scripts/player.gd")
	var shockwave_script = load("res://scripts/shockwave.gd")
	var gravity_well_script = load("res://scripts/gravity_well.gd")
	var magic_orbital_script = load("res://scripts/orbital_ability.gd")
	
	for i in range(1, gun1_level):
		bullet_script.damage_min_bonus += gun1_improvements.damage_min
		bullet_script.damage_max_bonus += gun1_improvements.damage_max
		bullet_script.speed_bonus += gun1_improvements.bullet_speed
		bullet_script.range_bonus += gun1_improvements.range
	
	if has_gun2:
		player = get_node("/root/world/player")
		if player:
			player.owns_gun2 = true
			player.update_gun_states()
			
		for i in range(1, gun2_level):
			bullet2_script.damage_min_bonus += gun2_improvements.damage_min
			bullet2_script.damage_max_bonus += gun2_improvements.damage_max
			bullet2_script.speed_bonus += gun2_improvements.bullet_speed
			bullet2_script.range_bonus += gun2_improvements.range
	
	if has_sniper:
		player = get_node("/root/world/player")
		if player:
			player.owns_sniper1 = true
			player.update_gun_states()
			
		for i in range(1, sniper_level):
			sniper_bullet_script.damage_min_bonus += sniper_improvements.damage_min
			sniper_bullet_script.damage_max_bonus += sniper_improvements.damage_max
			sniper_bullet_script.speed_bonus += sniper_improvements.bullet_speed
			sniper_bullet_script.range_bonus += sniper_improvements.range
	
	if has_rocket_launcher:
		player = get_node("/root/world/player")
		if player:
			player.owns_rocketlauncher = true
			player.update_gun_states()
			
		for i in range(1, rocket_launcher_level):
			rocket_ammo_script.damage_min_bonus += rocket_launcher_improvements.damage_min
			rocket_ammo_script.damage_max_bonus += rocket_launcher_improvements.damage_max
			rocket_ammo_script.speed_bonus += rocket_launcher_improvements.bullet_speed
			rocket_ammo_script.range_bonus += rocket_launcher_improvements.range
	
	if blink_level > 1:
		player = get_node("/root/world/player")
		if player:
			player.blink_cooldown = blink_cooldown_upgrade[blink_level]
	
	if has_fire_blink:
		player = get_node("/root/world/player")
		if player:
			player.owns_fire_blink = true
			
		for i in range(1, fire_blink_level):
			fire_blink_script.damage_min_bonus += fire_blink_improvements.damage_min
			fire_blink_script.damage_max_bonus += fire_blink_improvements.damage_max
	
	for i in range(1, shockwave_level):
		shockwave_script.damage += 10.0
		shockwave_script.knockback_amount += 75.0
	
	for i in range(1, hp_level):
		player_script.set_max_health(player_script.max_health + 25.0)
		player = get_node("/root/world/player")
		if player:
			player.health += 25.0
			player.health_changed.emit(player.health)
	
	for i in range(1, mana_level):
		player_script.set_max_mana(player_script.max_mana + 50.0)
		player = get_node("/root/world/player")
		if player:
			player.current_mana += 50.0
			player.mana_changed.emit(player.current_mana)
	
	if has_gravity_well:
		player = get_node("/root/world/player")
		if player:
			player.owns_gravity_well = true
			
		for i in range(1, gravity_well_level):
			gravity_well_script.damage_bonus += gravity_well_improvements.damage
			gravity_well_script.duration_bonus += gravity_well_improvements.duration
			gravity_well_script.pull_radius_bonus += gravity_well_improvements.pull_radius
			gravity_well_script.damage_radius_bonus += gravity_well_improvements.damage_radius
	
	if has_magic_orbital:
		player = get_node("/root/world/player")
		if player:
			player.owns_orbital_ability = true
			
		for i in range(1, magic_orbital_level):
			magic_orbital_script.ability_level += 1
			
	var pause_menu = get_node("/root/world/PauseMenu")
	player = get_node("/root/world/player")
	
	if player:
		if has_gun2:
			player.owns_gun2 = true
		if has_sniper:
			player.owns_sniper1 = true
		if has_rocket_launcher:
			player.owns_rocketlauncher = true
		if has_fire_blink:
			player.owns_fire_blink = true
		if has_gravity_well:
			player.owns_gravity_well = true
		if has_magic_orbital:
			player.owns_orbital_ability = true
	
	if pause_menu:
		pause_menu.gun1_level = gun1_level
		pause_menu.gun2_level = gun2_level
		pause_menu.sniper1_level = sniper_level
		pause_menu.rocketlauncher_level = rocket_launcher_level
		pause_menu.blink_level = blink_level
		pause_menu.fire_blink_level = fire_blink_level
		pause_menu.shockwave_level = shockwave_level
		pause_menu.hp_level = hp_level
		pause_menu.mana_level = mana_level
		pause_menu.gravity_well_level = gravity_well_level
		pause_menu.orbital_level = magic_orbital_level
		
		pause_menu.update_cost_labels()
	
	var weapon_hud = get_node_or_null("/root/world/UI/WeaponHUD")
	if weapon_hud:
		weapon_hud.update_weapon_display()
	else:
		print("Warning: WeaponHUD not found!")

func apply_cursed_powerup():
	var bullet_script = load("res://scripts/bullet.gd")
	var bullet2_script = load("res://scripts/bullet_2.gd")
	var sniper_bullet_script = load("res://scripts/sniper_1_bullet.gd")
	var rocket_ammo_script = load("res://scripts/rocket_ammo.gd")
	var player_script = load("res://scripts/player.gd")
	var pause_menu_script = load("res://scripts/pause_menu.gd")
	
	bullet_script.glass_cannon_multiplier = false
	bullet_script.runforrestrun_multiplier = false
	bullet2_script.glass_cannon_multiplier = false
	bullet2_script.runforrestrun_multiplier = false
	sniper_bullet_script.glass_cannon_multiplier = false
	sniper_bullet_script.runforrestrun_multiplier = false
	rocket_ammo_script.glass_cannon_multiplier = false
	rocket_ammo_script.runforrestrun_multiplier = false
	player_script.damage_multiplier = false
	player_script.weapon_restriction = false
	pause_menu_script.semi_pacifist = false
	player_script.speed = 450.0
	
	match active_cursed_powerup:
		"glass_cannon":
			bullet_script.glass_cannon_multiplier = true
			bullet2_script.glass_cannon_multiplier = true
			sniper_bullet_script.glass_cannon_multiplier = true
			rocket_ammo_script.glass_cannon_multiplier = true
			player_script.damage_multiplier = true
			
		"semi_pacifist":
			pause_menu_script.semi_pacifist = true
			player_script.weapon_restriction = true
			player_script.ability_mana_reduction = true
			
		"run_forrest_run":
			bullet_script.runforrestrun_multiplier = true
			bullet2_script.runforrestrun_multiplier = true
			sniper_bullet_script.runforrestrun_multiplier = true
			rocket_ammo_script.runforrestrun_multiplier = true
			player_script.speed = 675.0


func _on_previous_difficulty_button_pressed() -> void:
	if selected_difficulty > min_difficulty:
		selected_difficulty -= difficulty_increment
		selected_difficulty = snappedf(selected_difficulty, 0.1)
		update_difficulty_label()


func _on_next_difficulty_button_pressed() -> void:
	if selected_difficulty < max_difficulty:
		selected_difficulty += difficulty_increment
		selected_difficulty = snappedf(selected_difficulty, 0.1)
		update_difficulty_label()
