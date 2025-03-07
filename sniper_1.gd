extends Node2D

@onready var shooting_point: Marker2D = $"weapon pivot/Sniper1Gun/shooting point"
@onready var weapon_pivot = $"weapon pivot"
@onready var laser_sight: Line2D = $"laser sight"
@onready var sniper_shot: AudioStreamPlayer2D = $"sniper shot"
@onready var stats_manager = get_node("/root/world/StatsManager")

const BULLET = preload("res://scenes/sniper_1_bullet.tscn")

var can_fire = true
var fire_rate = 0.60
var fire_timer = 0.0
const LASER_LENGTH = 2000

var weapon_name = "Sniper"


func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	var direction = global_position.direction_to(mouse_pos)
	
	var angle = direction.angle()
	
	weapon_pivot.rotation = angle
	
	if abs(angle) > PI/2:
		weapon_pivot.scale.y = -1
	else:
		weapon_pivot.scale.y = 1
		
	laser_sight.global_position = shooting_point.global_position
	laser_sight.rotation = weapon_pivot.rotation
		
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
	sniper_shot.play()
	
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.rotation = weapon_pivot.rotation
	
	get_node("/root/world").add_child(new_bullet)
	
	stats_manager.total_shots_fired += 1
	
	if stats_manager.shots_fired_by_weapon.has(weapon_name):
		stats_manager.shots_fired_by_weapon[weapon_name] += 1
	else:
		stats_manager.shots_fired_by_weapon[weapon_name] = 1
	
	
	
