extends MarginContainer


@onready var next_weapon_up: TextureRect = $VBoxContainer/NextWeaponUp
@onready var current_weapon: TextureRect = $VBoxContainer/CurrentWeapon
@onready var next_weapon_down: TextureRect = $VBoxContainer/NextWeaponDown

var gun1_texture: Texture
var gun2_texture: Texture
var sniper_texture: Texture
var rocket_launcher_texture: Texture

var player = null

func _ready():
	gun1_texture = preload("res://assets/adjusted guns/pistolWeaponHUD.png")
	gun2_texture = preload("res://assets/adjusted guns/Gun2WeaponHUD.png")
	sniper_texture = preload("res://assets/adjusted guns/sniperWeaponHUD.png")
	rocket_launcher_texture = preload("res://assets/adjusted guns/RocketLauncherWeaponHUD.png")
	
	player = get_node("/root/world/player")
	
	if player:
		update_weapon_display()
	else:
		print("ERROR: Player not found")

func update_weapon_display():
	if not player:
		return
		
	var owned_weapons: Array = []
	if player.owns_gun1:
		owned_weapons.append("gun1")
	if player.owns_gun2:
		owned_weapons.append("gun2")
	if player.owns_sniper1:
		owned_weapons.append("sniper1")
	if player.owns_rocketlauncher:
		owned_weapons.append("rocketlauncher")
		
	var current_index: int = -1
	if player.equip_gun1:
		current_index = owned_weapons.find("gun1")
	elif player.equip_gun2:
		current_index = owned_weapons.find("gun2")
	elif player.equip_sniper1:
		current_index = owned_weapons.find("sniper1")
	elif player.equip_rocketlauncher:
		current_index = owned_weapons.find("rocketlauncher")
	

	if current_index != -1:
		current_weapon.texture = get_weapon_texture(owned_weapons[current_index])
		
		var up_index: int = (current_index - 1)
		if up_index < 0:
			up_index = owned_weapons.size() - 1
		
		var down_index: int = (current_index + 1) % owned_weapons.size()
		
		next_weapon_up.texture = get_weapon_texture(owned_weapons[up_index])
		next_weapon_down.texture = get_weapon_texture(owned_weapons[down_index])
	
	if owned_weapons.size() <= 1:
		next_weapon_up.visible = false
		next_weapon_down.visible = false
	else:
		next_weapon_up.visible = true
		next_weapon_down.visible = true

func get_weapon_texture(weapon_name):
	match weapon_name:
		"gun1":
			return gun1_texture
		"gun2":
			return gun2_texture
		"sniper1":
			return sniper_texture
		"rocketlauncher":
			return rocket_launcher_texture
	return null
