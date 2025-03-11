extends Area2D

@onready var sprite: Sprite2D = $Projectile
@onready var particles: CPUParticles2D = $CPUParticles2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 650.0
var traveled_distance: int = 0
var max_distance: float = 1200.0
var damage: int = randi_range(15, 25)
var rotation_speed: float = 5.0

func _ready() -> void:
	rotation = direction.angle()


func _process(delta: float) -> void:
	particles.gravity = -direction * 100
	particles.local_coords = false

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	sprite.rotation += rotation_speed * delta
	
	traveled_distance += speed * delta
	if traveled_distance >= max_distance:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var player: CharacterBody2D = area.get_parent()
		if player.has_method("take_damage_from_mob1"):
			player.take_damage_from_mob1(damage)
		queue_free()
