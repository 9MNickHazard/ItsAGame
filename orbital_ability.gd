extends Node2D

@onready var rotation_point: Marker2D = $RotationPoint
@onready var sprite_2d1: Sprite2D = $RotationPoint/Sprite2D
@onready var area_2d1: Area2D = $RotationPoint/Sprite2D/Area2D
@onready var sprite_2d2: Sprite2D = $RotationPoint/Sprite2D2
@onready var area_2d2: Area2D = $RotationPoint/Sprite2D2/Area2D2
@onready var sprite_2d3: Sprite2D = $RotationPoint/Sprite2D3
@onready var area_2d: Area2D = $RotationPoint/Sprite2D3/Area2D3
@onready var sprite_2d4: Sprite2D = $RotationPoint/Sprite2D4
@onready var area_2d4: Area2D = $RotationPoint/Sprite2D4/Area2D4
@onready var sprite_2d5: Sprite2D = $RotationPoint/Sprite2D5
@onready var area_2d5: Area2D = $RotationPoint/Sprite2D5/Area2D5
@onready var sprite_2d6: Sprite2D = $RotationPoint/Sprite2D6
@onready var area_2d6: Area2D = $RotationPoint/Sprite2D6/Area2D6
@onready var sprite_2d7: Sprite2D = $RotationPoint/Sprite2D7
@onready var area_2d7: Area2D = $RotationPoint/Sprite2D7/Area2D7
@onready var sprite_2d8: Sprite2D = $RotationPoint/Sprite2D8
@onready var area_2d8: Area2D = $RotationPoint/Sprite2D8/Area2D8
@onready var duration_timer: Timer = $DurationTimer

static var glass_cannon_multiplier: bool = false
static var runforrestrun_multiplier: bool = false

static var ability_level: int = 1

var rotation_speed: float = 5  # radians per second
var orbit_radius: float = 150.0
var knockback_amount: float = 300.0
var knockback_dir: Vector2
var active_orbs: int

var minimum_damage: int = 10
var maximum_damage: int = 15

var min_damage_bonus: int = 0
var max_damage_bonus: int = 0

static var permanent_min_damage_bonus: int = 0
static var permanent_max_damage_bonus: int = 0

var damage: int

var duration: float

var player

func _ready() -> void:
	player = get_node("/root/world/player")
	rotation_speed = 1.5 * (1 + (ability_level * 0.15))
	
	if ability_level > 1:
		for i in range(ability_level - 1):
			min_damage_bonus += 2
			max_damage_bonus += 4
	
	minimum_damage = minimum_damage + min_damage_bonus + permanent_min_damage_bonus
	maximum_damage = maximum_damage + max_damage_bonus + permanent_max_damage_bonus
	
	duration = 20.0 + ((ability_level - 1) * 5.0)
	duration_timer.wait_time = duration
	duration_timer.start()
	
	minimum_damage += (2 * (ability_level - 1))
	maximum_damage += (2 * (ability_level - 1))
	
	active_orbs = ability_level
	
	disable_all_sprites_and_hitboxes()
	
	for i in range(active_orbs):
		var angle: float = (2 * PI / active_orbs) * i
		var position: Vector2 = Vector2(cos(angle), sin(angle)) * orbit_radius
		
		match i:
			0:
				enable_and_position_sprite(sprite_2d1, area_2d1, position)
			1:
				enable_and_position_sprite(sprite_2d2, area_2d2, position)
			2:
				enable_and_position_sprite(sprite_2d3, area_2d, position)
			3:
				enable_and_position_sprite(sprite_2d4, area_2d4, position)
			4:
				enable_and_position_sprite(sprite_2d5, area_2d5, position)
			5:
				enable_and_position_sprite(sprite_2d6, area_2d6, position)
			6:
				enable_and_position_sprite(sprite_2d7, area_2d7, position)
			7:
				enable_and_position_sprite(sprite_2d8, area_2d8, position)


func _process(delta: float) -> void:
	global_position = player.global_position
	rotation_point.rotation += rotation_speed * delta

func disable_sprite_and_hitbox(sprite_node: Sprite2D, area_node: Area2D) -> void:
	sprite_node.visible = false
	area_node.monitoring = false
	area_node.monitorable = false
	
	var collision_shape = area_node.get_node("CollisionShape2D")
	collision_shape.disabled = true
	
func enable_and_position_sprite(sprite_node: Sprite2D, area_node: Area2D, position: Vector2) -> void:
	sprite_node.visible = true
	sprite_node.position = position
	area_node.monitoring = true
	area_node.monitorable = true
	
	var collision_shape = area_node.get_node("CollisionShape2D")
	collision_shape.disabled = false
	
func disable_all_sprites_and_hitboxes() -> void:
	disable_sprite_and_hitbox(sprite_2d1, area_2d1)
	disable_sprite_and_hitbox(sprite_2d2, area_2d2)
	disable_sprite_and_hitbox(sprite_2d3, area_2d)
	disable_sprite_and_hitbox(sprite_2d4, area_2d4)
	disable_sprite_and_hitbox(sprite_2d5, area_2d5)
	disable_sprite_and_hitbox(sprite_2d6, area_2d6)
	disable_sprite_and_hitbox(sprite_2d7, area_2d7)
	disable_sprite_and_hitbox(sprite_2d8, area_2d8)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_area_2d_4_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_area_2d_5_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_area_2d_6_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_area_2d_7_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_area_2d_8_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		damage = randi_range(minimum_damage, maximum_damage)
		if glass_cannon_multiplier:
			damage = damage * 2
		if runforrestrun_multiplier:
			damage = ceil(damage * 0.75)
			
		knockback_dir = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)


func _on_duration_timer_timeout() -> void:
	queue_free()
