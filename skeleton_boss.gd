extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var hp_bar = $HpBar

# Attack hitboxes
@onready var down_attack1 = $DownAttack1
@onready var down_attack2_1 = $DownAttack2_1
@onready var down_attack2_2 = $DownAttack2_2
@onready var down_attack2_3 = $DownAttack2_3
@onready var side_attack1 = $SideAttack1
@onready var side_attack2_1 = $SideAttack2_1
@onready var side_attack2_2 = $SideAttack2_2
@onready var side_attack2_3 = $SideAttack2_3
@onready var up_attack1 = $UpAttack1
@onready var up_attack2_1 = $UpAttack2_1
@onready var up_attack2_2 = $UpAttack2_2
@onready var up_attack2_3 = $UpAttack2_3
@onready var charge_attack = $ChargeAttack

const CoinScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene = preload("res://scenes/floating_damage.tscn")
const HeartScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene = preload("res://scenes/mana_ball.tscn")
const SkeletonProjectile = preload("res://scenes/skeleton_boss_projectile.tscn")
const DiamondScene = preload("res://scenes/diamond.tscn")

# Boss stats
var health = 5000.0
var max_health = 5000.0
var is_dead = false

# Attack properties
var is_attacking = false
var attack_range = 300
var attack3_range = 700
var attack_cooldown = 1.5
var attack_timer = 0.0
var attack1_minimum_damage = 30.0
var attack1_maximum_damage = 60.0
var attack2_minimum_damage = 20.0
var attack2_maximum_damage = 40.0
var damage
var overlapping_player = false
var damage_cooldown = 1.5
var damage_timer = 0.0

# Movement properties
const SPEED = 500.0
const CHARGE_SPEED = 1200.0

# State management
enum State {CHASE, CHARGING, CHARGE_ATTACK}
var current_state = State.CHASE
var state_timer = 0.0
var player = null

# Charge attack properties
var charge_cooldown = 6.0
var charge_timer = 0.0
var is_charging = false
var charge_prep_time = 1.0
var charge_prep_timer = 0.0
var charge_direction = Vector2.ZERO
var charge_duration = 1.0
var charge_active_timer = 0.0

func _ready() -> void:
	player = get_node("/root/world/player")
	
	# Set up health bar
	hp_bar.max_value = max_health
	hp_bar.value = health
	
	# Set initial animation
	animated_sprite.play("DownIdle")
	
	# Connect frame changed signal
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	# Disable all hitboxes initially
	disable_all_hitboxes()

func _physics_process(delta):
	if is_dead:
		return
	
	# Handle charging state
	if current_state == State.CHARGING:
		charge_prep_timer += delta
		if charge_prep_timer >= charge_prep_time:
			# Start the actual charge attack
			current_state = State.CHARGE_ATTACK
			charge_direction = global_position.direction_to(player.global_position).normalized()
			charge_active_timer = 0.0
		return
		
	if current_state == State.CHARGE_ATTACK:
		charge_active_timer += delta
		if charge_active_timer < charge_duration:
			velocity = charge_direction * CHARGE_SPEED
			charge_attack.monitoring = true
			move_and_slide()
			return
		else:
			# End charge attack
			current_state = State.CHASE
			charge_attack.monitoring = false
			
	# Update state timer
	state_timer += delta
	if state_timer >= 3.0:
		state_timer = 0
	
	# Update attack timer
	attack_timer += delta
	charge_timer += delta
	
	var direction
	
	if not is_inside_play_area():
		direction = global_position.direction_to(Vector2.ZERO)
	else:
		direction = global_position.direction_to(player.global_position)

	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Check if we should do a charge attack
	if not is_attacking and charge_timer >= charge_cooldown and distance_to_player <= 700 and distance_to_player > 300 and randf() <= 0.6:
		start_charge()
		charge_timer = 0.0
		return
		
	# Check if we should attack
	if not is_attacking and attack_timer >= attack_cooldown:
		if distance_to_player <= attack3_range and distance_to_player > attack_range:
			# Player is in the extended range - use attack 3 (projectiles)
			choose_attack(3)  # Force attack type 3
			attack_timer = 0.0
			return
		elif distance_to_player <= attack_range:
			# Player is in close range - use any attack
			choose_attack()
			attack_timer = 0.0
			return
	
	# Handle movement
	var optimal_distance = 150.0
	
	if not is_attacking and current_state != State.CHARGING and current_state != State.CHARGE_ATTACK:
		if distance_to_player > optimal_distance:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
			
		# Set animation based on movement direction
		update_animation(direction)
		move_and_slide()
	
	# Handle player damage if overlapping
	if overlapping_player:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			if player.has_method("take_damage_from_mob1"):
				player.take_damage_from_mob1(damage)
			damage_timer = 0.0

func update_animation(direction):
	# Determine animation direction based on movement
	if direction.length() > 0.1:
		if abs(direction.y) > abs(direction.x):
			if direction.y > 0:
				animated_sprite.play("DownWalk")
			else:
				animated_sprite.play("UpWalk")
		else:
			animated_sprite.play("SideWalk")
			animated_sprite.flip_h = direction.x < 0
	else:
		# Idle animation based on last direction
		var current_anim = animated_sprite.animation
		if current_anim.begins_with("Down"):
			animated_sprite.play("DownIdle")
		elif current_anim.begins_with("Up"):
			animated_sprite.play("UpIdle")
		else:
			animated_sprite.play("SideIdle")

func choose_attack(force_attack_type = null):
	if is_dead:
		return
		
	is_attacking = true
	
	# Disable all hitboxes initially
	disable_all_hitboxes()
	
	# Choose attack type or use the forced type
	var attack_type
	
	if force_attack_type != null:
		attack_type = force_attack_type
	else:
		if randf() < 0.5:
			attack_type = 1
		elif randf() < 0.9:
			attack_type = 2
		else:
			attack_type = 3
	
	# Direction-based attack
	var to_player = player.global_position - global_position
	
	if abs(to_player.y) > abs(to_player.x):
		if to_player.y > 0:  # Player is below, use Down attacks
			play_attack_animation("Down", attack_type)
		else:  # Player is above, use Up attacks
			play_attack_animation("Up", attack_type)
	else:  # Player is to the side, use Side attacks
		animated_sprite.flip_h = to_player.x < 0
		
		# If facing left, flip the hitboxes
		if to_player.x < 0:
			side_attack1.scale.x = -1
			side_attack2_1.scale.x = -1
			side_attack2_2.scale.x = -1
			side_attack2_3.scale.x = -1
		else:
			side_attack1.scale.x = 1
			side_attack2_1.scale.x = 1
			side_attack2_2.scale.x = 1
			side_attack2_3.scale.x = 1
			
		play_attack_animation("Side", attack_type)

func play_attack_animation(direction, attack_type):
	animated_sprite.play(direction + "Attack" + str(attack_type))
	await animated_sprite.animation_finished
	end_attack()

func end_attack():
	is_attacking = false
	disable_all_hitboxes()
	attack_timer = 0.0
	
	# Return to appropriate idle animation
	var current_anim = animated_sprite.animation
	if current_anim.begins_with("Down"):
		animated_sprite.play("DownIdle")
	elif current_anim.begins_with("Up"):
		animated_sprite.play("UpIdle")
	else:
		animated_sprite.play("SideIdle")

func disable_all_hitboxes():
	# Disable all attack hitboxes
	down_attack1.monitoring = false
	down_attack2_1.monitoring = false
	down_attack2_2.monitoring = false
	down_attack2_3.monitoring = false
	side_attack1.monitoring = false
	side_attack2_1.monitoring = false
	side_attack2_2.monitoring = false
	side_attack2_3.monitoring = false
	up_attack1.monitoring = false
	up_attack2_1.monitoring = false
	up_attack2_2.monitoring = false
	up_attack2_3.monitoring = false
	charge_attack.monitoring = false

func _on_frame_changed():
	if not is_attacking:
		return
		
	var current_anim = animated_sprite.animation
	var current_frame = animated_sprite.frame
	
	# Handle Attack1 hitboxes - hit on frame 6 (index 5)
	if current_frame == 5:
		if current_anim == "DownAttack1":
			down_attack1.monitoring = true
		elif current_anim == "SideAttack1":
			side_attack1.monitoring = true
		elif current_anim == "UpAttack1":
			up_attack1.monitoring = true
		elif current_anim == "DownAttack3" or current_anim == "SideAttack3" or current_anim == "UpAttack3":
			spawn_projectiles()
			
	# Handle Attack2 hitboxes - hit on frames 4, 7, and 10
	if current_anim.ends_with("Attack2"):
		if current_frame == 3:  # Frame 4
			if current_anim == "DownAttack2":
				down_attack2_1.monitoring = true
			elif current_anim == "SideAttack2":
				side_attack2_1.monitoring = true
			elif current_anim == "UpAttack2":
				up_attack2_1.monitoring = true
		elif current_frame == 6:  # Frame 7
			if current_anim == "DownAttack2":
				down_attack2_1.monitoring = false
				down_attack2_2.monitoring = true
			elif current_anim == "SideAttack2":
				side_attack2_1.monitoring = false
				side_attack2_2.monitoring = true
			elif current_anim == "UpAttack2":
				up_attack2_1.monitoring = false
				up_attack2_2.monitoring = true
		elif current_frame == 9:  # Frame 10
			if current_anim == "DownAttack2":
				down_attack2_2.monitoring = false
				down_attack2_3.monitoring = true
			elif current_anim == "SideAttack2":
				side_attack2_2.monitoring = false
				side_attack2_3.monitoring = true
			elif current_anim == "UpAttack2":
				up_attack2_2.monitoring = false
				up_attack2_3.monitoring = true
		elif current_frame == 10:  # End of hitbox sequence
			if current_anim == "DownAttack2":
				down_attack2_3.monitoring = false
			elif current_anim == "SideAttack2":
				side_attack2_3.monitoring = false
			elif current_anim == "UpAttack2":
				up_attack2_3.monitoring = false

func spawn_projectiles():
	# Create 8 projectiles in cardinal and intercardinal directions
	var directions = [
		Vector2.RIGHT,                # East
		Vector2(1, -1).normalized(),  # Northeast
		Vector2.UP,                   # North
		Vector2(-1, -1).normalized(), # Northwest
		Vector2.LEFT,                 # West
		Vector2(-1, 1).normalized(),  # Southwest
		Vector2.DOWN,                 # South
		Vector2(1, 1).normalized()    # Southeast
	]
	
	for dir in directions:
		var projectile = SkeletonProjectile.instantiate()
		projectile.global_position = global_position
		projectile.direction = dir
		get_parent().add_child(projectile)

func start_charge():
	current_state = State.CHARGING
	charge_prep_timer = 0.0
	animation_player.play("charge_up")
	
	# After charge animation completes, charge attack begins in physics process

func is_inside_play_area() -> bool:
	return global_position.x >= -1570 and global_position.x <= 1570 and \
		   global_position.y >= -970 and global_position.y <= 950

func take_damage(damage_dealt: float = 10.0, knockback_amount: float = 250.0, knockback_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return
		
	health -= damage_dealt
	hp_bar.value = health
	
	# Spawn floating damage number
	var damage_number = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage_dealt
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -50)  # Higher for boss
	
	# Play hit effect
	#animation_player.stop()
	#animation_player.play("hit_flash")
	
	if health <= 0:
		die()

func die():
	is_dead = true
	is_attacking = false
	disable_all_hitboxes()
	
	# Determine death animation based on current orientation
	var current_anim = animated_sprite.animation
	if current_anim.begins_with("Down"):
		animated_sprite.play("DownDeath")
	elif current_anim.begins_with("Up"):
		animated_sprite.play("UpDeath") 
	else:
		animated_sprite.play("SideDeath")
	
	# Drop coins and items
	var diamond_number = randi_range(3, 7)
	for i in range(diamond_number):
		var diamond = DiamondScene.instantiate()
		var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
		diamond.global_position = global_position + offset
		get_parent().call_deferred("add_child", diamond)
	
	var coin_number = randi_range(25, 40)
	for i in range(coin_number):
		var coin = CoinPoolManager.get_coin()
		var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
		coin.global_position = global_position + offset
	
	for i in range(3):
		var heart = HeartScene.instantiate()
		heart.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_parent().call_deferred("add_child", heart)
	
	for i in range(2):
		var manaball = ManaBallScene.instantiate()
		manaball.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_parent().call_deferred("add_child", manaball)
	
	# XP
	var xp_amount = 3000
	var ui = get_node("/root/world/UI")
	if ui and ui.experience_manager:
		ui.experience_manager.add_experience(xp_amount)
		ui.increase_score(100)
	
	# Wait for death animation to finish before removing
	await animated_sprite.animation_finished
	queue_free()

# Individual hitbox area entered handlers
func _on_down_attack1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack1_minimum_damage, attack1_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_down_attack2_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_down_attack2_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_down_attack2_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_side_attack1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack1_minimum_damage, attack1_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_side_attack2_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_side_attack2_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_side_attack2_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_up_attack1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack1_minimum_damage, attack1_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_up_attack2_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_up_attack2_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_up_attack2_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(attack2_minimum_damage, attack2_maximum_damage)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_charge_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		var charge_damage = randi_range(45, 75)
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(charge_damage)
			
			
			
			
func _on_down_attack1_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_down_attack2_1_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_down_attack2_2_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_down_attack2_3_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_side_attack1_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_side_attack2_1_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_side_attack2_2_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_side_attack2_3_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_up_attack1_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_up_attack2_1_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_up_attack2_2_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_up_attack2_3_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_charge_attack_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0
