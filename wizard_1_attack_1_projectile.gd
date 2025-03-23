extends Area2D

var travelled_distance: float = 0.0
var minimum_damage: int = 5
var maximum_damage: int = 10
var damage: int = randi_range(minimum_damage, maximum_damage)

var PROJECTILE_SPEED: float = 250.0
var RANGE: float = 800.0
var direction: Vector2 = Vector2.ZERO

func fire_projectile(dir: Vector2, damage_multiplier: float = 1.0) -> void:
	direction = dir.normalized()
	rotation = direction.angle()
	
	if damage_multiplier != 1.0:
		minimum_damage = int(minimum_damage * damage_multiplier)
		maximum_damage = int(maximum_damage * damage_multiplier)
		damage = randi_range(minimum_damage, maximum_damage)

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
