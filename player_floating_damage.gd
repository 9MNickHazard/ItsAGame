extends Node2D

@onready var label: Label = $Label
var velocity: Vector2 = Vector2.ZERO
var damage_amount: int = 0
var lifetime: float = 0.5
var fade_duration: float = 0.3

func _ready() -> void:
	position += Vector2(randf_range(-20, 20), randf_range(-10, -30))
	
	velocity = Vector2(randf_range(-20, 20), -100)
	
	label.text = str(round(damage_amount))
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration).set_delay(lifetime)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	position += velocity * delta
	velocity.y += 100 * delta
