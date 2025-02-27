extends StaticBody2D

@onready var detection_area: Area2D = $DetectionArea

var default_alpha = 1.0
var transparent_alpha = 0.7
var bodies_behind = 0

func _ready() -> void:
	modulate.a = default_alpha



func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("mobs"):
		bodies_behind += 1
		modulate.a = transparent_alpha


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("mobs"):
		bodies_behind -= 1
		if bodies_behind <= 0:
			bodies_behind = 0
			modulate.a = default_alpha
