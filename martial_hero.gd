extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var attack_1_hitbox: Area2D = $Attack1Hitbox
@onready var attack_2_hitbox: Area2D = $Attack2Hitbox
@onready var attack_1_facing_away_hitbox: Area2D = $Attack1FacingAwayHitbox
@onready var attack_2_facing_away_hitbox: Area2D = $Attack2FacingAwayHitbox
@onready var attack_1_facing_camera: Area2D = $Attack1FacingCamera
@onready var attack_2_facing_camera: Area2D = $Attack2FacingCamera
@onready var los_ray: RayCast2D = $LOSRayCast

const CoinScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene = preload("res://scenes/floating_damage.tscn")
const HeartScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene = preload("res://scenes/mana_ball.tscn")


# player pushback variables
var push_direction = Vector2.ZERO
var is_being_pushed = false
const PUSH_SPEED = 100.0

var player
var is_attacking = false
var attack_range = 135
var attack_cooldown = 1.0
var attack_timer = 0.0
var health = 200.0
var overlapping_player = false
var damage_cooldown = 1.0
var damage_timer = 0.0
var minimum_damage = 20.0
var maximum_damage = 40.0
var damage
var is_dead = false

var knockback_timer = 0.0
var knockback_duration = 0.15
const KNOCKBACK_AMOUNT = 250

const SPEED = 400.0

enum State {CHASE, WANDER}
var current_state = State.CHASE
var state_timer = 0.0
var wander_direction = Vector2.ZERO


func _ready() -> void:
	player = get_node("/root/world/player")
	animated_sprite.play("run")
	
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	attack_1_hitbox.monitoring = false
	attack_2_hitbox.monitoring = false
	attack_1_facing_away_hitbox.monitoring = false
	attack_2_facing_away_hitbox.monitoring = false
	attack_1_facing_camera.monitoring = false
	attack_2_facing_camera.monitoring = false
	
	
			
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
		# if goblin is chasing it has 50% chance to start wandering
		if current_state == State.CHASE and randf() <= 0.2:
			current_state = State.WANDER
			wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		# if goblin is wandering it has 60% chance to start chasing
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
	
	# only check distance if not already in middle of an attack
	if not is_attacking and distance_to_player <= attack_range and attack_timer >= attack_cooldown:
		start_attack()
		attack_timer = 0.0
	
	var optimal_distance = 100.0
	
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
		
	if overlapping_player:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			if player.has_method("take_damage_from_mob1"):
				player.take_damage_from_mob1(damage)
			damage_timer = 0.0
			
			
			
func _on_frame_changed():
	if is_attacking and animated_sprite.frame == 3:  # frame 5, index 4
		match animated_sprite.animation:
			"attack1":
				attack_1_hitbox.monitoring = true
			"attack2":
				attack_2_hitbox.monitoring = true
			"attack1facingaway":
				attack_1_facing_away_hitbox.monitoring = true
			"attack2facingaway":
				attack_2_facing_away_hitbox.monitoring = true
			"attack1facingcamera":
				attack_1_facing_camera.monitoring = true
			"attack2facingcamera":
				attack_2_facing_camera.monitoring = true

	elif is_attacking and animated_sprite.frame == 4:  # frame 6, index 5
		attack_1_hitbox.monitoring = false
		attack_2_hitbox.monitoring = false
		attack_1_facing_away_hitbox.monitoring = false
		attack_2_facing_away_hitbox.monitoring = false
		attack_1_facing_camera.monitoring = false
		attack_2_facing_camera.monitoring = false
		

func start_attack():
	if is_dead:
		return
	
	is_attacking = true
	
	attack_1_hitbox.monitoring = false
	attack_2_hitbox.monitoring = false
	attack_1_facing_away_hitbox.monitoring = false
	attack_2_facing_away_hitbox.monitoring = false
	attack_1_facing_camera.monitoring = false
	attack_2_facing_camera.monitoring = false
	
	var to_player = player.global_position - global_position
	var distance_to_player
		
	if abs(to_player.y) > abs(to_player.x):
		if to_player.y > 0:
			play_attack_animation(5)
			await animated_sprite.animation_finished
			distance_to_player = global_position.distance_to(player.global_position)
			
			if distance_to_player <= attack_range:
				play_attack_animation(6)
				await animated_sprite.animation_finished
				end_attack()
			else:
				end_attack()
		else:
			play_attack_animation(3)
			await animated_sprite.animation_finished
			distance_to_player = global_position.distance_to(player.global_position)
			
			if distance_to_player <= attack_range:
				play_attack_animation(4)
				await animated_sprite.animation_finished
				end_attack()
			else:
				end_attack()
	else:
		play_attack_animation(1)
		await animated_sprite.animation_finished
		distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player <= attack_range:
			play_attack_animation(2)
			await animated_sprite.animation_finished
			end_attack()
		else:
			end_attack()
	


func end_attack():
	is_attacking = false
	attack_1_hitbox.monitoring = false
	attack_2_hitbox.monitoring = false
	attack_1_facing_away_hitbox.monitoring = false
	attack_2_facing_away_hitbox.monitoring = false
	attack_1_facing_camera.monitoring = false
	attack_2_facing_camera.monitoring = false
	attack_timer = 0.0
	animated_sprite.play("run")

func play_attack_animation(which_attack: int):
	if is_dead:
		return
	
	var to_player = player.global_position - global_position
		
	if abs(to_player.y) > abs(to_player.x):
		if to_player.y > 0:
			if which_attack == 5:
				animated_sprite.play("attack1facingcamera")
			elif which_attack == 6:
				animated_sprite.play("attack2facingcamera")
		else:
			if which_attack == 3:
				animated_sprite.play("attack1facingaway")
			elif which_attack == 4:
				animated_sprite.play("attack2facingaway")
	else:
		animated_sprite.flip_h = to_player.x < 0
		if to_player.x < 0:
			attack_1_hitbox.scale.x = -1
			attack_2_hitbox.scale.x = -1
		else:
			attack_1_hitbox.scale.x = 1
			attack_2_hitbox.scale.x = 1
		
		if which_attack == 1:
			animated_sprite.play("attack1")
		elif which_attack == 2:
			animated_sprite.play("attack2")
	
		
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
		
		var coin_number = randi_range(25, 50)
		var x_offset = randi_range(5, 25)
		var y_offset = randi_range(5, 25)
		for i in range(coin_number):
			if randi() % 2 == 0 and coin_number > 1:
				x_offset = -x_offset
			if randi() % 2 == 0 and coin_number > 1:
				y_offset = -y_offset
			
			var coin = CoinPoolManager.get_coin()
			coin.global_position = global_position + Vector2(x_offset, y_offset)
			
		if randf() < 0.09:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
			
		if randf() < 0.08:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		var xp_amount = 200
		var ui = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(5)
		animated_sprite.play("death")
		await animated_sprite.animation_finished
		queue_free()
	
	hit_flash.stop()
	hit_flash.play("hit_flash")


func _on_attack_1_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_attack_2_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_attack_1_facing_away_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)
			
func _on_attack_2_facing_away_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_attack_1_facing_camera_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_attack_2_facing_camera_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)





# exiting areaa
func _on_attack_1_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0


func _on_attack_2_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0


func _on_attack_1_facing_away_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0
		

func _on_attack_2_facing_away_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_attack_1_facing_camera_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0


func _on_attack_2_facing_camera_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0
		
		
func _on_player_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = true
		push_direction = (global_position - player.global_position).normalized()


func _on_player_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = false
