extends Area2D

@onready var rocket: Sprite2D = $Rocket
@onready var explosion: AnimatedSprite2D = $ExplosionSprite
@onready var explosion_sfx: AudioStreamPlayer2D = $"Explosion SFX"
@onready var explosion_area: Area2D = $"ExplosionSprite/Explosion Area"
@onready var explosion_collision: CollisionShape2D = $"ExplosionSprite/Explosion Area/Explosion Collision"

var travelled_distance: float = 0.0
static var damage_min_bonus: int = 0
static var damage_max_bonus: int = 0
var minimum_damage: int = 30
var maximum_damage: int = 60
var damage: int = randf_range(minimum_damage + damage_min_bonus, maximum_damage + damage_max_bonus)
static var speed_bonus: float = 0.0
static var range_bonus: float = 0.0
var BULLET_SPEED: float = 600.0 + speed_bonus
var RANGE: float = 800.0 + range_bonus

static var glass_cannon_multiplier: bool = false
static var runforrestrun_multiplier: bool = false

var has_exploded: bool = false
var enemies_hit: Array = []

func _ready() -> void:
	explosion.visible = false
	explosion_collision.disabled = true
	explosion.animation_finished.connect(_on_explosion_animation_finished)
	explosion.frame_changed.connect(_on_explosion_frame_changed)

func _physics_process(delta: float) -> void:
	if has_exploded:
		return
		
	var direction: Vector2 = Vector2.RIGHT.rotated(rotation)
	position += direction * BULLET_SPEED * delta
	
	travelled_distance += BULLET_SPEED * delta
	if travelled_distance > RANGE:
		start_explosion()

func _on_body_entered(body: Node2D) -> void:
	if not has_exploded:
		start_explosion()


func start_explosion() -> void:
	has_exploded = true
	rocket.visible = false
	explosion.visible = true
	explosion_sfx.play()
	explosion.play("explosion")
	explosion_collision.call_deferred("set", "disabled", false)

func _on_explosion_frame_changed() -> void:
	if explosion.animation == "explosion":
		var current_frame = explosion.frame
		
		if current_frame in [2, 3, 4]:
			var bodies = explosion_area.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("take_damage") and not enemies_hit.has(body):
					if glass_cannon_multiplier:
						damage = damage * 2
					if runforrestrun_multiplier:
						damage = ceil(damage * 0.75)
						
					enemies_hit.append(body)
					var knockback_dir: Vector2 = (body.global_position - global_position).normalized()
					body.take_damage(damage, 400.0, knockback_dir)

func _on_explosion_animation_finished() -> void:
	if explosion.animation == "explosion":
		queue_free()
