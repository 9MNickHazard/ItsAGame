extends Area2D

static var glass_cannon_multiplier: bool = false
static var runforrestrun_multiplier: bool = false

var enemies_hit: Array = []

static var damage_min_bonus: int = 0
static var damage_max_bonus: int = 0

var damage_min: int = 15
var damage_max: int = 30

var damage: int

static var permanent_min_damage_bonus: int = 0
static var permanent_max_damage_bonus: int = 0

func _ready() -> void:
	damage_min = damage_min + damage_min_bonus + permanent_min_damage_bonus
	damage_max = damage_max + damage_max_bonus + permanent_max_damage_bonus

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not enemies_hit.has(body):
		damage = randi_range(damage_min, damage_max)
		
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		enemies_hit.append(body)
		var knockback_dir: Vector2 = Vector2.ZERO
		body.take_damage(damage)
