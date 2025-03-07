extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area1: Area2D = $Area1
@onready var area2: Area2D = $Area2
@onready var area3: Area2D = $Area3
@onready var area4: Area2D = $Area4
@onready var area5: Area2D = $Area5


static var damage = 10.0
static var knockback_amount = 200.0
static var shockwave_color

var enemy_hit_counts = {}
const MAX_HITS_PER_ENEMY = 3

func _ready():
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	area1.monitoring = false
	area2.monitoring = false
	area3.monitoring = false
	area4.monitoring = false
	area5.monitoring = false

func _on_frame_changed():
	area1.monitoring = false
	area2.monitoring = false
	area3.monitoring = false
	area4.monitoring = false
	area5.monitoring = false
	
	match animated_sprite.frame:
		0:
			area1.monitoring = true
		1:
			area2.monitoring = true
		2:
			area3.monitoring = true
		3:
			area4.monitoring = true
		4, 5:
			area5.monitoring = true

func _on_animation_finished():
	area1.monitoring = false
	area2.monitoring = false
	area3.monitoring = false
	area4.monitoring = false
	area5.monitoring = false
	queue_free()

func handle_body_entered(body: Node2D):
	if is_instance_valid(body) and body.has_method("take_damage"):
		if not enemy_hit_counts.has(body):
			enemy_hit_counts[body] = 0
		
		if enemy_hit_counts[body] < MAX_HITS_PER_ENEMY:
			enemy_hit_counts[body] += 1
			
			var knockback_dir = (body.global_position - global_position).normalized()
			
			body.take_damage(damage, knockback_amount, knockback_dir)

func _on_area_1_body_entered(body: Node2D):
	handle_body_entered(body)

func _on_area_2_body_entered(body: Node2D):
	handle_body_entered(body)

func _on_area_3_body_entered(body: Node2D):
	handle_body_entered(body)

func _on_area_4_body_entered(body: Node2D):
	handle_body_entered(body)

func _on_area_5_body_entered(body: Node2D):
	handle_body_entered(body)
