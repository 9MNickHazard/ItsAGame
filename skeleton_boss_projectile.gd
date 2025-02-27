extends Area2D

@onready var sprite: Sprite2D = $Projectile
@onready var particles: CPUParticles2D = $CPUParticles2D

var direction = Vector2.RIGHT
var speed = 650.0
var traveled_distance = 0
var max_distance = 1200.0
var damage = randi_range(15, 25)
var rotation_speed = 5.0  # For spinning effect

func _ready():
	# Set up initial rotation based on direction
	rotation = direction.angle()
	
	# Optional: Add a trail effect or particles
	# If you have a particles node, you could enable it here

func _process(delta):
	# Make particles emit in the opposite direction of travel
	particles.gravity = -direction * 100
	# Make sure emission is in local coordinates
	particles.local_coords = false

func _physics_process(delta):
	# Move in the specified direction
	position += direction * speed * delta
	
	# Optional: Add rotation for visual effect
	sprite.rotation += rotation_speed * delta
	
	# Check if the projectile has traveled far enough
	traveled_distance += speed * delta
	if traveled_distance >= max_distance:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("player_hurtbox"):
		var player = area.get_parent()
		if player.has_method("take_damage_from_mob1"):
			player.take_damage_from_mob1(damage)
		queue_free()
