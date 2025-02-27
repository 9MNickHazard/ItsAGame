extends Area2D

@onready var pickup_area: Area2D = $PickupArea


var player = null
var max_speed = 600
var current_speed = 0
var acceleration = 800
var is_being_pulled = false
	

func _physics_process(delta: float) -> void:
	if is_being_pulled and player:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
		
		var direction = global_position.direction_to(player.global_position)
		
		global_position += direction * current_speed * delta


func _on_body_entered(body: Node2D) -> void:
	var ui = get_node("/root/world/UI")
	if ui:
		ui.add_coin(100)
	queue_free()


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		is_being_pulled = true
		current_speed = 0


func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		is_being_pulled = false
		current_speed = 0
