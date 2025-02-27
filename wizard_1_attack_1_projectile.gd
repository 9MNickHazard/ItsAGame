extends Area2D

var travelled_distance = 0
var minimum_damage = 5.0
var maximum_damage = 10.0
var damage = randi_range(minimum_damage, maximum_damage)

var PROJECTILE_SPEED = 300.0
var RANGE = 900.0
var direction = Vector2.ZERO

func fire_projectile(dir: Vector2):
	direction = dir.normalized()
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
