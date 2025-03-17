extends Area2D

var travelled_distance: float = 0.0

static var damage_min_bonus: int = 0
static var damage_max_bonus: int = 0

var minimum_damage: int = 4
var maximum_damage: int = 8
var damage: int

static var speed_bonus: float = 0.0
static var range_bonus: float = 0.0

static var glass_cannon_multiplier: bool = false
static var runforrestrun_multiplier: bool = false

var BULLET_SPEED: float = 1500.0 + speed_bonus
var RANGE: float = 1000.0 + range_bonus

static var permanent_min_damage_bonus: int = 0
static var permanent_max_damage_bonus: int = 0

func _ready() -> void:
	minimum_damage = minimum_damage + damage_min_bonus + permanent_min_damage_bonus
	maximum_damage = maximum_damage + damage_max_bonus + permanent_max_damage_bonus

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLET_SPEED * delta
	
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > RANGE:
		queue_free()
	
	
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)

		body.take_damage(damage)
		
	queue_free()
