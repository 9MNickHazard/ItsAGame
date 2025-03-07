extends Node2D

@onready var shooting_point: Marker2D = $"weapon pivot/Pistol/shooting point"
@onready var weapon_pivot: Marker2D = $"weapon pivot"
@onready var doubleshot_gun_sound: AudioStreamPlayer2D = $"doubleshot gun sound"
@onready var stats_manager = get_node("/root/world/StatsManager")

const BULLET2 = preload("res://scenes/bullet_2.tscn")

var can_fire = true
var fire_rate = 0.12
var fire_timer = 0.0
var world

const SPREAD_ANGLE = 0.10

var weapon_name = "Multi-Shot Gun"


func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var direction = global_position.direction_to(mouse_pos)
	
	var angle = direction.angle()
	
	weapon_pivot.rotation = angle
	
	if abs(angle) > PI/2:
		weapon_pivot.scale.y = -1
	else:
		weapon_pivot.scale.y = 1
		
	if Input.is_action_pressed("left_click"):
		if can_fire:
			shoot()
			can_fire = false
			fire_timer = fire_rate

	if not can_fire:
		fire_timer -= delta
		if fire_timer <= 0:
			can_fire = true
		
		
func shoot():
	doubleshot_gun_sound.play()
	var new_bullet1 = BULLET2.instantiate()
	var new_bullet2 = BULLET2.instantiate()
	
	var pause_menu = get_node("/root/world/PauseMenu")
	
	stats_manager.total_shots_fired += 2
	
	if stats_manager.shots_fired_by_weapon.has(weapon_name):
		stats_manager.shots_fired_by_weapon[weapon_name] += 2
	else:
		stats_manager.shots_fired_by_weapon[weapon_name] = 2
	
	if pause_menu and pause_menu.gun2_level >= 4:
		var new_bullet3 = BULLET2.instantiate()
		new_bullet3.global_position = shooting_point.global_position
		new_bullet3.rotation = weapon_pivot.rotation
		world = get_node("/root/world")
		world.add_child(new_bullet3)
		
		stats_manager.total_shots_fired += 1
		
		if stats_manager.shots_fired_by_weapon.has(weapon_name):
			stats_manager.shots_fired_by_weapon[weapon_name] += 1
	
	new_bullet1.global_position = shooting_point.global_position
	new_bullet1.rotation = weapon_pivot.rotation - SPREAD_ANGLE
	
	new_bullet2.global_position = shooting_point.global_position
	new_bullet2.rotation = weapon_pivot.rotation + SPREAD_ANGLE
	
	
	if not world:
		world = get_node("/root/world")
	world.add_child(new_bullet1)
	world.add_child(new_bullet2)
		
