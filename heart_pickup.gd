extends Area2D

@onready var pickup_area: Area2D = $PickupArea
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var despawn_timer: Timer = $DespawnTimer
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

var player = null
var max_speed: float = 600.0
var current_speed: float = 0.0
var acceleration: float = 800.0
var is_being_pulled: bool = false

static var permanent_pickup_range_bonus: float = 0.0
var pickup_shape
var original_radius

func _ready() -> void:
	pickup_shape = pickup_area.get_node("CollisionShape2D").shape
	original_radius = pickup_shape.radius
	pickup_shape.radius = original_radius + permanent_pickup_range_bonus
	cpu_particles_2d.emitting = true
	despawn_timer.start()
	

func _physics_process(delta: float) -> void:
	if is_being_pulled and player:
		if player.health >= player.max_health:
			is_being_pulled = false
			current_speed = 0
			return
		
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
		
		var direction: Vector2 = global_position.direction_to(player.global_position)
		
		global_position += direction * current_speed * delta


func _on_body_entered(body: Node2D) -> void:
	player = get_node("/root/world/player")
	if player.health >= player.max_health:
		return
	else:
		var heal_amount: int = min(10, player.max_health - player.health)
		player.health += heal_amount
		player.health_changed.emit(player.health)
		
		stats_manager.total_hearts_collected += 1
		
		queue_free()


func _on_pickup_area_body_entered(body: Node2D) -> void:
	player = get_node("/root/world/player")
	if player.health >= player.max_health:
		is_being_pulled = false
		current_speed = 0
		return
		
	if body.is_in_group("player"):
		player = body
		is_being_pulled = true
		current_speed = 0


func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		is_being_pulled = false
		current_speed = 0


func _on_despawn_timer_timeout() -> void:
	queue_free()
