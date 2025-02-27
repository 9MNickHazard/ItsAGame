extends Area2D


var enemies_hit = []

static var damage_min_bonus = 0
static var damage_max_bonus = 0

var damage_min = 15
var damage_max = 30

var damage = randi_range(damage_min + damage_min_bonus, damage_max + damage_max_bonus)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and not enemies_hit.has(body):
		enemies_hit.append(body)
		var knockback_dir = Vector2.ZERO
		body.take_damage(damage)
