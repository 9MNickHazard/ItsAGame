# pause_menu.gd
extends CanvasLayer


@onready var not_enough_coins_label: Label = $NotEnoughCoinsLabel
@onready var level_requirement_label: Label = $LevelRequirementLabel
@onready var pause_menu: CanvasLayer = $"."

@onready var gun_1_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/Gun1Container/VBoxContainer/Gun1UpgradeButton
@onready var gun_1_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/Gun1Container/VBoxContainer/Gun1LevelReq
@onready var gun_2_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/Gun2Container/VBoxContainer/Gun2UpgradeButton
@onready var gun_2_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/Gun2Container/VBoxContainer/Gun2LevelReq
@onready var sniper_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/SniperContainer/VBoxContainer/SniperUpgradeButton
@onready var sniper_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/SniperContainer/VBoxContainer/SniperLevelReq
@onready var rocket_launcher_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/RocketLauncherContainer/VBoxContainer/RocketLauncherUpgradeButton
@onready var rocket_launcher_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/RocketLauncherContainer/VBoxContainer/RocketLauncherLevelReq
@onready var blink_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/BlinkContainer/VBoxContainer/BlinkUpgradeButton
@onready var blink_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/BlinkContainer/VBoxContainer/BlinkLevelReq
@onready var fire_blink_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/FireBlinkContainer/VBoxContainer/FireBlinkUpgradeButton
@onready var fire_blink_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/FireBlinkContainer/VBoxContainer/FireBlinkLevelReq
@onready var shockwave_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/ShockwaveContainer/VBoxContainer/ShockwaveUpgradeButton
@onready var shockwave_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/ShockwaveContainer/VBoxContainer/ShockwaveLevelReq
@onready var hp_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/HpContainer/VBoxContainer/HpUpgradeButton
@onready var hp_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/HpContainer/VBoxContainer/HpLevelReq
@onready var mana_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/ManaContainer/VBoxContainer/ManaUpgradeButton
@onready var mana_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/ManaContainer/VBoxContainer/ManaLevelReq
@onready var gravity_well_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/GravityWellContainer/VBoxContainer/GravityWellUpgradeButton
@onready var gravity_well_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/GravityWellContainer/VBoxContainer/GravityWellLevelReq
@onready var orbital_ability_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/OrbitalAbilityContainer/VBoxContainer/OrbitalAbilityUpgradeButton
@onready var orbital_ability_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/OrbitalAbilityContainer/VBoxContainer/OrbitalAbilityLevelReq
@onready var shotgun_upgrade_button: Button = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/ShotgunContainer/VBoxContainer/ShotgunUpgradeButton
@onready var shotgun_level_req: Label = $MainMargin/MainPanel/VBoxMain/ContentRow/MarginContainer/GridContainer/ShotgunContainer/VBoxContainer/ShotgunLevelReq

@onready var continue_button: Button = $MainMargin/MainPanel/VBoxMain/BottomRow/MarginContainer/HBoxContainer/ContinueButton
@onready var player_coins_label: Label = $MainMargin/MainPanel/VBoxMain/TopRow/VBoxContainer/CoinsLabel
@onready var player_level_label: Label = $MainMargin/MainPanel/VBoxMain/TopRow/VBoxContainer/LevelLabel

@onready var semi_pacifist_label: Label = $SemiPacifistLabel

@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

static var semi_pacifist = false

var player = null
var ui = null

# BLINK VARIABLES
var blink_costs = {
	2: 250,
	3: 500,
	4: 1000,
	5: 1750
}
var blink_cooldown_upgrade = {
	2: 4,
	3: 3,
	4: 2,
	5: 1.5
}
var blink_level = 1
var blink_level_requirements = {
	2: 2,
	3: 4,
	4: 7,
	5: 11
}

# FIRE BLINK VARIABLES
var fire_blink_buy_cost = 250
var fire_blink_buy_level_req = 3
var fire_blink_costs = {
	2: 300,
	3: 450,
	4: 600,
	5: 750
}
var fire_blink_improvements = {
	"damage_min": 8,
	"damage_max": 14
}
var fire_blink_level = 1
var fire_blink_level_requirements = {
	2: 4,
	3: 6,
	4: 8,
	5: 10
}

# GRAVITY WELL VARIABLES
var gravity_well_buy_cost = 200
var gravity_well_buy_level_req = 3
var gravity_well_costs = {
	2: 400,
	3: 550,
	4: 700,
	5: 850
}
var gravity_well_improvements = {
	"damage": 2,
	"duration": 2,
	"pull_radius": 15.0, # percent increase
	"damage_radius": 10.0
}
var gravity_well_level = 1
var gravity_well_level_requirements = {
	2: 5,
	3: 6,
	4: 8,
	5: 10
}

# GUN1 VARIABLES
var gun1 = null
var gun1_costs = {
	2: 25,
	3: 50,
	4: 80,
	5: 120
}
var gun1_improvements = {
	"fire_rate": 0.02,  # reduce fire_rate by x
	"damage_min": 3,      # increases minimum damage by x
	"damage_max": 5,      # # increases maximum damage by x
	"bullet_speed": 100.0,
	"range": 100.0
}
var gun1_level = 1
var gun1_level_requirements = {
	2: 2,  
	3: 3,  
	4: 4,  
	5: 5
}

# GUN2 VARIABLES
var gun2 = null
var gun2_buy_cost = 200
var gun2_buy_level_req = 3
var gun2_costs = {
	2: 100,
	3: 175,
	4: 300,
	5: 500
}
var gun2_improvements = {
	"fire_rate": 0.01,
	"damage_min": 2,
	"damage_max": 4,
	"bullet_speed": 100.0,
	"range": 50.0
}
var gun2_level = 1
var gun2_level_requirements = {
	2: 5,  
	3: 7,  
	4: 9,  
	5: 11
}

# HP VARIABLES
var hp_level = 1
var hp_upgrade_costs = {
	2: 50,
	3: 100,
	4: 150,
	5: 200,
	6: 300,
	7: 400,
	8: 500,
	9: 750,
	10: 1000,
	11: 1500
}
var hp_upgrade_level_requirements = {
	2: 2,
	3: 2,
	4: 3,
	5: 3,
	6: 4,
	7: 4,
	8: 5,
	9: 6,
	10: 7,
	11: 8
}

# MANA VARIABLES
var mana_level = 1
var mana_upgrade_costs = {
	2: 100,
	3: 200,
	4: 300,
	5: 400,
	6: 500,
	7: 600
}
var mana_upgrade_level_requirements = {
	2: 2,
	3: 3,
	4: 4,
	5: 5,
	6: 7,
	7: 9
}

# ORBITAL ABILITY VARIABLES
var orbital_buy_cost = 200
var orbital_buy_level_req = 3
var orbital_costs = {
	2: 300,
	3: 550,
	4: 700,
	5: 850,
	6: 1000,
	7: 1222,
	8: 1200
}
var orbital_level = 1
var orbital_level_requirements = {
	2: 4,
	3: 5,
	4: 6,
	5: 7,
	6: 8,
	7: 9,
	8: 11
}

# ROCKET LAUNCHER VARIABLES
var rocketlauncher = null
var rocketlauncher_buy_cost = 150
var rocketlauncher_buy_level_req = 4
var rocketlauncher_costs = {
	2: 200,
	3: 250,
	4: 300,
	5: 350
}
var rocketlauncher_improvements = {
	"fire_rate": 0.02,
	"damage_min": 8,
	"damage_max": 16,
	"bullet_speed": 50.0,
	"range": 100.0
}
var rocketlauncher_level = 1
var rocketlauncher_level_requirements = {
	2: 6,  
	3: 8,  
	4: 10,  
	5: 12
}

# SHOCKWAVE VARIABLES
var shockwave_level = 1
var shockwave_upgrade_costs = {
	2: 150,
	3: 300,
	4: 450,
	5: 600
}
var shockwave_upgrade_level_requirements = {
	2: 3,
	3: 5,
	4: 7,
	5: 9
}

# SHOTGUN VARIABLES
var shotgun = null
var shotgun_buy_cost = 150
var shotgun_buy_level_req = 3
var shotgun_costs = {
	2: 200,
	3: 300,
	4: 400,
	5: 600
}
var shotgun_improvements = {
	"fire_rate": 0.05,
	"damage_min": 5,
	"damage_max": 10,
	"bullet_speed": 50.0,
	"range": 40.0,
	"knockback_amount": 50.0
}
var shotgun_level = 1
var shotgun_level_requirements = {
	2: 5,  
	3: 7,  
	4: 9,  
	5: 11
}

# SNIPER VARIABLES
var sniper1 = null
var sniper1_buy_cost = 75
var sniper1_buy_level_req = 2
var sniper1_costs = {
	2: 50,
	3: 75,
	4: 100,
	5: 125
}
var sniper1_improvements = {
	"fire_rate": 0.03,
	"damage_min": 6,
	"damage_max": 12,
	"bullet_speed": 200.0,
	"range": 200.0
}
var sniper1_level = 1
var sniper1_level_requirements = {
	2: 3,  
	3: 4,  
	4: 5,  
	5: 6
}


func _ready() -> void:
	pause_menu.hide()
	not_enough_coins_label.hide()
	level_requirement_label.hide()
	semi_pacifist_label.hide()
	
	
	gun_1_upgrade_button.text = "Level " + str(gun1_level + 1) + ": " + str(gun1_costs[gun1_level + 1])
	
	gun_2_upgrade_button.text = "Buy: " + str(gun2_buy_cost)
	
	sniper_upgrade_button.text = "Buy: " + str(sniper1_buy_cost)
	
	rocket_launcher_upgrade_button.text = "Buy: " + str(rocketlauncher_buy_cost)
	
	blink_upgrade_button.text = "Level " + str(blink_level + 1) + ": " + str(blink_costs[blink_level + 1])
	
	hp_upgrade_button.text = "+25 HP: " + str(hp_upgrade_costs[hp_level + 1])
	
	fire_blink_upgrade_button.text = "Buy: " + str(fire_blink_buy_cost)
	
	mana_upgrade_button.text = "+50 Mana: " + str(mana_upgrade_costs[mana_level + 1])
	
	shockwave_upgrade_button.text = "Level " + str(shockwave_level + 1) + ": " + str(shockwave_upgrade_costs[shockwave_level + 1])
	
	gravity_well_upgrade_button.text = "Buy: " + str(gravity_well_buy_cost)
	
	orbital_ability_upgrade_button.text = "Buy: " + str(orbital_buy_cost)
	
	shotgun_upgrade_button.text = "Buy: " + str(shotgun_buy_cost)
	
	orbital_ability_level_req.text = "Level Req: " + str(orbital_level_requirements[orbital_level + 1])
	gun_1_level_req.text = "Level Req: " + str(gun1_level_requirements[gun1_level + 1])
	gun_2_level_req.text = "Level Req: " + str(gun2_buy_level_req)
	sniper_level_req.text = "Level Req: " + str(sniper1_buy_level_req)
	rocket_launcher_level_req.text = "Level Req: " + str(rocketlauncher_buy_level_req)
	blink_level_req.text = "Level Req: " + str(blink_level_requirements[blink_level + 1])
	hp_level_req.text = "Level Req: " + str(hp_upgrade_level_requirements[hp_level + 1])
	fire_blink_level_req.text = "Level Req: " + str(fire_blink_buy_level_req)
	mana_level_req.text = "Level Req: " + str(mana_upgrade_level_requirements[mana_level + 1])
	shockwave_level_req.text = "Level Req: " + str(shockwave_upgrade_level_requirements[shockwave_level + 1])
	gravity_well_level_req.text = "Level Req: " + str(gravity_well_buy_level_req)
	shotgun_level_req.text = "Level Req: " + str(shotgun_buy_level_req)
	
	ui = get_node("/root/world/UI")
	gun1 = get_node("/root/world/player/gun")
	gun2 = get_node("/root/world/player/gun2")
	sniper1 = get_node("/root/world/player/sniper1")
	rocketlauncher = get_node("/root/world/player/RocketLauncher")
	shotgun = get_node("/root/world/player/Shotgun")
	player = get_node("/root/world/player")
	
	player_coins_label.text = "Coins: " + str(ui.coins_collected)
	player_level_label.text = "Level: " + str(ui.experience_manager.get_current_level())
		
	update_cost_labels()


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

#func _input(event):
	#if event.is_action_pressed("pause"):
		#toggle_pause()

func toggle_pause():
	if pause_menu.visible and !get_tree().paused:
		pause_menu.hide()
	else:
		pause_menu.show()
		update_cost_labels()
		player_coins_label.text = "Coins: " + str(ui.coins_collected)
		player_level_label.text = "Level: " + str(ui.experience_manager.get_current_level())
		
		continue_button.visible = true
			
		get_tree().paused = true
		

func update_cost_labels():
	if semi_pacifist:
		gun_2_upgrade_button.text = "UNPURCHASABLE"
		gun_2_level_req.text = "UNPURCHASABLE"
		
		sniper_upgrade_button.text = "UNPURCHASABLE"
		sniper_level_req.text = "UNPURCHASABLE"
		
		rocket_launcher_upgrade_button.text = "UNPURCHASABLE"
		rocket_launcher_level_req.text = "UNPURCHASABLE"
		
		shotgun_upgrade_button.text = "UNPURCHASABLE"
		shotgun_level_req.text = "UNPURCHASABLE"
	else:
		if player.owns_gun2 == true and gun2_level < 5:
			gun_2_upgrade_button.text = "Level " + str(gun2_level + 1) + ": " + str(gun2_costs[gun2_level + 1])
			gun_2_level_req.text = "Level Req: " + str(gun2_level_requirements[gun2_level + 1])
		elif gun2_level >= 5:
			gun_2_upgrade_button.text = "MAX LEVEL"
			gun_2_level_req.text = "MAX LEVEL"
			
		if player.owns_sniper1 == true and sniper1_level < 5:
			sniper_upgrade_button.text = "Level: " + str(sniper1_level + 1) + ": " + str(sniper1_costs[sniper1_level + 1])
			sniper_level_req.text = "Level Req: " + str(sniper1_level_requirements[sniper1_level + 1])
		elif sniper1_level >= 5:
			sniper_upgrade_button.text = "MAX LEVEL"
			sniper_level_req.text = "MAX LEVEL"
			
		if player.owns_rocketlauncher == true and rocketlauncher_level < 5:
			rocket_launcher_upgrade_button.text = "Level: " + str(rocketlauncher_level + 1) + ": " + str(rocketlauncher_costs[rocketlauncher_level + 1])
			rocket_launcher_level_req.text = "Level Req: " + str(rocketlauncher_level_requirements[rocketlauncher_level + 1])
		elif rocketlauncher_level >= 5:
			rocket_launcher_upgrade_button.text = "MAX LEVEL"
			rocket_launcher_level_req.text = "MAX LEVEL"
			
		if player.owns_shotgun == true and shotgun_level < 5:
			shotgun_upgrade_button.text = "Level: " + str(shotgun_level + 1) + ": " + str(shotgun_costs[shotgun_level + 1])
			shotgun_level_req.text = "Level Req: " + str(shotgun_level_requirements[shotgun_level + 1])
		elif shotgun_level >= 5:
			shotgun_upgrade_button.text = "MAX LEVEL"
			shotgun_level_req.text = "MAX LEVEL"
			
	
	if player.owns_gun1 == true and gun1_level < 5:
		gun_1_upgrade_button.text = "Level " + str(gun1_level + 1) + ": " + str(gun1_costs[gun1_level + 1])
		gun_1_level_req.text = "Level Req: " + str(gun1_level_requirements[gun1_level + 1])
	elif gun1_level >= 5:
		gun_1_upgrade_button.text = "MAX LEVEL"
		gun_1_level_req.text = "MAX LEVEL"
	
	
	if blink_level < 5:
		blink_upgrade_button.text = "Cooldown " + str(blink_cooldown_upgrade[blink_level + 1]) + "s: " + str(blink_costs[blink_level + 1])
		blink_level_req.text = "Level Req: " + str(blink_level_requirements[blink_level + 1])
	else:
		blink_upgrade_button.text = "MAX LEVEL"
		blink_level_req.text = "MAX LEVEL"
	
	
	if hp_level < 11:
		hp_upgrade_button.text = "+25 HP: " + str(hp_upgrade_costs[hp_level + 1])
		hp_level_req.text = "Level Req: " + str(hp_upgrade_level_requirements[hp_level + 1])
	else:
		hp_upgrade_button.text = "MAX LEVEL"
		hp_level_req.text = "MAX LEVEL"
		
		
	if player.owns_fire_blink == true and fire_blink_level < 5:
		fire_blink_upgrade_button.text = "Level " + str(fire_blink_level + 1) + ": " + str(fire_blink_costs[fire_blink_level + 1])
		fire_blink_level_req.text = "Level Req: " + str(fire_blink_level_requirements[fire_blink_level + 1])
	elif fire_blink_level >= 5:
		fire_blink_upgrade_button.text = "MAX LEVEL"
		fire_blink_level_req.text = "MAX LEVEL"
		
	
	if mana_level < 7:
		mana_upgrade_button.text = "+50 Mana: " + str(mana_upgrade_costs[mana_level + 1])
		mana_level_req.text = "Level Req: " + str(mana_upgrade_level_requirements[mana_level + 1])
	else:
		mana_upgrade_button.text = "MAX LEVEL"
		mana_level_req.text = "MAX LEVEL"
		
	if shockwave_level < 5:
		shockwave_upgrade_button.text = "Level: " + str(shockwave_level + 1) + ": " + str(shockwave_upgrade_costs[shockwave_level + 1])
		shockwave_level_req.text = "Level Req: " + str(shockwave_upgrade_level_requirements[shockwave_level + 1])
	else:
		shockwave_upgrade_button.text = "MAX LEVEL"
		shockwave_level_req.text = "MAX LEVEL"
	
	if player.owns_gravity_well == true and gravity_well_level < 5:
		gravity_well_upgrade_button.text = "Level " + str(gravity_well_level + 1) + ": " + str(gravity_well_costs[gravity_well_level + 1])
		gravity_well_level_req.text = "Level Req: " + str(gravity_well_level_requirements[gravity_well_level + 1])
	elif fire_blink_level >= 5:
		gravity_well_upgrade_button.text = "MAX LEVEL"
		gravity_well_level_req.text = "MAX LEVEL"
		
	if player.owns_orbital_ability == true and orbital_level < 8:
		orbital_ability_upgrade_button.text = "Level " + str(orbital_level + 1) + ": " + str(orbital_costs[orbital_level + 1])
		orbital_ability_level_req.text = "Level Req: " + str(orbital_level_requirements[orbital_level + 1])
	elif orbital_level >= 8:
		orbital_ability_upgrade_button.text = "MAX LEVEL"
		orbital_ability_level_req.text = "MAX LEVEL"
		
func disable_enable_buttons(disabled: bool = true):
	if disabled:
		gun_1_upgrade_button.disabled = true
		gun_2_upgrade_button.disabled = true
		sniper_upgrade_button.disabled = true
		blink_upgrade_button.disabled = true
		hp_upgrade_button.disabled = true
		fire_blink_upgrade_button.disabled = true
		rocket_launcher_upgrade_button.disabled = true
		shockwave_upgrade_button.disabled = true
		mana_upgrade_button.disabled = true
		gravity_well_upgrade_button.disabled = true
		orbital_ability_upgrade_button.disabled = true
		shotgun_upgrade_button.disabled = true
	else:
		gun_1_upgrade_button.disabled = false
		gun_2_upgrade_button.disabled = false
		sniper_upgrade_button.disabled = false
		blink_upgrade_button.disabled = false
		hp_upgrade_button.disabled = false
		fire_blink_upgrade_button.disabled = false
		rocket_launcher_upgrade_button.disabled = false
		shockwave_upgrade_button.disabled = false
		mana_upgrade_button.disabled = false
		gravity_well_upgrade_button.disabled = false
		orbital_ability_upgrade_button.disabled = false
		shotgun_upgrade_button.disabled = false

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
	
	var ShotgunBulletScript: GDScript = load("res://scripts/shotgun_bullet.gd")
	ShotgunBulletScript.damage_min_bonus = 0
	ShotgunBulletScript.damage_max_bonus = 0
	ShotgunBulletScript.speed_bonus = 0.0
	ShotgunBulletScript.range_bonus = 0.0
	ShotgunBulletScript.knockback_amount = 400.0
	ShotgunBulletScript.glass_cannon_multiplier = false
	ShotgunBulletScript.runforrestrun_multiplier = false
	
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
	ShockwaveScript.damage = 20
	ShockwaveScript.knockback_amount = 200.0
	
	var OrbitalAbilityScript: GDScript = load("res://scripts/orbital_ability.gd")
	OrbitalAbilityScript.ability_level = 1
	
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
	
func _on_continue_button_pressed() -> void:
	var difficulty_manager = get_node("/root/world/DifficultyManager")
	if difficulty_manager:
		difficulty_manager.resume_game()
		
	get_tree().paused = false
	pause_menu.visible = false



func _on_mana_upgrade_button_pressed() -> void:
	if mana_level >= 7:
		return
		
	var next_level = mana_level + 1
	var cost = mana_upgrade_costs[next_level]
	var level_req = mana_upgrade_level_requirements[next_level]
	
	if ui.coins_collected >= cost:
		if ui.experience_manager.current_level >= level_req:
			ui.coins_collected -= cost
			ui.coin_label.text = "Coins: " + str(ui.coins_collected)
			
			mana_level += 1
			
			var PlayerScript = load("res://scripts/player.gd")
			PlayerScript.set_max_mana(PlayerScript.max_mana + 50.0)
			player.current_mana += 50.0
			player.mana_changed.emit(player.current_mana)
			
			player_coins_label.text = "Coins: " + str(ui.coins_collected)
			update_cost_labels()
		else:
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
	elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
		disable_enable_buttons()
		
		var original_position = not_enough_coins_label.position
		not_enough_coins_label.position.y += 50
		
		not_enough_coins_label.show()
		level_requirement_label.text = "Required Level: " + str(level_req)
		level_requirement_label.show()
		await get_tree().create_timer(1.2).timeout
		level_requirement_label.hide()
		not_enough_coins_label.hide()
		
		not_enough_coins_label.position = original_position
		disable_enable_buttons(false)
	else:
		not_enough_coins_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_coins_label.hide()


func _on_shockwave_upgrade_button_pressed() -> void:
	if shockwave_level >= 5:
		return
		
	var next_level = shockwave_level + 1
	var cost = shockwave_upgrade_costs[next_level]
	var level_req = shockwave_upgrade_level_requirements[next_level]
	
	if ui.coins_collected >= cost:
		if ui.experience_manager.current_level >= level_req:
			ui.coins_collected -= cost
			ui.coin_label.text = "Coins: " + str(ui.coins_collected)
			
			shockwave_level += 1
			
			var ShockwaveScript = load("res://scripts/shockwave.gd")
			ShockwaveScript.damage += 10
			ShockwaveScript.knockback_amount += 100.0
			
			player_coins_label.text = "Coins: " + str(ui.coins_collected)
			update_cost_labels()
		else:
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
	elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
		disable_enable_buttons()
		
		var original_position = not_enough_coins_label.position
		not_enough_coins_label.position.y += 50
		
		not_enough_coins_label.show()
		level_requirement_label.text = "Required Level: " + str(level_req)
		level_requirement_label.show()
		await get_tree().create_timer(1.2).timeout
		level_requirement_label.hide()
		not_enough_coins_label.hide()
		
		not_enough_coins_label.position = original_position
		disable_enable_buttons(false)
	else:
		not_enough_coins_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_coins_label.hide()


func _on_hp_upgrade_button_pressed() -> void:
	if hp_level >= 11:
		return
		
	var next_level = hp_level + 1
	var cost = hp_upgrade_costs[next_level]
	var level_req = hp_upgrade_level_requirements[next_level]
	
	if ui.coins_collected >= cost:
		if ui.experience_manager.current_level >= level_req:
			ui.coins_collected -= cost
			ui.coin_label.text = "Coins: " + str(ui.coins_collected)
			
			hp_level += 1
			
			var PlayerScript = load("res://scripts/player.gd")
			PlayerScript.set_max_health(PlayerScript.max_health + 25)
			player.health += 25
			player.health_changed.emit(player.health)
			
			player_coins_label.text = "Coins: " + str(ui.coins_collected)
			update_cost_labels()
		else:
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
	elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
		disable_enable_buttons()
		
		var original_position = not_enough_coins_label.position
		not_enough_coins_label.position.y += 50
		
		not_enough_coins_label.show()
		level_requirement_label.text = "Required Level: " + str(level_req)
		level_requirement_label.show()
		await get_tree().create_timer(1.2).timeout
		level_requirement_label.hide()
		not_enough_coins_label.hide()
		
		not_enough_coins_label.position = original_position
		disable_enable_buttons(false)
	else:
		not_enough_coins_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_coins_label.hide()


func _on_fire_blink_upgrade_button_pressed() -> void:
	if player.owns_fire_blink == false:
		if ui.coins_collected >= fire_blink_buy_cost:
			if ui.experience_manager.current_level >= fire_blink_buy_level_req:
				ui.coins_collected -= fire_blink_buy_cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				if player:
					player.acquire_fire_blink()
				else:
					print("Player reference is null!")
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(fire_blink_buy_level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < fire_blink_buy_cost and ui.experience_manager.current_level < fire_blink_buy_level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(fire_blink_buy_level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
	else:
		if fire_blink_level >= 5:
			return
			
		var next_level = fire_blink_level + 1
		var cost = fire_blink_costs[next_level]
		var level_req = fire_blink_level_requirements[next_level]
		
		if ui.coins_collected >= cost:
			if ui.experience_manager.current_level >= level_req:
				ui.coins_collected -= cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				fire_blink_level += 1
				
				var FireBlinkScript = load("res://scripts/fire_blink.gd")
				FireBlinkScript.damage_min_bonus += fire_blink_improvements["damage_min"]
				FireBlinkScript.damage_max_bonus += fire_blink_improvements["damage_max"]
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()


func _on_blink_upgrade_button_pressed() -> void:
	if blink_level >= 5:
		return
		
	var next_level = blink_level + 1
	var cost = blink_costs[next_level]
	var level_req = blink_level_requirements[next_level]
	
	if ui.coins_collected >= cost:
		if ui.experience_manager.current_level >= level_req:
			ui.coins_collected -= cost
			ui.coin_label.text = "Coins: " + str(ui.coins_collected)
			
			blink_level += 1
			
			var player = get_node("/root/world/player")
			player.blink_cooldown = blink_cooldown_upgrade[blink_level]
			
			player_coins_label.text = "Coins: " + str(ui.coins_collected)
			update_cost_labels()
		else:
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
	elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
		disable_enable_buttons()
		
		var original_position = not_enough_coins_label.position
		not_enough_coins_label.position.y += 50
		
		not_enough_coins_label.show()
		level_requirement_label.text = "Required Level: " + str(level_req)
		level_requirement_label.show()
		await get_tree().create_timer(1.2).timeout
		level_requirement_label.hide()
		not_enough_coins_label.hide()
		
		not_enough_coins_label.position = original_position
		disable_enable_buttons(false)
	else:
		not_enough_coins_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_coins_label.hide()


func _on_rocket_launcher_upgrade_button_pressed() -> void:
	if semi_pacifist:
		disable_enable_buttons()
		semi_pacifist_label.show()
		await get_tree().create_timer(1.2).timeout
		semi_pacifist_label.hide()
		disable_enable_buttons(false)
		return
	
	if player.owns_rocketlauncher == false:
		if ui.coins_collected >= rocketlauncher_buy_cost:
			if ui.experience_manager.current_level >= rocketlauncher_buy_level_req:
				ui.coins_collected -= rocketlauncher_buy_cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				if player:
					player.acquire_rocketlauncher()
				else:
					print("Player reference is null!")
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(rocketlauncher_buy_level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < rocketlauncher_buy_cost and ui.experience_manager.current_level < rocketlauncher_buy_level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(rocketlauncher_buy_level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
	else:
		if rocketlauncher_level >= 5:
			return
			
		var next_level = rocketlauncher_level + 1
		var cost = rocketlauncher_costs[next_level]
		var level_req = rocketlauncher_level_requirements[next_level]
		
		if ui.coins_collected >= cost:
			if ui.experience_manager.current_level >= level_req:
				ui.coins_collected -= cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				rocketlauncher_level += 1
				
				rocketlauncher.fire_rate -= rocketlauncher_improvements["fire_rate"]
				
				var RocketLauncherScript = load("res://scripts/rocket_ammo.gd")
				RocketLauncherScript.damage_min_bonus += rocketlauncher_improvements["damage_min"]
				RocketLauncherScript.damage_max_bonus += rocketlauncher_improvements["damage_max"]
				RocketLauncherScript.speed_bonus += rocketlauncher_improvements["bullet_speed"]
				RocketLauncherScript.range_bonus += rocketlauncher_improvements["range"]
				
				if rocketlauncher_level == 2:
					rocketlauncher.modulate = Color(0, 1, 0, 0.8)  # green
				elif rocketlauncher_level == 3:
					rocketlauncher.modulate = Color(1, 0, 0, 0.8)  # red
				elif rocketlauncher_level == 4:
					rocketlauncher.modulate = Color(0.627, 0.125, 0.941, 0.8)  # purple
				else:
					rocketlauncher.modulate = Color(1, 1, 0, 0.8)  # gold
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()


func _on_sniper_upgrade_button_pressed() -> void:
	if semi_pacifist:
		disable_enable_buttons()
		semi_pacifist_label.show()
		await get_tree().create_timer(1.2).timeout
		semi_pacifist_label.hide()
		disable_enable_buttons(false)
		return
		
	if player.owns_sniper1 == false:
		if ui.coins_collected >= sniper1_buy_cost:
			if ui.experience_manager.current_level >= sniper1_buy_level_req:
				ui.coins_collected -= sniper1_buy_cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				if player:
					player.acquire_sniper1()
				else:
					print("Player reference is null!")
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(sniper1_buy_level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < sniper1_buy_cost and ui.experience_manager.current_level < sniper1_buy_level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(sniper1_buy_level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
	else:
		if sniper1_level >= 5:
			return
			
		var next_level = sniper1_level + 1
		var cost = sniper1_costs[next_level]
		var level_req = sniper1_level_requirements[next_level]
		
		if ui.coins_collected >= cost:
			if ui.experience_manager.current_level >= level_req:
				ui.coins_collected -= cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				sniper1_level += 1
				
				sniper1.fire_rate -= sniper1_improvements["fire_rate"]
				
				var BulletScript = load("res://scripts/sniper_1_bullet.gd")
				BulletScript.damage_min_bonus += sniper1_improvements["damage_min"]
				BulletScript.damage_max_bonus += sniper1_improvements["damage_max"]
				BulletScript.speed_bonus += sniper1_improvements["bullet_speed"]
				BulletScript.range_bonus += sniper1_improvements["range"]
				
				if sniper1_level == 2:
					sniper1.modulate = Color(0, 1, 0, 0.8)
				elif sniper1_level == 3:
					sniper1.modulate = Color(1, 0, 0, 0.8)
				elif sniper1_level == 4:
					sniper1.modulate = Color(0.627, 0.125, 0.941, 0.8)
				else:
					sniper1.modulate = Color(1, 1, 0, 0.8)
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()


func _on_gun_2_upgrade_button_pressed() -> void:
	if semi_pacifist:
		disable_enable_buttons()
		semi_pacifist_label.show()
		await get_tree().create_timer(1.2).timeout
		semi_pacifist_label.hide()
		disable_enable_buttons(false)
		return
		
	if player.owns_gun2 == false:
		if ui.coins_collected >= gun2_buy_cost:
			if ui.experience_manager.current_level >= gun2_buy_level_req:
				ui.coins_collected -= gun2_buy_cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				if player:
					player.acquire_gun2()
				else:
					print("Player reference is null!")
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(gun2_buy_level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < gun2_buy_cost and ui.experience_manager.current_level < gun2_buy_level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(gun2_buy_level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
	else:
		if gun2_level >= 5:
			return
			
		var next_level = gun2_level + 1
		var cost = gun2_costs[next_level]
		var level_req = gun2_level_requirements[next_level]
		
		if ui.coins_collected >= cost:
			if ui.experience_manager.current_level >= level_req:
				ui.coins_collected -= cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				gun2_level += 1
				
				gun2.fire_rate -= gun2_improvements["fire_rate"]
				
				var BulletScript = load("res://scripts/bullet_2.gd")
				BulletScript.damage_min_bonus += gun2_improvements["damage_min"]
				BulletScript.damage_max_bonus += gun2_improvements["damage_max"]
				BulletScript.speed_bonus += gun2_improvements["bullet_speed"]
				BulletScript.range_bonus += gun2_improvements["range"]
				
				if gun2_level == 2:
					gun2.modulate = Color(0, 1, 0, 0.8)
				elif gun2_level == 3:
					gun2.modulate = Color(1, 0, 0, 0.8)
				elif gun2_level == 4:
					gun2.modulate = Color(0.627, 0.125, 0.941, 0.8)
				else:
					gun2.modulate = Color(1, 0.84, 0.2, 0.8)
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()


func _on_gun_1_upgrade_button_pressed() -> void:
	if gun1_level >= 5:
		return
		
	var next_level = gun1_level + 1
	var cost = gun1_costs[next_level]
	var level_req = gun1_level_requirements[next_level]
	
	if ui.coins_collected >= cost:
		if ui.experience_manager.current_level >= level_req:
			ui.coins_collected -= cost
			ui.coin_label.text = "Coins: " + str(ui.coins_collected)
			
			gun1_level += 1
			
			gun1.fire_rate -= gun1_improvements["fire_rate"]
			
			var BulletScript = load("res://scripts/bullet.gd")
			BulletScript.damage_min_bonus += gun1_improvements["damage_min"]
			BulletScript.damage_max_bonus += gun1_improvements["damage_max"]
			BulletScript.speed_bonus += gun1_improvements["bullet_speed"]
			BulletScript.range_bonus += gun1_improvements["range"]
			
			if gun1_level == 2:
				gun1.modulate = Color(0, 1, 0, 0.9)
			elif gun1_level == 3:
				gun1.modulate = Color(1, 0, 0, 0.9)
			elif gun1_level == 4:
				gun1.modulate = Color(0.627, 0.125, 0.941, 0.9)
			else:
				gun1.modulate = Color(1, 0.84, 0.2, 0.8)
			
			player_coins_label.text = "Coins: " + str(ui.coins_collected)
			update_cost_labels()
		else:
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
	elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
		disable_enable_buttons()
		
		var original_position = not_enough_coins_label.position
		not_enough_coins_label.position.y += 50
		
		not_enough_coins_label.show()
		level_requirement_label.text = "Required Level: " + str(level_req)
		level_requirement_label.show()
		await get_tree().create_timer(1.2).timeout
		level_requirement_label.hide()
		not_enough_coins_label.hide()
		
		not_enough_coins_label.position = original_position
		disable_enable_buttons(false)
	else:
		not_enough_coins_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_coins_label.hide()
		
		
func _on_gravity_well_upgrade_button_pressed() -> void:
	if player.owns_gravity_well == false:
		if ui.coins_collected >= gravity_well_buy_cost:
			if ui.experience_manager.current_level >= gravity_well_buy_level_req:
				ui.coins_collected -= gravity_well_buy_cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				if player:
					player.acquire_gravity_well()
				else:
					print("Player reference is null!")
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(gravity_well_buy_level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
	else:
		if gravity_well_level >= 5:
			return
			
		var next_level = gravity_well_level + 1
		var cost = gravity_well_costs[next_level]
		var level_req = gravity_well_level_requirements[next_level]
		
		if ui.coins_collected >= cost:
			if ui.experience_manager.current_level >= level_req:
				ui.coins_collected -= cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				gravity_well_level += 1
				
				var GravityWellScript = load("res://scenes/gravity_well.gd")
				GravityWellScript.damage_bonus += gravity_well_improvements["damage"]
				GravityWellScript.duration_bonus += gravity_well_improvements["duration"]
				GravityWellScript.pull_radius_bonus += gravity_well_improvements["pull_radius"]
				GravityWellScript.damage_radius_bonus += gravity_well_improvements["damage_radius"]
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()


func _on_orbital_ability_upgrade_button_pressed() -> void:
	if player.owns_orbital_ability == false:
		if ui.coins_collected >= orbital_buy_cost:
			if ui.experience_manager.current_level >= orbital_buy_level_req:
				ui.coins_collected -= orbital_buy_cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				if player:
					player.acquire_orbital_ability()
				else:
					print("Player reference is null!")
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(orbital_buy_level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
	else:
		if orbital_level >= 8:
			return
			
		var next_level = orbital_level + 1
		var cost = orbital_costs[next_level]
		var level_req = orbital_level_requirements[next_level]
		
		if ui.coins_collected >= cost:
			if ui.experience_manager.current_level >= level_req:
				ui.coins_collected -= cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				orbital_level += 1
				
				var OrbitalAbilityScript = load("res://scenes/orbital_ability.tscn")
				OrbitalAbilityScript.ability_level += 1
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()


func _on_shotgun_upgrade_button_pressed() -> void:
	if semi_pacifist:
		disable_enable_buttons()
		semi_pacifist_label.show()
		await get_tree().create_timer(1.2).timeout
		semi_pacifist_label.hide()
		disable_enable_buttons(false)
		return
		
	if player.owns_shotgun == false:
		if ui.coins_collected >= shotgun_buy_cost:
			if ui.experience_manager.current_level >= shotgun_buy_level_req:
				ui.coins_collected -= shotgun_buy_cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				if player:
					player.acquire_shotgun()
				else:
					print("Player reference is null!")
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(shotgun_buy_level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < shotgun_buy_cost and ui.experience_manager.current_level < shotgun_buy_level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(shotgun_buy_level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
	else:
		if shotgun_level >= 5:
			return
			
		var next_level = shotgun_level + 1
		var cost = shotgun_costs[next_level]
		var level_req = shotgun_level_requirements[next_level]
		
		if ui.coins_collected >= cost:
			if ui.experience_manager.current_level >= level_req:
				ui.coins_collected -= cost
				ui.coin_label.text = "Coins: " + str(ui.coins_collected)
				
				shotgun_level += 1
				
				shotgun.fire_rate -= shotgun_improvements["fire_rate"]
				
				var BulletScript = load("res://scripts/shotgun_bullet.gd")
				BulletScript.damage_min_bonus += shotgun_improvements["damage_min"]
				BulletScript.damage_max_bonus += shotgun_improvements["damage_max"]
				BulletScript.speed_bonus += shotgun_improvements["bullet_speed"]
				BulletScript.range_bonus += shotgun_improvements["range"]
				BulletScript.knockback_amount += shotgun_improvements["knockback_amount"]
				
				if shotgun_level == 2:
					shotgun.modulate = Color(0, 1, 0, 0.8)
				elif shotgun_level == 3:
					shotgun.modulate = Color(1, 0, 0, 0.8)
				elif shotgun_level == 4:
					shotgun.modulate = Color(0.627, 0.125, 0.941, 0.8)
				else:
					shotgun.modulate = Color(1, 0.84, 0.2, 0.8)
				
				player_coins_label.text = "Coins: " + str(ui.coins_collected)
				update_cost_labels()
			else:
				level_requirement_label.text = "Required Level: " + str(level_req)
				level_requirement_label.show()
				await get_tree().create_timer(1.2).timeout
				level_requirement_label.hide()
		elif ui.coins_collected < cost and ui.experience_manager.current_level < level_req:
			disable_enable_buttons()
			
			var original_position = not_enough_coins_label.position
			not_enough_coins_label.position.y += 50
			
			not_enough_coins_label.show()
			level_requirement_label.text = "Required Level: " + str(level_req)
			level_requirement_label.show()
			await get_tree().create_timer(1.2).timeout
			level_requirement_label.hide()
			not_enough_coins_label.hide()
			
			not_enough_coins_label.position = original_position
			disable_enable_buttons(false)
		else:
			not_enough_coins_label.show()
			await get_tree().create_timer(1.2).timeout
			not_enough_coins_label.hide()
