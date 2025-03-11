extends Area2D

@onready var warning_circle: ColorRect = $ColorRect
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var warning_timer: Timer = $WarningTimer

var minimum_damage: int = 5
var maximum_damage: int = 15
var damage: int


func _ready() -> void:
	warning_circle.visible = true
	animated_sprite.visible = false
	collision_shape.disabled = true
	
	animated_sprite.frame_changed.connect(_on_frame_changed)
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_warning_timer_timeout() -> void:
	warning_circle.visible = false
	animated_sprite.visible = true
	collision_shape.disabled = false
	animated_sprite.play("spike")

func _on_frame_changed() -> void:
	if animated_sprite.animation == "spike" and animated_sprite.frame in [1, 2]:
		var areas = get_overlapping_areas()
		for area in areas:
			if area.is_in_group("player_hurtbox"):
				var player: CharacterBody2D = area.get_parent()
				if player.has_method("take_damage_from_mob1"):
					damage = randi_range(minimum_damage, maximum_damage)
					player.take_damage_from_mob1(damage)

func _on_animation_finished() -> void:
	queue_free()
