extends Area2D

var travelled_distance = 0

static var damage_min_bonus = 0.0
static var damage_max_bonus = 0.0

var minimum_damage = 8.0
var maximum_damage = 12.0
var damage = randf_range(minimum_damage + damage_min_bonus, maximum_damage + damage_max_bonus)

static var speed_bonus = 0.0
static var range_bonus = 0.0

var BULLET_SPEED = 1000.0 + speed_bonus
var RANGE = 1500.0 + range_bonus

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLET_SPEED * delta
	
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > RANGE:
		queue_free()
	
	
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var knockback_dir = Vector2.RIGHT.rotated(rotation)
		body.take_damage(damage, 250.0, knockback_dir)
		
	queue_free()
		
