extends Node2D

@onready var label = $Label
var velocity = Vector2.ZERO
var heal_amount = 0
var lifetime = 0.5
var fade_duration = 0.3

func _ready():
	position += Vector2(randf_range(-20, 20), randf_range(-10, -30))
	
	velocity = Vector2(randf_range(-20, 20), -100)
	
	label.text = "+" + str(round(int(heal_amount)))
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration).set_delay(lifetime)
	tween.tween_callback(queue_free)

func _process(delta):
	position += velocity * delta
	velocity.y += 100 * delta
