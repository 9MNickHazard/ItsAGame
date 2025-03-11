extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $SingleArea/CollisionShape2D
@onready var single_area: Area2D = $SingleArea

static var damage: int = 20
static var knockback_amount: float = 200.0

var hit_enemies: Dictionary = {}

var current_radius: float
var max_radius: float = 465.0
var expansion_rate: float = 930.0

func _ready() -> void:
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	hit_enemies = {}
	
	current_radius = 68.0
	collision_shape.shape.set_radius(current_radius)

func _process(delta: float) -> void:
	if current_radius < max_radius:
		current_radius += expansion_rate * delta
		if collision_shape.shape:
			collision_shape.shape.set_radius(current_radius)

func _on_body_entered(body: CharacterBody2D) -> void:
	if not is_instance_valid(body):
		return
	
	if is_instance_valid(body) and body.has_method("take_damage"):
		var body_id: int = body.get_instance_id()
		print(body_id)
		if hit_enemies.has(body_id):
			return
			
		hit_enemies[body_id] = true
		
		var knockback_dir: Vector2 = (body.global_position - global_position).normalized()
		body.take_damage(damage, knockback_amount, knockback_dir)

func _on_animation_finished() -> void:
	queue_free()
	






#@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
#@onready var area1: Area2D = $Area1
#@onready var area2: Area2D = $Area2
#@onready var area3: Area2D = $Area3
#@onready var area4: Area2D = $Area4
#@onready var area5: Area2D = $Area5
#
#
#static var damage = 10.0
#static var knockback_amount = 200.0
#static var shockwave_color
#
#var enemy_hit_counts = {}
#const MAX_HITS_PER_ENEMY = 3
#
#const MAX_ENEMIES_PER_FRAME = 12
#var enemies_processed_this_frame = 0
#var last_frame_processed = -1
#
#func _ready():
	#animated_sprite.animation_finished.connect(_on_animation_finished)
	#animated_sprite.frame_changed.connect(_on_frame_changed)
	#
	#disable_all_areas()
#
#func _exit_tree():
	#enemy_hit_counts.clear()
	#
	#if animated_sprite and animated_sprite.is_connected("animation_finished", _on_animation_finished):
		#animated_sprite.animation_finished.disconnect(_on_animation_finished)
	#if animated_sprite and animated_sprite.is_connected("frame_changed", _on_frame_changed):
		#animated_sprite.frame_changed.disconnect(_on_frame_changed)
#
## Disable all collision areas
#func disable_all_areas():
	#area1.monitoring = false
	#area2.monitoring = false
	#area3.monitoring = false
	#area4.monitoring = false
	#area5.monitoring = false
#
#func _on_frame_changed():
	#disable_all_areas()
	#
	#match animated_sprite.frame:
		#0:
			#area1.monitoring = true
		#1:
			#area2.monitoring = true
		#2:
			#area3.monitoring = true
		#3:
			#area4.monitoring = true
		#4, 5:
			#area5.monitoring = true
#
#func _on_animation_finished():
	#disable_all_areas()
	#queue_free()
#
#func handle_body_entered(body: Node2D):
	#var current_frame = Engine.get_frames_drawn()
	#if current_frame != last_frame_processed:
		#enemies_processed_this_frame = 0
		#last_frame_processed = current_frame
	#
	#if enemies_processed_this_frame >= MAX_ENEMIES_PER_FRAME:
		#return
		#
	#if not is_instance_valid(body) or not body.has_method("take_damage"):
		#return
		#
	#var body_id = body.get_instance_id()
	#
	#if not enemy_hit_counts.has(body_id):
		#enemy_hit_counts[body_id] = 0
	#
	#if enemy_hit_counts[body_id] < MAX_HITS_PER_ENEMY:
		#enemy_hit_counts[body_id] += 1
		#
		#var knockback_dir = (body.global_position - global_position).normalized()
		#
		#if body.has_method("take_damage"):
			#body.take_damage(damage, knockback_amount, knockback_dir)
			#
		#enemies_processed_this_frame += 1
#
#func _on_area_1_body_entered(body: Node2D):
	#handle_body_entered(body)
#
#func _on_area_2_body_entered(body: Node2D):
	#handle_body_entered(body)
#
#func _on_area_3_body_entered(body: Node2D):
	#handle_body_entered(body)
#
#func _on_area_4_body_entered(body: Node2D):
	#handle_body_entered(body)
#
#func _on_area_5_body_entered(body: Node2D):
	#handle_body_entered(body)
