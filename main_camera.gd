extends Camera2D

@onready var damage_vignette = get_node("/root/world/UI/DamageVignette")

var shake_amount = 0
var default_offset = offset
var trauma = 0.0
var trauma_power = 2
var decay = 0.8
var max_offset = Vector2(32, 24)

func _ready():
	if damage_vignette:
		damage_vignette.modulate.a = 0

func _process(delta):
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake()
	
	if damage_vignette and damage_vignette.modulate.a > 0:
		damage_vignette.modulate.a = max(damage_vignette.modulate.a - delta, 0)

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)
	
	if damage_vignette:
		damage_vignette.modulate.a = min(damage_vignette.modulate.a + amount, 0.5)

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_offset.x * amount * randf_range(-1, 1) * 0.01
	offset.x = max_offset.x * amount * randf_range(-1, 1) 
	offset.y = max_offset.y * amount * randf_range(-1, 1)
