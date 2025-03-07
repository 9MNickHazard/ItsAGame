extends Area2D

var travelled_distance = 0

static var damage_min_bonus = 0.0
static var damage_max_bonus = 0.0

var minimum_damage = 4.0
var maximum_damage = 7.0
var damage = randf_range(minimum_damage + damage_min_bonus, maximum_damage + damage_max_bonus)

static var speed_bonus = 0.0
static var range_bonus = 0.0

static var glass_cannon_multiplier = false
static var runforrestrun_multiplier = false

var BULLET_SPEED = 1500.0 + speed_bonus
var RANGE = 1000.0 + range_bonus

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLET_SPEED * delta
	
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > RANGE:
		queue_free()
	
	
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		var knockback_dir = Vector2.ZERO
		body.take_damage(damage)
		
	queue_free()
