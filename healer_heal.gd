extends Area2D

@onready var heal_timer: Timer = $HealTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particles: CPUParticles2D = $CPUParticles2D

var minimum_heal: int = 7
var maximum_heal: int = 14
var heal_amount: int
const HEAL_INTERVAL = 0.25
var time_since_last_heal: float = 0.0

func _ready() -> void:
	animated_sprite.play("HealSpell")

func _process(delta: float) -> void:
	time_since_last_heal += delta
	
	if time_since_last_heal >= HEAL_INTERVAL:
		heal_nearby_mobs()
		time_since_last_heal = 0.0

func initialize(heal_multiplier: float = 1.0) -> void:
	minimum_heal = int(minimum_heal * heal_multiplier)
	maximum_heal = int(maximum_heal * heal_multiplier)
	

func heal_nearby_mobs() -> void:
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if is_instance_valid(body) and body.is_in_group("mobs") and not body.is_dead:
			if body.has_method("heal"):
				heal_amount = randi_range(minimum_heal, maximum_heal)
				body.heal(heal_amount)
		elif is_instance_valid(body) and body.is_in_group("boss") and not body.is_dead:
			if body.has_method("heal"):
				heal_amount = randi_range(minimum_heal, maximum_heal)
				body.heal(heal_amount)


func _on_heal_timer_timeout() -> void:
	queue_free()
