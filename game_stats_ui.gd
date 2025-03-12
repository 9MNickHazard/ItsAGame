extends CanvasLayer

@onready var stats_container: VBoxContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/StatsContainer
@onready var restart_button: Button = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/RestartButton
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

var pixel_font: FontFile = preload("res://assets/fonts/PixelOperator8.ttf")

func _ready() -> void:
	populate_stats()
	
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


func populate_stats() -> void:
	# time stats
	add_stat_label("Time Stats", true)
	add_stat_label("Total Play Time: " + stats_manager.get_formatted_time())
	add_stat_label("")
	
	# collection stats
	add_stat_label("Collection Stats", true)
	add_stat_label("Total Coins Collected: " + str(stats_manager.total_coins_collected))
	add_stat_label("Total Hearts Collected: " + str(stats_manager.total_hearts_collected))
	add_stat_label("Total Mana Balls Collected: " + str(stats_manager.total_mana_balls_collected))
	add_stat_label("Total Diamonds Collected: " + str(stats_manager.total_diamonds_collected))
	add_stat_label("")
	
	# combat stats
	add_stat_label("Combat Stats", true)
	add_stat_label("Damage Dealt to Mobs: " + str(round(stats_manager.damage_dealt_to_enemies)))
	add_stat_label("Damage Taken from Mobs: " + str(round(stats_manager.damage_taken_from_enemies)))
	add_stat_label("Total Mobs Killed: " + str(stats_manager.total_enemies_killed))
	add_stat_label("")
	
	# enemy kills
	if not stats_manager.enemy_kills_by_type.is_empty():
		add_stat_label("Kills by Enemy Type", true)
		for enemy_type in stats_manager.enemy_kills_by_type:
			add_stat_label(enemy_type + ": " + str(stats_manager.enemy_kills_by_type[enemy_type]))
		add_stat_label("")
	
	# ability usage
	add_stat_label("Ability Usage", true)
	add_stat_label("Total Blinks Used: " + str(stats_manager.total_blinks_used))
	add_stat_label("Total Shockwaves Used: " + str(stats_manager.total_shockwaves_used))
	add_stat_label("Total Gravity Wells Used: " + str(stats_manager.total_gravity_wells_used))
	add_stat_label("Total Magic Orbitals Used: " + str(stats_manager.total_orbital_abilities_used))
	add_stat_label("Total Shots Fired: " + str(stats_manager.total_shots_fired))
	add_stat_label("")
	
	# shots by weapon
	if not stats_manager.shots_fired_by_weapon.is_empty():
		add_stat_label("Shots by Weapon", true)
		for weapon in stats_manager.shots_fired_by_weapon:
			add_stat_label(weapon + ": " + str(stats_manager.shots_fired_by_weapon[weapon]))
		add_stat_label("")
	
	# progress stats
	add_stat_label("Progress Stats", true)
	add_stat_label("Highest Difficulty Reached: " + str(snappedf(stats_manager.highest_difficulty_reached, 0.1)))
	add_stat_label("Highest Level Reached: " + str(stats_manager.highest_level_reached))
	
	# additional Stats
	add_stat_label("")
	add_stat_label("Additional Stats", true)
	
	# dps
	if stats_manager.total_play_time_seconds > 0:
		var dps = stats_manager.damage_dealt_to_enemies / stats_manager.total_play_time_seconds
		add_stat_label("Damage Per Second: " + str(snapped(dps, 0.01)))
	
	# average coins/kill
	if stats_manager.total_enemies_killed > 0:
		var coins_per_kill = float(stats_manager.total_coins_collected) / stats_manager.total_enemies_killed
		add_stat_label("Average Coins Per Kill: " + str(snappedf(coins_per_kill, 0.1)))

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
