extends Area2D

@onready var pickup_area: Area2D = $PickupArea
@onready var coin_sfx: AudioStreamPlayer2D = $"Coin SFX"
@onready var despawn_timer: Timer = $DespawnTimer

var player = null
var max_speed: float = 600.0
var current_speed: float = 0.0
var acceleration: float = 800.0
var is_being_pulled: bool = false
var value: int = 25

func _ready() -> void:
	set_physics_process(false)
	despawn_timer.start()

func _physics_process(delta: float) -> void:
	if is_being_pulled and player:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
		
		var direction: Vector2 = global_position.direction_to(player.global_position)
		
		global_position += direction * current_speed * delta


func _on_body_entered(body: Node2D) -> void:
	var ui: CanvasLayer = get_node("/root/world/UI")
	if ui:
		ui.add_coin(value)

	coin_sfx.play()
	
	var timer = get_tree().create_timer(0.22)
	await timer.timeout
	
	queue_free()


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		is_being_pulled = true
		current_speed = 0
		set_physics_process(true)


func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		is_being_pulled = false
		current_speed = 0


func _on_despawn_timer_timeout() -> void:
	queue_free()
