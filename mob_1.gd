extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $HitFlash
@onready var facing_away_hitbox: Area2D = $FacingAwayHitbox
@onready var facing_camera_hitbox: Area2D = $FacingCameraHitbox
@onready var side_hitbox: Area2D = $SideHitbox
@onready var goblin_sfx: AudioStreamPlayer2D = $Node2D/GoblinSFX
@onready var goblin_sfx_2: AudioStreamPlayer2D = $Node2D/GoblinSFX2
@onready var goblin_sfx_3: AudioStreamPlayer2D = $Node2D/GoblinSFX3
@onready var goblin_sfx_4: AudioStreamPlayer2D = $Node2D/GoblinSFX4
@onready var goblin_sfx_5: AudioStreamPlayer2D = $Node2D/GoblinSFX5
@onready var goblin_sfx_6: AudioStreamPlayer2D = $Node2D/GoblinSFX6
@onready var goblin_sfx_7: AudioStreamPlayer2D = $Node2D/GoblinSFX7
@onready var goblin_sfx_8: AudioStreamPlayer2D = $Node2D/GoblinSFX8
@onready var goblin_sfx_9: AudioStreamPlayer2D = $Node2D/GoblinSFX9
@onready var goblin_sfx_10: AudioStreamPlayer2D = $Node2D/GoblinSFX10
@onready var goblin_sfx_11: AudioStreamPlayer2D = $Node2D/GoblinSFX11
@onready var goblin_sfx_12: AudioStreamPlayer2D = $Node2D/GoblinSFX12
@onready var goblin_sfx_13: AudioStreamPlayer2D = $Node2D/GoblinSFX13
@onready var goblin_sfx_14: AudioStreamPlayer2D = $Node2D/GoblinSFX14
@onready var goblin_sfx_15: AudioStreamPlayer2D = $Node2D/GoblinSFX15
@onready var goblin_death_sfx: AnimationPlayer = $GoblinDeathSFX
@onready var los_ray: RayCast2D = $LOSRayCast
@onready var stats_manager = get_node("/root/world/StatsManager")

const CoinScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene = preload("res://scenes/floating_damage.tscn")
const HeartScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene = preload("res://scenes/mana_ball.tscn")
const fivecoin_scene = preload("res://scenes/5_coin.tscn")
const FloatingHealScene = preload("res://scenes/floating_heal.tscn")

# gravity well variables
var is_being_pulled_by_gravity_well = false
var gravity_well_position = Vector2.ZERO
var gravity_well_strength = 0.0
var gravity_well_factor = 0.0

# player pushback variables
var push_direction = Vector2.ZERO
var is_being_pushed = false
const PUSH_SPEED = 100.0

var player
var is_attacking = false
var attack_range = 60
var attack_cooldown = 0.5
var attack_timer = 0.0
var max_health = 20.0
var health = 20.0
var overlapping_player = false
var damage_cooldown = 1.5
var damage_timer = 0.0
var damage
var minimum_damage = 6.0
var maximum_damage = 12.0
var is_dead = false

var knockback_timer = 0.0
var knockback_duration = 0.15

const SPEED = 275.0

enum State {CHASE, WANDER, FLANK}
var current_state = State.CHASE
var state_timer = 0.0
var wander_direction = Vector2.ZERO
var flank_direction = Vector2.ZERO


func _ready() -> void:
	player = get_node("/root/world/player")
	animated_sprite.play("run")
	
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	facing_away_hitbox.monitoring = false
	facing_camera_hitbox.monitoring = false
	side_hitbox.monitoring = false
	
	
			
func _physics_process(delta):
	if is_dead:
		return
		
	var movement_velocity = Vector2.ZERO
	
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
		
		if current_state == State.CHASE:
			var rand_value = randf()
			if rand_value <= 0.15:
				current_state = State.WANDER
				wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			elif rand_value <= 0.35:
				current_state = State.FLANK
				flank_direction = calculate_flank_direction()
		
		elif current_state == State.WANDER:
			var rand_value = randf()
			if rand_value <= 0.70:
				current_state = State.CHASE
			elif rand_value <= 0.85:
				current_state = State.FLANK
				flank_direction = calculate_flank_direction()
		
		elif current_state == State.FLANK:
			var rand_value = randf()
			if rand_value <= 0.70:
				current_state = State.CHASE
			elif rand_value <= 0.80:
				current_state = State.WANDER
				wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	attack_timer += delta
	
	var ai_direction
	if not is_inside_play_area():
		ai_direction = global_position.direction_to(Vector2.ZERO)
	elif current_state == State.CHASE:
		ai_direction = global_position.direction_to(player.global_position)
	elif current_state == State.FLANK:
		ai_direction = flank_direction
	else:
		ai_direction = wander_direction
	
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if not is_attacking and distance_to_player <= attack_range and attack_timer >= attack_cooldown:
		start_attack()
		attack_timer = 0.0
	
	var optimal_distance = 50.0
	
	var ai_velocity = Vector2.ZERO
	if not is_attacking:
		if distance_to_player > optimal_distance:
			ai_velocity = ai_direction * SPEED
		
		if is_being_pulled_by_gravity_well:
			var pull_direction = global_position.direction_to(gravity_well_position)
			
			var pull_velocity = pull_direction * gravity_well_strength * gravity_well_factor
			
			var pull_dominance = pow(gravity_well_factor, 1.5)
			velocity = ai_velocity * (1.0 - pull_dominance) + pull_velocity * pull_dominance
		else:
			velocity = ai_velocity
			
		if ai_direction.x != 0:
			animated_sprite.flip_h = ai_direction.x < 0
		
		if velocity != Vector2.ZERO:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
			
		move_and_slide()
		
	if overlapping_player:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			if player.has_method("take_damage_from_mob1"):
				player.take_damage_from_mob1(20)
			damage_timer = 0.0
	
	
			
			
func _on_frame_changed():
	if is_attacking and animated_sprite.frame == 3:  # frame 4, index 3
		match animated_sprite.animation:
			"facing_camera_attack":
				facing_camera_hitbox.monitoring = true
			"facing_away_attack":
				facing_away_hitbox.monitoring = true
			"side_attack":
				side_hitbox.monitoring = true
	elif is_attacking and animated_sprite.frame == 4:  # frame 5, index 4
		facing_camera_hitbox.monitoring = false
		facing_away_hitbox.monitoring = false
		side_hitbox.monitoring = false
		

func start_attack():
	if is_dead:
		return
		
	is_attacking = true
	
	facing_away_hitbox.monitoring = false
	facing_camera_hitbox.monitoring = false
	side_hitbox.monitoring = false
	
	play_attack_animation()
	await animated_sprite.animation_finished
	end_attack()


func end_attack():
	if is_dead:
		return
		
	is_attacking = false
	facing_away_hitbox.monitoring = false
	facing_camera_hitbox.monitoring = false
	side_hitbox.monitoring = false
	attack_timer = 0.0
	animated_sprite.play("run")

func play_attack_animation():
	if is_dead:
		return
		
	var to_player = player.global_position - global_position
	
	if abs(to_player.y) > abs(to_player.x):
		if to_player.y > 0:
			animated_sprite.play("facing_camera_attack")
		else:
			animated_sprite.play("facing_away_attack")
	else:
		animated_sprite.play("side_attack")
		animated_sprite.flip_h = to_player.x < 0
		
		if to_player.x < 0:
			side_hitbox.scale.x = -1
		else:
			side_hitbox.scale.x = 1
			
func is_inside_play_area() -> bool:
	return global_position.x >= -1570 and global_position.x <= 1570 and \
		   global_position.y >= -970 and global_position.y <= 950
		
func calculate_flank_direction():
	var to_player = player.global_position - global_position
	var perpendicular = Vector2(-to_player.y, to_player.x).normalized()
	if randf() > 0.5:
		perpendicular = -perpendicular
	return (perpendicular * 0.8 + to_player.normalized() * 0.2).normalized()
			

func play_random_goblin_death_sound():
	var sound_effect = randi_range(1, 15)
	if sound_effect == 1:
		goblin_sfx.play()
	elif sound_effect == 2:
		goblin_sfx_2.play()
	elif sound_effect == 3:
		goblin_sfx_3.play()
	elif sound_effect == 4:
		goblin_sfx_4.play()
	elif sound_effect == 5:
		goblin_sfx_5.play()
	elif sound_effect == 6:
		goblin_sfx_6.play()
	elif sound_effect == 7:
		goblin_sfx_7.play()
	elif sound_effect == 8:
		goblin_sfx_8.play()
	elif sound_effect == 9:
		goblin_sfx_9.play()
	elif sound_effect == 10:
		goblin_sfx_10.play()
	elif sound_effect == 11:
		goblin_sfx_11.play()
	elif sound_effect == 12:
		goblin_sfx_12.play()
	elif sound_effect == 13:
		goblin_sfx_13.play()
	elif sound_effect == 14:
		goblin_sfx_14.play()
	elif sound_effect == 15:
		goblin_sfx_15.play()

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
		
	stats_manager.damage_dealt_to_enemies += damage_dealt
		
	if health <= 0:
		is_dead = true
		is_attacking = false
		
		stats_manager.add_enemy_kill("Torch Goblin")
		
		var coin_number = randi_range(1, 3)
		var x_offset = randi_range(-25, 25)
		var y_offset = randi_range(-25, 25)
		
		for i in range(coin_number):
			x_offset = randi_range(-25, 25)
			y_offset = randi_range(-25, 25)
			
			var coin = CoinPoolManager.get_coin()
			if coin:
				coin.global_position = global_position + Vector2(x_offset, y_offset)
			else:
				print("ERROR: Failed to get coin from pool")
			
		if randf() < 0.03:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
		
		if randf() < 0.02:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		#var xp_amount = randi_range(2, 5)
		var xp_amount = 30
		var ui = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(1)
		goblin_death_sfx.play("Goblin Death SFX")
	
	animation_player.stop()
	animation_player.play("hit_flash")

func heal(amount: float):
	if not is_instance_valid(self) or is_dead or health >= max_health:
		return
	
	var actual_heal = min(amount, max_health - health)
	health += actual_heal
	
	var heal_number = FloatingHealScene.instantiate()
	heal_number.heal_amount = actual_heal
	get_parent().add_child(heal_number)
	heal_number.global_position = global_position + Vector2(0, -30)

func _on_facing_away_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_facing_camera_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)


func _on_side_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)
			

# exiting areaa
func _on_facing_away_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0


func _on_facing_camera_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0


func _on_side_hitbox_area_exited(area: Area2D) -> void:
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
