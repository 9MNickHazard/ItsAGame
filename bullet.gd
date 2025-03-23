extends Area2D

var travelled_distance: float = 0.0

static var damage_min_bonus: int = 0
static var damage_max_bonus: int = 0

var minimum_damage: int = 8
var maximum_damage: int = 12
var damage: int

static var speed_bonus: float = 0.0
static var range_bonus: float = 0.0

static var glass_cannon_multiplier: bool = false
static var runforrestrun_multiplier: bool = false

static var permanent_min_damage_bonus: int = 0
static var permanent_max_damage_bonus: int = 0

static var homing_enabled: bool = false
var homing_strength: float = 10.0
var target_enemy: Node2D = null

var BULLET_SPEED: float = 1000.0 + speed_bonus
var RANGE: float = 1500.0 + range_bonus

func _ready() -> void:
	minimum_damage = minimum_damage + damage_min_bonus + permanent_min_damage_bonus
	maximum_damage = maximum_damage + damage_max_bonus + permanent_max_damage_bonus
	
	if homing_enabled:
		target_enemy = find_closest_enemy()

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	
	if homing_enabled and is_instance_valid(target_enemy):
		var to_enemy: Vector2 = global_position.direction_to(target_enemy.global_position)
		direction = direction.lerp(to_enemy, homing_strength * delta).normalized()
		rotation = direction.angle()
	
	position += direction * BULLET_SPEED * delta
	
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > RANGE:
		queue_free()

func find_closest_enemy() -> Node2D:
	var regular_enemies = get_tree().get_nodes_in_group("mobs")
	var boss_enemies = get_tree().get_nodes_in_group("boss")
	
	var all_enemies = []
	all_enemies.append_array(regular_enemies)
	all_enemies.append_array(boss_enemies)
	
	var closest_enemy = null
	var closest_distance: float = 10000.0
	
	for enemy in all_enemies:
		if enemy and is_instance_valid(enemy):
			var distance: float = global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy
	
	return closest_enemy
	
	
	

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		var knockback_dir: Vector2 = Vector2.RIGHT.rotated(rotation)
		body.take_damage(damage, 250.0, knockback_dir)
		
	queue_free()
		
