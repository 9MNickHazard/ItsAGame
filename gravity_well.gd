extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var pull_area: Area2D = $PullArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var duration_timer: Timer = $DurationTimer
@onready var damage_timer: Timer = $DamageTimer

static var glass_cannon_multiplier: bool = false
static var runforrestrun_multiplier: bool = false

var damage_per_tick: int = 10
var pull_strength: float = 300.0
var max_pull_strength: float = 600.0
var lifetime: float = 12.0
var pull_affected_enemies: Array = []
var damage_affected_enemies: Array = []
var spin_speed: float = 2.0
var is_spinning: bool = false


static var damage_bonus: int = 0
static var duration_bonus: float = 0.0
static var pull_radius_bonus: float = 0.0
static var damage_radius_bonus: float = 0.0

func _ready() -> void:
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
	
	var pull_shape: CircleShape2D = pull_area.get_node("CollisionShape2D").shape
	if pull_shape is CircleShape2D:
		var original_radius = pull_shape.radius
		pull_shape.radius = original_radius * (1.0 + (pull_radius_bonus / 100.0))

	var hitbox_shape = hitbox_area.get_node("CollisionShape2D").shape
	if hitbox_shape is CircleShape2D:
		var original_radius = hitbox_shape.radius
		hitbox_shape.radius = original_radius * (1.0 + (damage_radius_bonus / 100.0))
	

func _process(delta: float) -> void:
	if is_spinning:
		animated_sprite.rotation -= spin_speed * delta

func _physics_process(delta: float) -> void:
	for enemy in pull_affected_enemies:
		if is_instance_valid(enemy):
			enemy.is_being_pulled_by_gravity_well = true
			enemy.gravity_well_position = global_position
			enemy.gravity_well_strength = pull_strength
			
			var distance: float = global_position.distance_to(enemy.global_position)
			var pull_shape = pull_area.get_node("CollisionShape2D").shape
			var max_distance = pull_shape.radius
			var distance_factor = clamp(1.0 - (distance / max_distance), 0.30, 1.0)
			
			enemy.gravity_well_factor = distance_factor


func _on_animation_finished() -> void:
	if animated_sprite.animation == "gravity_well":
		animated_sprite.stop()
		animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("gravity_well") - 1
		
		is_spinning = true

func _on_damage_timer_timeout() -> void:
	for enemy in damage_affected_enemies:
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			var damage_dealt: int = damage_per_tick + damage_bonus
			if glass_cannon_multiplier:
				damage_dealt = damage_dealt * 2
			if runforrestrun_multiplier:
				damage_dealt = ceil(damage_dealt * 0.75)
			enemy.take_damage(damage_dealt)

func _on_pull_area_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("mobs"):
		pull_affected_enemies.append(body)

func _on_pull_area_body_exited(body: CharacterBody2D) -> void:
	if pull_affected_enemies.has(body):
		pull_affected_enemies.erase(body)
		body.is_being_pulled_by_gravity_well = false

func _on_hitbox_area_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("mobs"):
		damage_affected_enemies.append(body)

func _on_hitbox_area_body_exited(body: CharacterBody2D) -> void:
	if damage_affected_enemies.has(body):
		damage_affected_enemies.erase(body)

func _on_duration_timer_timeout() -> void:
	is_spinning = false
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
