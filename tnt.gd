extends Area2D

@onready var tnt_sprite: AnimatedSprite2D = $TNTSprite
@onready var explosion_sprite: AnimatedSprite2D = $Explosion
@onready var explosion_collision: CollisionShape2D = $ExplosionCollision
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var initial_position: Vector2
var target_position: Vector2
var direction: Vector2
var has_landed: bool = false
var has_exploded: bool = false
var ground_timer: float = 0.0
const GROUND_DELAY = 1.0
var minimum_damage: int = 15
var maximum_damage: int = 30
var damage: int
const TNT_SPEED = 500.0

func _ready() -> void:
	monitoring = true
	monitorable = true

	tnt_sprite.play("wick")
	explosion_sprite.visible = false
	initial_position = global_position
	explosion_collision.disabled = true

func throw(target_pos: Vector2) -> void:
	target_position = target_pos

	target_position += Vector2(randf_range(-150, 150), randf_range(-150, 150))

	direction = global_position.direction_to(target_position)

func _physics_process(delta: float) -> void:
	if has_landed:
		animation_player.play("pre_explode")
		ground_timer += delta
		if ground_timer >= GROUND_DELAY and not has_exploded:
			has_exploded = true
			explode()
		return
	
	var distance_to_move: float = TNT_SPEED * delta
	var distance_to_target: float = global_position.distance_to(target_position)
	
	if distance_to_move >= distance_to_target:
		global_position = target_position
		land()
	else:
		global_position += direction * TNT_SPEED * delta

func land() -> void:
	has_landed = true
	ground_timer = 0.0
	rotation = 0

func explode() -> void:
	explosion_collision.disabled = false
	await get_tree().physics_frame

	tnt_sprite.visible = false
	explosion_sprite.visible = true

	explosion_sprite.play("explode")
	
	var areas: Array[Area2D] = get_overlapping_areas()
	for area in areas:
		if area.is_in_group("player_hurtbox"):
			var player: CharacterBody2D = area.get_parent()
			if player.has_method("take_damage_from_mob1"):
				damage = randi_range(minimum_damage, maximum_damage)
				player.take_damage_from_mob1(damage)
	
	await explosion_sprite.animation_finished
	queue_free()

func _on_explosion_animation_finished() -> void:
	if explosion_sprite.animation == "explode":
		queue_free()
			
