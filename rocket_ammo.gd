extends Area2D

@onready var rocket: Sprite2D = $Rocket
@onready var explosion: AnimatedSprite2D = $ExplosionSprite
@onready var explosion_sfx: AudioStreamPlayer2D = $"Explosion SFX"
@onready var explosion_area: Area2D = $"ExplosionSprite/Explosion Area"
@onready var explosion_collision: CollisionShape2D = $"ExplosionSprite/Explosion Area/Explosion Collision"

var travelled_distance = 0
static var damage_min_bonus = 0.0
static var damage_max_bonus = 0.0
var minimum_damage = 50.0
var maximum_damage = 100.0
var damage = randf_range(minimum_damage + damage_min_bonus, maximum_damage + damage_max_bonus)
static var speed_bonus = 0.0
static var range_bonus = 0.0
var BULLET_SPEED = 600.0 + speed_bonus
var RANGE = 800.0 + range_bonus

var has_exploded = false
var enemies_hit = []

func _ready():
	explosion.visible = false
	explosion_collision.disabled = true
	explosion.animation_finished.connect(_on_explosion_animation_finished)
	explosion.frame_changed.connect(_on_explosion_frame_changed)

func _physics_process(delta: float) -> void:
	if has_exploded:
		return
		
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLET_SPEED * delta
	
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > RANGE:
		start_explosion()

func _on_body_entered(body: Node2D) -> void:
	if not has_exploded:
		start_explosion()


func start_explosion():
	has_exploded = true
	rocket.visible = false
	explosion.visible = true
	explosion_sfx.play()
	explosion.play("explosion")
	explosion_collision.call_deferred("set", "disabled", false)

func _on_explosion_frame_changed():
	if explosion.animation == "explosion":
		var current_frame = explosion.frame
		
		if current_frame in [2, 3, 4]:  # Apply damage on frames 3, 4, and 5
			var bodies = explosion_area.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("take_damage") and not enemies_hit.has(body):
					enemies_hit.append(body)
					var knockback_dir = (body.global_position - global_position).normalized()
					body.take_damage(damage, 400.0, knockback_dir)

func _on_explosion_animation_finished():
	if explosion.animation == "explosion":
		queue_free()
