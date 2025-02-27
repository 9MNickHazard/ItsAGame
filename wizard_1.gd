extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var attack_1_release_point: Marker2D = $"attack1 release point"
@onready var attack_2_release_point: Marker2D = $"attack2 release point"
@onready var los_ray: RayCast2D = $LOSRayCast


const CoinScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene = preload("res://scenes/floating_damage.tscn")
const ATTACK1 = preload("res://scenes/wizard_1_attack_1_projectile.tscn")
const ATTACK2 = preload("res://scenes/wizard_1_attack_2_projectile.tscn")
const HeartScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene = preload("res://scenes/mana_ball.tscn")

# player pushback variables
var push_direction = Vector2.ZERO
var is_being_pushed = false
const PUSH_SPEED = 100.0

var player
var attack_range = 650.0
var attack_cooldown = 2.0
var attack_timer = 0.0
var health = 100.0
var is_attacking = false
var is_dead = false

var knockback_timer = 0.0
var knockback_duration = 0.15
const KNOCKBACK_AMOUNT = 250

const SPEED = 175.0

enum State {CHASE, WANDER}
var current_state = State.CHASE
var state_timer = 0.0
var wander_direction = Vector2.ZERO

func _ready() -> void:
	player = get_node("/root/world/player")
	animated_sprite.play("run")
	animated_sprite.frame_changed.connect(_on_frame_changed)

func _physics_process(delta):
	if is_dead:
		return
		
	if is_being_pushed and player:
		var push_velocity = push_direction * PUSH_SPEED
		velocity = push_velocity
		move_and_slide()
		return
		
	if knockback_timer > 0:
		knockback_timer -= delta
		move_and_slide()
		return
	
	state_timer += delta
	
	if state_timer >= 2.0:
		state_timer = 0
		if current_state == State.CHASE and randf() <= 0.2:
			current_state = State.WANDER
			wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		elif current_state == State.WANDER and randf() <= 0.8:
			current_state = State.CHASE
	
	attack_timer += delta
	
	var direction
	
	if not is_inside_play_area():
		direction = global_position.direction_to(Vector2.ZERO)
	elif current_state == State.CHASE:
		direction = global_position.direction_to(player.global_position)
	else:
		direction = wander_direction
		
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Handle attacks
	if distance_to_player <= attack_range and attack_timer >= attack_cooldown:
		if randf() <= 0.3:
			use_attack1()
			attack_timer = 0.0
		else:
			use_attack2()
			attack_timer = 0.0
	
	var optimal_distance = 350.0
	
	if not is_attacking:
		if distance_to_player > optimal_distance:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
		
		if direction.x != 0:
			animated_sprite.flip_h = direction.x < 0
		
		if velocity != Vector2.ZERO:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
			
		move_and_slide()
			


func _on_frame_changed():
	if is_attacking and animated_sprite.animation == "attack1" and animated_sprite.frame == 5:
		# Create 8 projectiles in different directions
		var directions = [
			Vector2.RIGHT,           # East
			Vector2.RIGHT + Vector2.UP,    # Northeast
			Vector2.UP,             # North
			Vector2.LEFT + Vector2.UP,     # Northwest
			Vector2.LEFT,           # West
			Vector2.LEFT + Vector2.DOWN,   # Southwest
			Vector2.DOWN,           # South
			Vector2.RIGHT + Vector2.DOWN    # Southeast
		]
		
		for dir in directions:
			var attack1_projectile = ATTACK1.instantiate()
			attack1_projectile.global_position = attack_1_release_point.global_position
			attack1_projectile.fire_projectile(dir)
			get_parent().add_child(attack1_projectile)
			
	elif is_attacking and animated_sprite.animation == "attack2" and animated_sprite.frame == 4:
		var attack2_projectile = ATTACK2.instantiate()
		attack2_projectile.global_position = attack_2_release_point.global_position
		attack2_projectile.fire_projectile(player.global_position)
		get_parent().add_child(attack2_projectile)
		
		
func use_attack1():
	if is_dead:
		return
		
	is_attacking = true
	animated_sprite.play("attack1")
	await animated_sprite.animation_finished
	is_attacking = false
	animated_sprite.play("run")
	
func use_attack2():
	if is_dead:
		return
		
	is_attacking = true
	animated_sprite.play("attack2")
	await animated_sprite.animation_finished
	is_attacking = false
	animated_sprite.play("run")
	
func is_inside_play_area() -> bool:
	return global_position.x >= -1570 and global_position.x <= 1570 and \
		   global_position.y >= -970 and global_position.y <= 950

func take_damage(damage_dealt: float = 10.0, knockback_amount: float = 250.0, knockback_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return
		
	health -= damage_dealt
	
	var damage_number = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage_dealt
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -30)
	
	if knockback_dir != Vector2.ZERO:
		velocity = knockback_dir * knockback_amount
		knockback_timer = knockback_duration
		
	if health <= 0:
		is_dead = true
		is_attacking = false
		
		var coin_number = randi_range(12, 30)
		var x_offset = randi_range(5, 25)
		var y_offset = randi_range(5, 25)
		for i in range(coin_number):
			if randi() % 2 == 0 and coin_number > 1:
				x_offset = -x_offset
			if randi() % 2 == 0 and coin_number > 1:
				y_offset = -y_offset
			
			var coin = CoinPoolManager.get_coin()
			coin.global_position = global_position + Vector2(x_offset, y_offset)
			
		if randf() < 0.07:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
			
		if randf() < 0.05:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		var xp_amount = 100
		var ui = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(3)
		animated_sprite.play("death")
		await animated_sprite.animation_finished
		queue_free()
	
	hit_flash.stop()
	hit_flash.play("hit_flash")
	
	
func _on_player_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = true
		push_direction = (global_position - player.global_position).normalized()


func _on_player_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = false
