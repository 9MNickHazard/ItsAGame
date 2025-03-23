extends Area2D

@onready var weapon_pivot: Marker2D = $WeaponPivot
@onready var shooting_point: Marker2D = $WeaponPivot/Sprite2D/ShootingPoint
@onready var shotgun_sound: AudioStreamPlayer2D = $ShotgunSound
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")
@onready var pause_menu: CanvasLayer = get_node("/root/world/PauseMenu")

const BULLET = preload("res://scenes/shotgun_bullet.tscn")

var can_fire: bool = true
var fire_rate: float = 0.50
var fire_timer: float = 0.0
var world: Node2D
var bullet_angle: float
var bullet_count: int = 6
const TOTAL_SPREAD_ANGLE: float = PI/4
var weapon_name: String = "Shotgun"


func _ready() -> void:
	world = get_node("/root/world")

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
	shotgun_sound.stop()
	shotgun_sound.play()
	
	if pause_menu.shotgun_level >= 5:
		bullet_count = 8
	elif pause_menu.shotgun_level >= 3:
		bullet_count = 7
	
	stats_manager.total_shots_fired += bullet_count
	
	if stats_manager.shots_fired_by_weapon.has(weapon_name):
		stats_manager.shots_fired_by_weapon[weapon_name] += bullet_count
	else:
		stats_manager.shots_fired_by_weapon[weapon_name] = bullet_count
	
	if not world:
		world = get_node("/root/world")
	
	for i in range(bullet_count):
		bullet_angle = -TOTAL_SPREAD_ANGLE/2 + i * (TOTAL_SPREAD_ANGLE / (bullet_count - 1))
		
		var new_bullet: Area2D = BULLET.instantiate()
		new_bullet.global_position = shooting_point.global_position
		new_bullet.rotation = weapon_pivot.rotation + bullet_angle
		world.add_child(new_bullet)
