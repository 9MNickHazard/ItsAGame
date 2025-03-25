extends CanvasLayer

@onready var gems_label: Label = $MarginContainer/PanelContainer/MainVbox/TopRow/MarginContainer/HBoxContainer/GemsLabel
@onready var save_manager = get_node("/root/SaveManager")
@onready var back_button: Button = $MarginContainer/PanelContainer/MainVbox/TopRow/MarginContainer/HBoxContainer/BackButton
@onready var base_health_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseHealth/VBoxContainer/CenterContainer2/BaseHealthButton
@onready var base_mana_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseMana/VBoxContainer/CenterContainer2/BaseManaButton
@onready var move_speed_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/MoveSpeed/VBoxContainer/CenterContainer2/MoveSpeedButton
@onready var wep_min_dmg_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMinDmg/VBoxContainer/CenterContainer2/WepMinDmgButton
@onready var wep_max_dmg_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMaxDmg/VBoxContainer/CenterContainer2/WepMaxDmgButton
@onready var abl_min_dmg_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMinDmg/VBoxContainer/CenterContainer2/AblMinDmgButton
@onready var abl_max_dmg_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMaxDmg/VBoxContainer/CenterContainer2/AblMaxDmgButton
@onready var luck_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Luck/VBoxContainer/CenterContainer2/LuckButton
@onready var revive_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Revive/VBoxContainer/CenterContainer2/ReviveButton
@onready var hp_regen_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/HpRegen/VBoxContainer/CenterContainer2/HpRegenButton
@onready var mana_regen_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/ManaRegen/VBoxContainer/CenterContainer2/ManaRegenButton
@onready var armor_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Armor/VBoxContainer/CenterContainer2/ArmorButton
@onready var xp_bonus_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/XpBonus/VBoxContainer/CenterContainer2/XpBonusButton
@onready var gold_bonus_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/GoldBonus/VBoxContainer/CenterContainer2/GoldBonusButton
@onready var magnet_button: Button = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Magnet/VBoxContainer/CenterContainer2/MagnetButton

@onready var base_health_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseHealth/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/BaseHealthCheckedPip1
@onready var base_health_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseHealth/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/BaseHealthCheckedPip2
@onready var base_health_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseHealth/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/BaseHealthCheckedPip3
@onready var base_health_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseHealth/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/BaseHealthCheckedPip4
@onready var base_mana_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseMana/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/BaseManaCheckedPip1
@onready var base_mana_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseMana/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/BaseManaCheckedPip2
@onready var base_mana_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseMana/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/BaseManaCheckedPip3
@onready var base_mana_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/BaseMana/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/BaseManaCheckedPip4
@onready var move_speed_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/MoveSpeed/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/MoveSpeedCheckedPip1
@onready var move_speed_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/MoveSpeed/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/MoveSpeedCheckedPip2
@onready var move_speed_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/MoveSpeed/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/MoveSpeedCheckedPip3
@onready var move_speed_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/MoveSpeed/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/MoveSpeedCheckedPip4
@onready var move_speed_checked_pip_5: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/MoveSpeed/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer5/MoveSpeedCheckedPip5
@onready var wep_min_dmg_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/WepMinDmgCheckedPip1
@onready var wep_min_dmg_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/WepMinDmgCheckedPip2
@onready var wep_min_dmg_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/WepMinDmgCheckedPip3
@onready var wep_min_dmg_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/WepMinDmgCheckedPip4
@onready var wep_min_dmg_checked_pip_5: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer5/WepMinDmgCheckedPip5
@onready var wep_max_dmg_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/WepMaxDmgCheckedPip1
@onready var wep_max_dmg_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/WepMaxDmgCheckedPip2
@onready var wep_max_dmg_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/WepMaxDmgCheckedPip3
@onready var wep_max_dmg_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/WepMaxDmgCheckedPip4
@onready var wep_max_dmg_checked_pip_5: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/WepMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer5/WepMaxDmgCheckedPip5
@onready var abl_min_dmg_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/AblMinDmgCheckedPip1
@onready var abl_min_dmg_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/AblMinDmgCheckedPip2
@onready var abl_min_dmg_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/AblMinDmgCheckedPip3
@onready var abl_min_dmg_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMinDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/AblMinDmgCheckedPip4
@onready var abl_max_dmg_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/AblMaxDmgCheckedPip1
@onready var abl_max_dmg_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/AblMaxDmgCheckedPip2
@onready var abl_max_dmg_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/AblMaxDmgCheckedPip3
@onready var abl_max_dmg_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/AblMaxDmg/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/AblMaxDmgCheckedPip4
@onready var luck_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Luck/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/LuckCheckedPip1
@onready var luck_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Luck/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/LuckCheckedPip2
@onready var luck_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Luck/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/LuckCheckedPip3
@onready var revive_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Revive/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/ReviveCheckedPip1
@onready var hp_regen_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/HpRegen/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/HpRegenCheckedPip1
@onready var hp_regen_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/HpRegen/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/HpRegenCheckedPip2
@onready var hp_regen_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/HpRegen/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/HpRegenCheckedPip3
@onready var mana_regen_check_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/ManaRegen/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/ManaRegenCheckPip1
@onready var mana_regen_check_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/ManaRegen/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/ManaRegenCheckPip2
@onready var mana_regen_check_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/ManaRegen/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/ManaRegenCheckPip3
@onready var armor_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Armor/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/ArmorCheckedPip1
@onready var armor_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Armor/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/ArmorCheckedPip2
@onready var armor_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Armor/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/ArmorCheckedPip3
@onready var armor_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Armor/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/ArmorCheckedPip4
@onready var armor_checked_pip_5: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Armor/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer5/ArmorCheckedPip5
@onready var xp_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/XpBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/XpCheckedPip1
@onready var xp_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/XpBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/XpCheckedPip2
@onready var xp_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/XpBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/XpCheckedPip3
@onready var xp_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/XpBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/XpCheckedPip4
@onready var gold_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/GoldBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/GoldCheckedPip1
@onready var gold_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/GoldBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/GoldCheckedPip2
@onready var gold_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/GoldBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/GoldCheckedPip3
@onready var gold_checked_pip_4: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/GoldBonus/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer4/GoldCheckedPip4
@onready var magnet_checked_pip_1: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Magnet/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer/MagnetCheckedPip1
@onready var magnet_checked_pip_2: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Magnet/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer2/MagnetCheckedPip2
@onready var magnet_checked_pip_3: TextureRect = $MarginContainer/PanelContainer/MainVbox/MainRow/MarginContainer/GridContainer/Magnet/VBoxContainer/CenterContainer/HBoxContainer/MarginContainer3/MagnetCheckedPip3

@onready var not_enough_gems_label: Label = $MarginContainer/PanelContainer/MainVbox/BottomRow/MarginContainer/NotEnoughGemsLabel

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

# Upgrade costs and effects
const UPGRADE_COSTS: Dictionary = {
	"base_health": [150, 300, 550, 1100],
	"base_mana": [165, 375, 625, 1250],
	"movement_speed": [85, 180, 350, 650, 1200],
	"min_weapon_damage": [120, 250, 500, 950, 1800],
	"max_weapon_damage": [150, 300, 600, 1100, 2000],
	"min_ability_damage": [110, 240, 500, 1000],
	"max_ability_damage": [140, 300, 600, 1200],
	"luck": [200, 450, 900],
	"revive": [5000],
	"mana_regeneration": [250, 600, 1300],
	"hp_regeneration": [250, 600, 1300],
	"armor": [250, 525, 1000, 1800, 3200],
	"xp_bonus": [150, 325, 650, 1300],
	"gold_bonus": [180, 400, 800, 1600],
	"magnet": [125, 300, 600]
}

const UPGRADE_EFFECTS: Dictionary = {
	"base_health": [10.0, 15.0, 25.0, 50.0],  #
	"base_mana": [25.0, 25.0, 50.0, 50.0],    #
	"movement_speed": [15.0, 15.0, 15.0, 25.0, 40.0],  #
	"min_weapon_damage": [1, 1, 1, 2, 3],  #
	"max_weapon_damage": [2, 2, 2, 3, 5],  #
	"min_ability_damage": [1, 2, 3, 5],  #
	"max_ability_damage": [2, 3, 5, 8],  #
	"luck": [5, 5, 5],  #
	"revive": [1],  # enables revive w/ 50% hp once a run
	"mana_regeneration": [0.5, 0.5, 0.5],  #
	"hp_regeneration": [0.2, 0.2, 0.2],  #
	"armor": [1, 1, 1, 1, 2],  #
	"xp_bonus": [0.05, 0.08, 0.12, 0.20],  #
	"gold_bonus": [.10, .15, .25, .4],  #
	"magnet": [50.0, 100.0, 150.0]  #
}

func _ready() -> void:
	not_enough_gems_label.hide()
	
	if save_manager:
		base_health_level = save_manager.get_upgrade_level("base_health")
		base_mana_level = save_manager.get_upgrade_level("base_mana")
		movement_speed_level = save_manager.get_upgrade_level("movement_speed")
		min_weapon_damage_level = save_manager.get_upgrade_level("min_weapon_damage")
		max_weapon_damage_level = save_manager.get_upgrade_level("max_weapon_damage")
		min_ability_damage_level = save_manager.get_upgrade_level("min_ability_damage")
		max_ability_damage_level = save_manager.get_upgrade_level("max_ability_damage")
		luck_level = save_manager.get_upgrade_level("luck")
		revive_level = save_manager.get_upgrade_level("revive")
		mana_regeneration_level = save_manager.get_upgrade_level("mana_regeneration")
		hp_regeneration_level = save_manager.get_upgrade_level("hp_regeneration")
		armor_level = save_manager.get_upgrade_level("armor")
		xp_bonus_level = save_manager.get_upgrade_level("xp_bonus")
		gold_bonus_level = save_manager.get_upgrade_level("gold_bonus")
		magnet_level = save_manager.get_upgrade_level("magnet")
	
	update_base_health_pips()
	update_base_mana_pips()
	update_movement_speed_pips()
	update_min_weapon_damage_pips()
	update_max_weapon_damage_pips()
	update_min_ability_damage_pips()
	update_max_ability_damage_pips()
	# LUCK HERE
	update_revive_pips()
	update_hp_regen_pips()
	update_mana_regen_pips()
	update_armor_pips()
	update_xp_bonus_pips()
	update_gold_bonus_pips()
	update_magnet_pips()
	
	gems_label.text = "Gems: " + str(save_manager.get_gems())

	update_button_texts()

func disable_enable_buttons(disabled: bool = true):
	if disabled:
		back_button.disabled = true
		base_health_button.disabled = true
		base_mana_button.disabled = true
		move_speed_button.disabled = true
		wep_min_dmg_button.disabled = true
		wep_max_dmg_button.disabled = true
		abl_min_dmg_button.disabled = true
		abl_max_dmg_button.disabled = true
		luck_button.disabled = true
		revive_button.disabled = true
		hp_regen_button.disabled = true
		mana_regen_button.disabled = true
		armor_button.disabled = true
		xp_bonus_button.disabled = true
		gold_bonus_button.disabled = true
		magnet_button.disabled = true
	else:
		back_button.disabled = false
		base_health_button.disabled = false
		base_mana_button.disabled = false
		move_speed_button.disabled = false
		wep_min_dmg_button.disabled = false
		wep_max_dmg_button.disabled = false
		abl_min_dmg_button.disabled = false
		abl_max_dmg_button.disabled = false
		luck_button.disabled = false
		revive_button.disabled = false
		hp_regen_button.disabled = false
		mana_regen_button.disabled = false
		armor_button.disabled = false
		xp_bonus_button.disabled = false
		gold_bonus_button.disabled = false
		magnet_button.disabled = false

func _on_base_health_button_pressed() -> void:
	if base_health_level >= UPGRADE_COSTS["base_health"].size():
		return
	
	var cost = UPGRADE_COSTS["base_health"][base_health_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var health_boost = UPGRADE_EFFECTS["base_health"][base_health_level]
		var PlayerScript = load("res://scripts/player.gd")
		PlayerScript.permanent_health_bonus += health_boost
		
		base_health_level += 1
		update_base_health_pips()
		
		save_manager.save_upgrade_level("base_health", base_health_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_base_health_pips() -> void:
	base_health_checked_pip_1.visible = base_health_level >= 1
	base_health_checked_pip_2.visible = base_health_level >= 2
	base_health_checked_pip_3.visible = base_health_level >= 3
	base_health_checked_pip_4.visible = base_health_level >= 4

func _on_base_mana_button_pressed() -> void:
	if base_mana_level >= UPGRADE_COSTS["base_mana"].size():
		return
	
	var cost = UPGRADE_COSTS["base_mana"][base_mana_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var mana_boost = UPGRADE_EFFECTS["base_mana"][base_mana_level]
		var PlayerScript = load("res://scripts/player.gd")
		PlayerScript.permanent_mana_bonus += mana_boost
		
		base_mana_level += 1
		update_base_mana_pips()
		
		save_manager.save_upgrade_level("base_mana", base_mana_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_base_mana_pips() -> void:
	base_mana_checked_pip_1.visible = base_mana_level >= 1
	base_mana_checked_pip_2.visible = base_mana_level >= 2
	base_mana_checked_pip_3.visible = base_mana_level >= 3
	base_mana_checked_pip_4.visible = base_mana_level >= 4

func _on_move_speed_button_pressed() -> void:
	if movement_speed_level >= UPGRADE_COSTS["movement_speed"].size():
		return
	
	var cost = UPGRADE_COSTS["movement_speed"][movement_speed_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var speed_boost = UPGRADE_EFFECTS["movement_speed"][movement_speed_level]
		var PlayerScript = load("res://scripts/player.gd")
		PlayerScript.permanent_speed_bonus += speed_boost
		
		movement_speed_level += 1
		update_movement_speed_pips()
		
		save_manager.save_upgrade_level("movement_speed", movement_speed_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_movement_speed_pips() -> void:
	move_speed_checked_pip_1.visible = movement_speed_level >= 1
	move_speed_checked_pip_2.visible = movement_speed_level >= 2
	move_speed_checked_pip_3.visible = movement_speed_level >= 3
	move_speed_checked_pip_4.visible = movement_speed_level >= 4
	move_speed_checked_pip_5.visible = movement_speed_level >= 5

func _on_wep_min_dmg_button_pressed() -> void:
	if min_weapon_damage_level >= UPGRADE_COSTS["min_weapon_damage"].size():
		return
	
	var cost = UPGRADE_COSTS["min_weapon_damage"][min_weapon_damage_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var damage_boost = UPGRADE_EFFECTS["min_weapon_damage"][min_weapon_damage_level]
		
		var BulletScript = load("res://scripts/bullet.gd")
		var Bullet2Script = load("res://scripts/bullet_2.gd")
		var SniperBulletScript = load("res://scripts/sniper_1_bullet.gd")
		var RocketAmmoScript = load("res://scripts/rocket_ammo.gd")
		var ShotgunBulletScript = load("res://scripts/shotgun_bullet.gd")
		
		BulletScript.permanent_min_damage_bonus += damage_boost
		Bullet2Script.permanent_min_damage_bonus += damage_boost
		SniperBulletScript.permanent_min_damage_bonus += damage_boost
		RocketAmmoScript.permanent_min_damage_bonus += damage_boost
		ShotgunBulletScript.permanent_min_damage_bonus += damage_boost
		
		min_weapon_damage_level += 1
		update_min_weapon_damage_pips()
		
		save_manager.save_upgrade_level("min_weapon_damage", min_weapon_damage_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_min_weapon_damage_pips() -> void:
	wep_min_dmg_checked_pip_1.visible = min_weapon_damage_level >= 1
	wep_min_dmg_checked_pip_2.visible = min_weapon_damage_level >= 2
	wep_min_dmg_checked_pip_3.visible = min_weapon_damage_level >= 3
	wep_min_dmg_checked_pip_4.visible = min_weapon_damage_level >= 4
	wep_min_dmg_checked_pip_5.visible = min_weapon_damage_level >= 5

func _on_wep_max_dmg_button_pressed() -> void:
	if max_weapon_damage_level >= UPGRADE_COSTS["max_weapon_damage"].size():
		return
	
	var cost = UPGRADE_COSTS["max_weapon_damage"][max_weapon_damage_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var damage_boost = UPGRADE_EFFECTS["max_weapon_damage"][max_weapon_damage_level]
		
		var BulletScript = load("res://scripts/bullet.gd")
		var Bullet2Script = load("res://scripts/bullet_2.gd")
		var SniperBulletScript = load("res://scripts/sniper_1_bullet.gd")
		var RocketAmmoScript = load("res://scripts/rocket_ammo.gd")
		var ShotgunBulletScript = load("res://scripts/shotgun_bullet.gd")
		
		BulletScript.permanent_max_damage_bonus += damage_boost
		Bullet2Script.permanent_max_damage_bonus += damage_boost
		SniperBulletScript.permanent_max_damage_bonus += damage_boost
		RocketAmmoScript.permanent_max_damage_bonus += damage_boost
		ShotgunBulletScript.permanent_max_damage_bonus += damage_boost
		
		max_weapon_damage_level += 1
		update_max_weapon_damage_pips()
		
		save_manager.save_upgrade_level("max_weapon_damage", max_weapon_damage_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_max_weapon_damage_pips() -> void:
	wep_max_dmg_checked_pip_1.visible = max_weapon_damage_level >= 1
	wep_max_dmg_checked_pip_2.visible = max_weapon_damage_level >= 2
	wep_max_dmg_checked_pip_3.visible = max_weapon_damage_level >= 3
	wep_max_dmg_checked_pip_4.visible = max_weapon_damage_level >= 4
	wep_max_dmg_checked_pip_5.visible = max_weapon_damage_level >= 5

func _on_abl_min_dmg_button_pressed() -> void:
	if min_ability_damage_level >= UPGRADE_COSTS["min_ability_damage"].size():
		return
	
	var cost = UPGRADE_COSTS["min_ability_damage"][min_ability_damage_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var damage_boost = UPGRADE_EFFECTS["min_ability_damage"][min_ability_damage_level]
		
		var ShockwaveScript = load("res://scripts/shockwave.gd")
		var FireBlinkScript = load("res://scripts/fire_blink.gd")
		var GravityWellScript = load("res://scripts/gravity_well.gd")
		var OrbitalAbilityScript = load("res://scripts/orbital_ability.gd")
		
		ShockwaveScript.permanent_min_damage_bonus += damage_boost
		FireBlinkScript.permanent_min_damage_bonus += damage_boost
		GravityWellScript.permanent_min_damage_bonus += damage_boost
		OrbitalAbilityScript.permanent_min_damage_bonus += damage_boost
		
		min_ability_damage_level += 1
		update_min_ability_damage_pips()
		
		save_manager.save_upgrade_level("min_ability_damage", min_ability_damage_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_min_ability_damage_pips() -> void:
	abl_min_dmg_checked_pip_1.visible = min_ability_damage_level >= 1
	abl_min_dmg_checked_pip_2.visible = min_ability_damage_level >= 2
	abl_min_dmg_checked_pip_3.visible = min_ability_damage_level >= 3
	abl_min_dmg_checked_pip_4.visible = min_ability_damage_level >= 4

func _on_abl_max_dmg_button_pressed() -> void:
	if max_ability_damage_level >= UPGRADE_COSTS["max_ability_damage"].size():
		return
	
	var cost = UPGRADE_COSTS["max_ability_damage"][max_ability_damage_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var damage_boost = UPGRADE_EFFECTS["max_ability_damage"][max_ability_damage_level]
		
		var ShockwaveScript = load("res://scripts/shockwave.gd")
		var FireBlinkScript = load("res://scripts/fire_blink.gd")
		var GravityWellScript = load("res://scripts/gravity_well.gd")
		var OrbitalAbilityScript = load("res://scripts/orbital_ability.gd")
		
		ShockwaveScript.permanent_max_damage_bonus += damage_boost
		FireBlinkScript.permanent_max_damage_bonus += damage_boost
		GravityWellScript.permanent_max_damage_bonus += damage_boost
		OrbitalAbilityScript.permanent_max_damage_bonus += damage_boost
		
		max_ability_damage_level += 1
		update_max_ability_damage_pips()
		
		save_manager.save_upgrade_level("max_ability_damage", max_ability_damage_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_max_ability_damage_pips() -> void:
	abl_max_dmg_checked_pip_1.visible = max_ability_damage_level >= 1
	abl_max_dmg_checked_pip_2.visible = max_ability_damage_level >= 2
	abl_max_dmg_checked_pip_3.visible = max_ability_damage_level >= 3
	abl_max_dmg_checked_pip_4.visible = max_ability_damage_level >= 4

func _on_luck_button_pressed() -> void:
	# Ignoring for now
	pass

func _on_revive_button_pressed() -> void:
	if revive_level >= UPGRADE_COSTS["revive"].size():
		return
	
	var cost = UPGRADE_COSTS["revive"][revive_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var PlayerScript = load("res://scripts/player.gd")
		PlayerScript.has_revive = true
		
		revive_level += 1
		update_revive_pips()
		
		save_manager.save_upgrade_level("revive", revive_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_revive_pips() -> void:
	revive_checked_pip_1.visible = revive_level >= 1

func _on_hp_regen_button_pressed() -> void:
	if hp_regeneration_level >= UPGRADE_COSTS["hp_regeneration"].size():
		return
	
	var cost = UPGRADE_COSTS["hp_regeneration"][hp_regeneration_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var regen_boost = UPGRADE_EFFECTS["hp_regeneration"][hp_regeneration_level]
		var PlayerScript = load("res://scripts/player.gd")
		PlayerScript.hp_regen_rate += regen_boost
		
		hp_regeneration_level += 1
		update_hp_regen_pips()
		
		save_manager.save_upgrade_level("hp_regeneration", hp_regeneration_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_hp_regen_pips() -> void:
	hp_regen_checked_pip_1.visible = hp_regeneration_level >= 1
	hp_regen_checked_pip_2.visible = hp_regeneration_level >= 2
	hp_regen_checked_pip_3.visible = hp_regeneration_level >= 3

func _on_mana_regen_button_pressed() -> void:
	if mana_regeneration_level >= UPGRADE_COSTS["mana_regeneration"].size():
		return
	
	var cost = UPGRADE_COSTS["mana_regeneration"][mana_regeneration_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var regen_boost = UPGRADE_EFFECTS["mana_regeneration"][mana_regeneration_level]
		var PlayerScript = load("res://scripts/player.gd")
		PlayerScript.mana_regen_rate += regen_boost
		
		mana_regeneration_level += 1
		update_mana_regen_pips()
		
		save_manager.save_upgrade_level("mana_regeneration", mana_regeneration_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_mana_regen_pips() -> void:
	mana_regen_check_pip_1.visible = mana_regeneration_level >= 1
	mana_regen_check_pip_2.visible = mana_regeneration_level >= 2
	mana_regen_check_pip_3.visible = mana_regeneration_level >= 3

func _on_armor_button_pressed() -> void:
	if armor_level >= UPGRADE_COSTS["armor"].size():
		return
	
	var cost = UPGRADE_COSTS["armor"][armor_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var armor_boost = UPGRADE_EFFECTS["armor"][armor_level]
		var PlayerScript = load("res://scripts/player.gd")
		PlayerScript.armor += armor_boost
		
		armor_level += 1
		update_armor_pips()
		
		save_manager.save_upgrade_level("armor", armor_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_armor_pips() -> void:
	armor_checked_pip_1.visible = armor_level >= 1
	armor_checked_pip_2.visible = armor_level >= 2
	armor_checked_pip_3.visible = armor_level >= 3
	armor_checked_pip_4.visible = armor_level >= 4
	armor_checked_pip_5.visible = armor_level >= 5

func _on_xp_bonus_button_pressed() -> void:
	if xp_bonus_level >= UPGRADE_COSTS["xp_bonus"].size():
		return
	
	var cost = UPGRADE_COSTS["xp_bonus"][xp_bonus_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var xp_boost = UPGRADE_EFFECTS["xp_bonus"][xp_bonus_level]
		var ExperienceManagerScript = load("res://scripts/experience_manager.gd")
		ExperienceManagerScript.xp_bonus_percent += xp_boost
		
		xp_bonus_level += 1
		update_xp_bonus_pips()
		
		save_manager.save_upgrade_level("xp_bonus", xp_bonus_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_xp_bonus_pips() -> void:
	xp_checked_pip_1.visible = xp_bonus_level >= 1
	xp_checked_pip_2.visible = xp_bonus_level >= 2
	xp_checked_pip_3.visible = xp_bonus_level >= 3
	xp_checked_pip_4.visible = xp_bonus_level >= 4

func _on_gold_bonus_button_pressed() -> void:
	if gold_bonus_level >= UPGRADE_COSTS["gold_bonus"].size():
		return
	
	var cost = UPGRADE_COSTS["gold_bonus"][gold_bonus_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var gold_boost = UPGRADE_EFFECTS["gold_bonus"][gold_bonus_level]
		var UIScript = load("res://scripts/ui.gd")
		UIScript.gold_bonus_percent += gold_boost
		
		gold_bonus_level += 1
		update_gold_bonus_pips()
		
		save_manager.save_upgrade_level("gold_bonus", gold_bonus_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_gold_bonus_pips() -> void:
	gold_checked_pip_1.visible = gold_bonus_level >= 1
	gold_checked_pip_2.visible = gold_bonus_level >= 2
	gold_checked_pip_3.visible = gold_bonus_level >= 3
	gold_checked_pip_4.visible = gold_bonus_level >= 4

func _on_magnet_button_pressed() -> void:
	if magnet_level >= UPGRADE_COSTS["magnet"].size():
		return
	
	var cost = UPGRADE_COSTS["magnet"][magnet_level]
	var gems = save_manager.get_gems()
	
	if gems >= cost:
		save_manager.spend_gems(cost)
		gems_label.text = "Gems: " + str(save_manager.get_gems())
		
		var magnet_boost = UPGRADE_EFFECTS["magnet"][magnet_level]
		
		var CoinScript = load("res://scripts/coin.gd")
		var FiveCoinScript = load("res://scripts/5_coin.gd")
		var TwentyFiveCoinScript = load("res://scripts/25_coin.gd")
		var HeartPickupScript = load("res://scripts/heart_pickup.gd")
		var ManaBallScript = load("res://scripts/mana_ball.gd")
		var DiamondScript = load("res://scripts/diamond.gd")
		
		CoinScript.permanent_pickup_range_bonus += magnet_boost
		FiveCoinScript.permanent_pickup_range_bonus += magnet_boost
		TwentyFiveCoinScript.permanent_pickup_range_bonus += magnet_boost
		HeartPickupScript.permanent_pickup_range_bonus += magnet_boost
		ManaBallScript.permanent_pickup_range_bonus += magnet_boost
		DiamondScript.permanent_pickup_range_bonus += magnet_boost
		
		magnet_level += 1
		update_magnet_pips()
		
		save_manager.save_upgrade_level("magnet", magnet_level)
		
		update_button_texts()
	else:
		disable_enable_buttons()
		
		not_enough_gems_label.show()
		await get_tree().create_timer(1.2).timeout
		not_enough_gems_label.hide()
		
		disable_enable_buttons(false)

func update_magnet_pips() -> void:
	magnet_checked_pip_1.visible = magnet_level >= 1
	magnet_checked_pip_2.visible = magnet_level >= 2
	magnet_checked_pip_3.visible = magnet_level >= 3


func update_button_texts() -> void:
	# Base Health
	if base_health_level < UPGRADE_COSTS["base_health"].size():
		base_health_button.text = "Upgrade: " + str(UPGRADE_COSTS["base_health"][base_health_level])
		base_health_button.disabled = false
	else:
		base_health_button.text = "MAXED"
		base_health_button.disabled = true
	
	# Base Mana
	if base_mana_level < UPGRADE_COSTS["base_mana"].size():
		base_mana_button.text = "Upgrade: " + str(UPGRADE_COSTS["base_mana"][base_mana_level])
		base_mana_button.disabled = false
	else:
		base_mana_button.text = "MAXED"
		base_mana_button.disabled = true
	
	# Movement Speed
	if movement_speed_level < UPGRADE_COSTS["movement_speed"].size():
		move_speed_button.text = "Upgrade: " + str(UPGRADE_COSTS["movement_speed"][movement_speed_level])
		move_speed_button.disabled = false
	else:
		move_speed_button.text = "MAXED"
		move_speed_button.disabled = true
	
	# Weapon Min Damage
	if min_weapon_damage_level < UPGRADE_COSTS["min_weapon_damage"].size():
		wep_min_dmg_button.text = "Upgrade: " + str(UPGRADE_COSTS["min_weapon_damage"][min_weapon_damage_level])
		wep_min_dmg_button.disabled = false
	else:
		wep_min_dmg_button.text = "MAXED"
		wep_min_dmg_button.disabled = true
	
	# Weapon Max Damage
	if max_weapon_damage_level < UPGRADE_COSTS["max_weapon_damage"].size():
		wep_max_dmg_button.text = "Upgrade: " + str(UPGRADE_COSTS["max_weapon_damage"][max_weapon_damage_level])
		wep_max_dmg_button.disabled = false
	else:
		wep_max_dmg_button.text = "MAXED"
		wep_max_dmg_button.disabled = true
	
	# Ability Min Damage
	if min_ability_damage_level < UPGRADE_COSTS["min_ability_damage"].size():
		abl_min_dmg_button.text = "Upgrade: " + str(UPGRADE_COSTS["min_ability_damage"][min_ability_damage_level])
		abl_min_dmg_button.disabled = false
	else:
		abl_min_dmg_button.text = "MAXED"
		abl_min_dmg_button.disabled = true
	
	# Ability Max Damage
	if max_ability_damage_level < UPGRADE_COSTS["max_ability_damage"].size():
		abl_max_dmg_button.text = "Upgrade: " + str(UPGRADE_COSTS["max_ability_damage"][max_ability_damage_level])
		abl_max_dmg_button.disabled = false
	else:
		abl_max_dmg_button.text = "MAXED"
		abl_max_dmg_button.disabled = true
	
	# Luck
	if luck_level < UPGRADE_COSTS["luck"].size():
		luck_button.text = "Upgrade: " + str(UPGRADE_COSTS["luck"][luck_level])
		luck_button.disabled = false
	else:
		luck_button.text = "MAXED"
		luck_button.disabled = true
	
	# Revive
	if revive_level < UPGRADE_COSTS["revive"].size():
		revive_button.text = "Upgrade: " + str(UPGRADE_COSTS["revive"][revive_level])
		revive_button.disabled = false
	else:
		revive_button.text = "MAXED"
		revive_button.disabled = true
	
	# HP Regeneration
	if hp_regeneration_level < UPGRADE_COSTS["hp_regeneration"].size():
		hp_regen_button.text = "Upgrade: " + str(UPGRADE_COSTS["hp_regeneration"][hp_regeneration_level])
		hp_regen_button.disabled = false
	else:
		hp_regen_button.text = "MAXED"
		hp_regen_button.disabled = true
	
	# Mana Regeneration
	if mana_regeneration_level < UPGRADE_COSTS["mana_regeneration"].size():
		mana_regen_button.text = "Upgrade: " + str(UPGRADE_COSTS["mana_regeneration"][mana_regeneration_level])
		mana_regen_button.disabled = false
	else:
		mana_regen_button.text = "MAXED"
		mana_regen_button.disabled = true
	
	# Armor
	if armor_level < UPGRADE_COSTS["armor"].size():
		armor_button.text = "Upgrade: " + str(UPGRADE_COSTS["armor"][armor_level])
		armor_button.disabled = false
	else:
		armor_button.text = "MAXED"
		armor_button.disabled = true
	
	# XP Bonus
	if xp_bonus_level < UPGRADE_COSTS["xp_bonus"].size():
		xp_bonus_button.text = "Upgrade: " + str(UPGRADE_COSTS["xp_bonus"][xp_bonus_level])
		xp_bonus_button.disabled = false
	else:
		xp_bonus_button.text = "MAXED"
		xp_bonus_button.disabled = true
	
	# Gold Bonus
	if gold_bonus_level < UPGRADE_COSTS["gold_bonus"].size():
		gold_bonus_button.text = "Upgrade: " + str(UPGRADE_COSTS["gold_bonus"][gold_bonus_level])
		gold_bonus_button.disabled = false
	else:
		gold_bonus_button.text = "MAXED"
		gold_bonus_button.disabled = true
	
	# Magnet
	if magnet_level < UPGRADE_COSTS["magnet"].size():
		magnet_button.text = "Upgrade: " + str(UPGRADE_COSTS["magnet"][magnet_level])
		magnet_button.disabled = false
	else:
		magnet_button.text = "MAXED"
		magnet_button.disabled = true

	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
