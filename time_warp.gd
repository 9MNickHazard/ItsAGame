extends Node2D

@onready var slow_area: Area2D = $SlowArea
@onready var duration_timer: Timer = $DurationTimer
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var slow_duration = 5.0

static var ability_level = 1

func _ready() -> void:
	if ability_level > 1:
		duration_timer.wait_time = 8.0 + (ability_level * 2.0)
		sprite_2d.scale *= 1 + (ability_level * 0.2)
		slow_area.scale *= 1 + (ability_level * 0.2)
		cpu_particles_2d.scale *= 1 + (ability_level * 0.2)
		slow_duration += ability_level * 1.5
	
	duration_timer.start()


func _on_slow_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.has_method("apply_slow_effect"):
		body.apply_slow_effect(slow_duration)


func _on_duration_timer_timeout() -> void:
	queue_free()
