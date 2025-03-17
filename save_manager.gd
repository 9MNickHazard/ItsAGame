extends Node

# Upgrade levels
static var base_health_level: int = 0
static var base_mana_level: int = 0
static var movement_speed_level: int = 0
static var min_weapon_damage_level: int = 0
static var max_weapon_damage_level: int = 0
static var min_ability_damage_level: int = 0
static var max_ability_damage_level: int = 0
static var luck_level: int = 0
static var revive_level: int = 0
static var mana_regeneration_level: int = 0
static var hp_regeneration_level: int = 0
static var armor_level: int = 0
static var xp_bonus_level: int = 0
static var gold_bonus_level: int = 0
static var magnet_level: int = 0

# Gems
static var gem_total: int = 0

# Difficulty Mode
static var unlocked_heroic: bool = false
static var unlocked_legendary: bool = false

# File path
const SAVE_FILE_PATH: String = "user://game_save.save"


func _ready() -> void:
	load_game()
	
	apply_all_saved_upgrades()


func save_game() -> void:
	var save_file = ConfigFile.new()
	
	save_file.set_value("upgrades", "base_health_level", base_health_level)
	save_file.set_value("upgrades", "base_mana_level", base_mana_level)
	save_file.set_value("upgrades", "movement_speed_level", movement_speed_level)
	save_file.set_value("upgrades", "min_weapon_damage_level", min_weapon_damage_level)
	save_file.set_value("upgrades", "max_weapon_damage_level", max_weapon_damage_level)
	save_file.set_value("upgrades", "min_ability_damage_level", min_ability_damage_level)
	save_file.set_value("upgrades", "max_ability_damage_level", max_ability_damage_level)
	save_file.set_value("upgrades", "luck_level", luck_level)
	save_file.set_value("upgrades", "revive_level", revive_level)
	save_file.set_value("upgrades", "mana_regeneration_level", mana_regeneration_level)
	save_file.set_value("upgrades", "hp_regeneration_level", hp_regeneration_level)
	save_file.set_value("upgrades", "armor_level", armor_level)
	save_file.set_value("upgrades", "xp_bonus_level", xp_bonus_level)
	save_file.set_value("upgrades", "gold_bonus_level", gold_bonus_level)
	save_file.set_value("upgrades", "magnet_level", magnet_level)
	
	save_file.set_value("currency", "gems", gem_total)
	
	save_file.set_value("difficulty", "unlocked_heroic", unlocked_heroic)
	save_file.set_value("difficulty", "unlocked_legendary", unlocked_legendary)
	
	save_file.set_value("metadata", "version", 0.5)
	
	var error = save_file.save(SAVE_FILE_PATH)
	if error != OK:
		print("Error saving game: ", error)
	else:
		print("Game saved successfully")


func load_game() -> void:
	var save_file = ConfigFile.new()
	var error = save_file.load(SAVE_FILE_PATH)
	
	if error != OK:
		print("No save file found or error loading. Using default values.")
		return
	
	base_health_level = save_file.get_value("upgrades", "base_health_level", 0)
	base_mana_level = save_file.get_value("upgrades", "base_mana_level", 0)
	movement_speed_level = save_file.get_value("upgrades", "movement_speed_level", 0)
	min_weapon_damage_level = save_file.get_value("upgrades", "min_weapon_damage_level", 0)
	max_weapon_damage_level = save_file.get_value("upgrades", "max_weapon_damage_level", 0)
	min_ability_damage_level = save_file.get_value("upgrades", "min_ability_damage_level", 0)
	max_ability_damage_level = save_file.get_value("upgrades", "max_ability_damage_level", 0)
	luck_level = save_file.get_value("upgrades", "luck_level", 0)
	revive_level = save_file.get_value("upgrades", "revive_level", 0)
	mana_regeneration_level = save_file.get_value("upgrades", "mana_regeneration_level", 0)
	hp_regeneration_level = save_file.get_value("upgrades", "hp_regeneration_level", 0)
	armor_level = save_file.get_value("upgrades", "armor_level", 0)
	xp_bonus_level = save_file.get_value("upgrades", "xp_bonus_level", 0)
	gold_bonus_level = save_file.get_value("upgrades", "gold_bonus_level", 0)
	magnet_level = save_file.get_value("upgrades", "magnet_level", 0)
	
	gem_total = save_file.get_value("currency", "gems", 0)
	
	unlocked_heroic = save_file.get_value("difficulty", "unlocked_heroic", false)
	unlocked_legendary = save_file.get_value("difficulty", "unlocked_legendary", false)
	
	print("Game loaded successfully")


func apply_all_saved_upgrades() -> void:
	var upgrade_effects = {
		"base_health": [10.0, 15.0, 25.0, 50.0],
		"base_mana": [25.0, 25.0, 50.0, 50.0],
		"movement_speed": [15.0, 15.0, 15.0, 25.0, 40.0],
		"min_weapon_damage": [1, 1, 1, 2, 3],
		"max_weapon_damage": [2, 2, 2, 3, 5],
		"min_ability_damage": [1, 2, 3, 5],
		"max_ability_damage": [2, 3, 5, 8],
		"luck": [5, 5, 5],
		"revive": [1],
		"mana_regeneration": [0.5, 0.5, 0.5],
		"hp_regeneration": [0.2, 0.2, 0.2],
		"armor": [1, 1, 1, 1, 2],
		"xp_bonus": [0.05, 0.08, 0.12, 0.20],
		"gold_bonus": [.10, .15, .25, .4],
		"magnet": [50.0, 100.0, 150.0]
	}
	
	# Apply Health
	var PlayerScript = load("res://scripts/player.gd")
	PlayerScript.permanent_health_bonus = 0.0
	for i in range(base_health_level):
		PlayerScript.permanent_health_bonus += upgrade_effects["base_health"][i]
	
	# Apply Mana
	PlayerScript.permanent_mana_bonus = 0.0
	for i in range(base_mana_level):
		PlayerScript.permanent_mana_bonus += upgrade_effects["base_mana"][i]
	
	# Apply Movement Speed
	PlayerScript.permanent_speed_bonus = 0.0
	for i in range(movement_speed_level):
		PlayerScript.permanent_speed_bonus += upgrade_effects["movement_speed"][i]
	
	# Apply Weapon Damage Min
	var BulletScript = load("res://scripts/bullet.gd")
	var Bullet2Script = load("res://scripts/bullet_2.gd")
	var SniperBulletScript = load("res://scripts/sniper_1_bullet.gd")
	var RocketAmmoScript = load("res://scripts/rocket_ammo.gd")
	var ShotgunBulletScript = load("res://scripts/shotgun_bullet.gd")
	
	BulletScript.permanent_min_damage_bonus = 0
	Bullet2Script.permanent_min_damage_bonus = 0
	SniperBulletScript.permanent_min_damage_bonus = 0
	RocketAmmoScript.permanent_min_damage_bonus = 0
	ShotgunBulletScript.permanent_min_damage_bonus = 0
	
	for i in range(min_weapon_damage_level):
		var bonus = upgrade_effects["min_weapon_damage"][i]
		BulletScript.permanent_min_damage_bonus += bonus
		Bullet2Script.permanent_min_damage_bonus += bonus
		SniperBulletScript.permanent_min_damage_bonus += bonus
		RocketAmmoScript.permanent_min_damage_bonus += bonus
		ShotgunBulletScript.permanent_min_damage_bonus += bonus
	
	# Apply Weapon Damage Max
	BulletScript.permanent_max_damage_bonus = 0
	Bullet2Script.permanent_max_damage_bonus = 0
	SniperBulletScript.permanent_max_damage_bonus = 0
	RocketAmmoScript.permanent_max_damage_bonus = 0
	ShotgunBulletScript.permanent_max_damage_bonus = 0
	
	for i in range(max_weapon_damage_level):
		var bonus = upgrade_effects["max_weapon_damage"][i]
		BulletScript.permanent_max_damage_bonus += bonus
		Bullet2Script.permanent_max_damage_bonus += bonus
		SniperBulletScript.permanent_max_damage_bonus += bonus
		RocketAmmoScript.permanent_max_damage_bonus += bonus
		ShotgunBulletScript.permanent_max_damage_bonus += bonus
	
	# Apply Ability Damage Min
	var ShockwaveScript = load("res://scripts/shockwave.gd")
	var FireBlinkScript = load("res://scripts/fire_blink.gd")
	var GravityWellScript = load("res://scripts/gravity_well.gd")
	var OrbitalAbilityScript = load("res://scripts/orbital_ability.gd")
	
	ShockwaveScript.permanent_min_damage_bonus = 0
	FireBlinkScript.permanent_min_damage_bonus = 0
	GravityWellScript.permanent_min_damage_bonus = 0
	OrbitalAbilityScript.permanent_min_damage_bonus = 0
	
	for i in range(min_ability_damage_level):
		var bonus = upgrade_effects["min_ability_damage"][i]
		ShockwaveScript.permanent_min_damage_bonus += bonus
		FireBlinkScript.permanent_min_damage_bonus += bonus
		GravityWellScript.permanent_min_damage_bonus += bonus
		OrbitalAbilityScript.permanent_min_damage_bonus += bonus
	
	# Apply Ability Damage Max
	ShockwaveScript.permanent_max_damage_bonus = 0
	FireBlinkScript.permanent_max_damage_bonus = 0
	GravityWellScript.permanent_max_damage_bonus = 0
	OrbitalAbilityScript.permanent_max_damage_bonus = 0
	
	for i in range(max_ability_damage_level):
		var bonus = upgrade_effects["max_ability_damage"][i]
		ShockwaveScript.permanent_max_damage_bonus += bonus
		FireBlinkScript.permanent_max_damage_bonus += bonus
		GravityWellScript.permanent_max_damage_bonus += bonus
		OrbitalAbilityScript.permanent_max_damage_bonus += bonus
	
	# Apply Revive
	PlayerScript.has_revive = (revive_level > 0)
	
	# Apply Mana Regeneration
	PlayerScript.mana_regen_rate = 0
	for i in range(mana_regeneration_level):
		PlayerScript.mana_regen_rate += upgrade_effects["mana_regeneration"][i]
	
	# Apply HP Regeneration
	PlayerScript.hp_regen_rate = 0
	for i in range(hp_regeneration_level):
		PlayerScript.hp_regen_rate += upgrade_effects["hp_regeneration"][i]
	
	# Apply Armor
	PlayerScript.armor = 0
	for i in range(armor_level):
		PlayerScript.armor += upgrade_effects["armor"][i]
	
	# Apply XP Bonus
	var ExperienceManagerScript = load("res://scripts/experience_manager.gd")
	var xp_bonus_for_script = 1.0
	ExperienceManagerScript.change_xp_bonus(xp_bonus_for_script)
	for i in range(xp_bonus_level):
		xp_bonus_for_script += upgrade_effects["xp_bonus"][i]
	ExperienceManagerScript.change_xp_bonus(xp_bonus_for_script)
	
	# Apply Gold Bonus
	var UIScript = load("res://scripts/ui.gd")
	var gold_bonus_for_script = 1.0
	UIScript.change_gold_bonus(gold_bonus_for_script)
	for i in range(gold_bonus_level):
		gold_bonus_for_script += upgrade_effects["gold_bonus"][i]
	UIScript.change_gold_bonus(gold_bonus_for_script)
	
	# Apply Magnet
	var CoinScript = load("res://scripts/coin.gd")
	var FiveCoinScript = load("res://scripts/5_coin.gd")
	var TwentyFiveCoinScript = load("res://scripts/25_coin.gd")
	var HeartPickupScript = load("res://scripts/heart_pickup.gd")
	var ManaBallScript = load("res://scripts/mana_ball.gd")
	var DiamondScript = load("res://scripts/diamond.gd")
	
	CoinScript.permanent_pickup_range_bonus = 0
	FiveCoinScript.permanent_pickup_range_bonus = 0
	TwentyFiveCoinScript.permanent_pickup_range_bonus = 0
	HeartPickupScript.permanent_pickup_range_bonus = 0
	ManaBallScript.permanent_pickup_range_bonus = 0
	DiamondScript.permanent_pickup_range_bonus = 0
	
	for i in range(magnet_level):
		var bonus = upgrade_effects["magnet"][i]
		CoinScript.permanent_pickup_range_bonus += bonus
		FiveCoinScript.permanent_pickup_range_bonus += bonus
		TwentyFiveCoinScript.permanent_pickup_range_bonus += bonus
		HeartPickupScript.permanent_pickup_range_bonus += bonus
		ManaBallScript.permanent_pickup_range_bonus += bonus
		DiamondScript.permanent_pickup_range_bonus += bonus
	
	# LUCK HERE


func get_gems() -> int:
	return gem_total


func add_gems(amount: int) -> void:
	gem_total += amount
	save_game()
	print("Added " + str(amount) + " gems. New total: " + str(gem_total))


func spend_gems(amount: int) -> bool:
	if gem_total >= amount:
		gem_total -= amount
		save_game()
		print("Spent " + str(amount) + " gems. Remaining: " + str(gem_total))
		return true
	else:
		print("Not enough gems! Needed: " + str(amount) + ", Have: " + str(gem_total))
		return false


func get_upgrade_level(upgrade_name: String) -> int:
	match upgrade_name:
		"base_health": return base_health_level
		"base_mana": return base_mana_level
		"movement_speed": return movement_speed_level
		"min_weapon_damage": return min_weapon_damage_level
		"max_weapon_damage": return max_weapon_damage_level
		"min_ability_damage": return min_ability_damage_level
		"max_ability_damage": return max_ability_damage_level
		"luck": return luck_level
		"revive": return revive_level
		"mana_regeneration": return mana_regeneration_level
		"hp_regeneration": return hp_regeneration_level
		"armor": return armor_level
		"xp_bonus": return xp_bonus_level
		"gold_bonus": return gold_bonus_level
		"magnet": return magnet_level
		_: 
			print("Warning: Unknown upgrade name: " + upgrade_name)
			return 0

func get_difficulty(difficulty: String):
	match difficulty:
		"heroic": return unlocked_heroic
		"legendary": return unlocked_legendary

func save_difficulty(difficulty_name: String, unlocked: bool) -> void:
	match difficulty_name:
		"heroic": unlocked_heroic = unlocked
		"legendary": unlocked_legendary = unlocked


func save_upgrade_level(upgrade_name: String, level: int) -> void:
	match upgrade_name:
		"base_health": base_health_level = level
		"base_mana": base_mana_level = level
		"movement_speed": movement_speed_level = level
		"min_weapon_damage": min_weapon_damage_level = level
		"max_weapon_damage": max_weapon_damage_level = level
		"min_ability_damage": min_ability_damage_level = level
		"max_ability_damage": max_ability_damage_level = level
		"luck": luck_level = level
		"revive": revive_level = level
		"mana_regeneration": mana_regeneration_level = level
		"hp_regeneration": hp_regeneration_level = level
		"armor": armor_level = level
		"xp_bonus": xp_bonus_level = level
		"gold_bonus": gold_bonus_level = level
		"magnet": magnet_level = level
		_: print("Warning: Unknown upgrade name: " + upgrade_name)
	
	save_game()


func reset_all_data() -> void:
	base_health_level = 0
	base_mana_level = 0
	movement_speed_level = 0
	min_weapon_damage_level = 0
	max_weapon_damage_level = 0
	min_ability_damage_level = 0
	max_ability_damage_level = 0
	luck_level = 0
	revive_level = 0
	mana_regeneration_level = 0
	hp_regeneration_level = 0
	armor_level = 0
	xp_bonus_level = 0
	gold_bonus_level = 0
	magnet_level = 0
	gem_total = 0
	
	save_game()
	apply_all_saved_upgrades()
	print("All save data has been reset!")
