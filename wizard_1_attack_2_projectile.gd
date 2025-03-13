extends Area2D

var travelled_distance: float = 0.0
var minimum_damage: int = 10
var maximum_damage: int = 15
var damage: int = randi_range(minimum_damage, maximum_damage)

var PROJECTILE_SPEED: float = 350.0
var RANGE: float = 1000.0
var direction: Vector2 = Vector2.ZERO

func fire_projectile(target_pos: Vector2) -> void:
	direction = global_position.direction_to(target_pos).normalized()
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * PROJECTILE_SPEED * delta
	
	travelled_distance += PROJECTILE_SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)
		queue_free()
