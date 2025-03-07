extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var pull_area: Area2D = $PullArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var duration_timer: Timer = $DurationTimer
@onready var damage_timer: Timer = $DamageTimer

var damage_per_tick = 5.0
var pull_strength = 300.0
var max_pull_strength = 600.0
var lifetime = 12.0
var pull_affected_enemies = []
var damage_affected_enemies = []
var spin_speed = 2.0
var is_spinning = false


static var damage_bonus = 0.0
static var duration_bonus = 0.0
static var pull_radius_bonus = 0.0
static var damage_radius_bonus = 0.0

func _ready():
	animated_sprite.play("gravity_well")
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	duration_timer.wait_time = lifetime + duration_bonus
	duration_timer.one_shot = true
	duration_timer.start()
	duration_timer.timeout.connect(_on_duration_timer_timeout)
	
	damage_timer.wait_time = 1.0
	damage_timer.one_shot = false
	damage_timer.start()
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	
	var pull_shape = pull_area.get_node("CollisionShape2D").shape
	if pull_shape is CircleShape2D:
		var original_radius = pull_shape.radius
		pull_shape.radius = original_radius * (1.0 + (pull_radius_bonus / 100.0))

	var hitbox_shape = hitbox_area.get_node("CollisionShape2D").shape
	if hitbox_shape is CircleShape2D:
		var original_radius = hitbox_shape.radius
		hitbox_shape.radius = original_radius * (1.0 + (damage_radius_bonus / 100.0))
	

func _process(delta):
	if is_spinning:
		animated_sprite.rotation -= spin_speed * delta

func _physics_process(delta):
	for enemy in pull_affected_enemies:
		if is_instance_valid(enemy):
			enemy.is_being_pulled_by_gravity_well = true
			enemy.gravity_well_position = global_position
			enemy.gravity_well_strength = pull_strength
			
			var distance = global_position.distance_to(enemy.global_position)
			var pull_shape = pull_area.get_node("CollisionShape2D").shape
			var max_distance = pull_shape.radius
			var distance_factor = clamp(1.0 - (distance / max_distance), 0.30, 1.0)
			
			enemy.gravity_well_factor = distance_factor


func _on_animation_finished():
	if animated_sprite.animation == "gravity_well":
		animated_sprite.stop()
		animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("gravity_well") - 1
		
		is_spinning = true

func _on_damage_timer_timeout():
	for enemy in damage_affected_enemies:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			var damage_dealt = damage_per_tick + damage_bonus
			enemy.take_damage(damage_dealt)

func _on_pull_area_body_entered(body):
	if body.is_in_group("mobs"):
		pull_affected_enemies.append(body)

func _on_pull_area_body_exited(body):
	if pull_affected_enemies.has(body):
		pull_affected_enemies.erase(body)
		body.is_being_pulled_by_gravity_well = false

func _on_hitbox_area_body_entered(body):
	if body.is_in_group("mobs"):
		damage_affected_enemies.append(body)

func _on_hitbox_area_body_exited(body):
	if damage_affected_enemies.has(body):
		damage_affected_enemies.erase(body)

func _on_duration_timer_timeout():
	is_spinning = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
