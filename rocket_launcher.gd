extends Area2D

@onready var weapon_pivot: Marker2D = $"weapon pivot"
@onready var shooting_point: Marker2D = $"weapon pivot/Sprite2D/shooting point"
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

const ROCKET = preload("res://scenes/rocket_ammo.tscn")

var can_fire: bool = true
var fire_rate: float = 0.9
var fire_timer: float = 0.0

var weapon_name: String = "Nuke Launcher"


func _physics_process(delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var direction: Vector2 = global_position.direction_to(mouse_pos)
	
	var angle: float = direction.angle()
	
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
		
		
func shoot() -> void:
	audio_stream_player.play()
	var new_bullet: Area2D = ROCKET.instantiate()
	new_bullet.global_position = shooting_point.global_position
	new_bullet.rotation = weapon_pivot.rotation
	
	get_node("/root/world").add_child(new_bullet)
	
	stats_manager.total_shots_fired += 1
	
	if stats_manager.shots_fired_by_weapon.has(weapon_name):
		stats_manager.shots_fired_by_weapon[weapon_name] += 1
	else:
		stats_manager.shots_fired_by_weapon[weapon_name] = 1
