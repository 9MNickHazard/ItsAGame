extends Area2D

@onready var pickup_area: Area2D = $PickupArea
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D


var player = null
var max_speed = 600
var current_speed = 0
var acceleration = 800
var is_being_pulled = false

func _ready() -> void:
	cpu_particles_2d.emitting = true
	

func _physics_process(delta: float) -> void:
	if is_being_pulled and player:
		if player.current_mana >= player.max_mana:
			is_being_pulled = false
			current_speed = 0
			return
			
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
		
		var direction = global_position.direction_to(player.global_position)
		
		global_position += direction * current_speed * delta


func _on_body_entered(body: Node2D) -> void:
	player = get_node("/root/world/player")
	if player.current_mana >= player.max_mana:
		return
	else:
		var mana_amount = min(50, player.max_mana - player.current_mana)
		player.current_mana += mana_amount
		player.mana_changed.emit(player.current_mana)
		queue_free()


func _on_pickup_area_body_entered(body: Node2D) -> void:
	player = get_node("/root/world/player")
	if player.current_mana >= player.max_mana:
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
