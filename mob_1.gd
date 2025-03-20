extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $HitFlash
@onready var facing_away_hitbox: Area2D = $FacingAwayHitbox
@onready var facing_camera_hitbox: Area2D = $FacingCameraHitbox
@onready var side_hitbox: Area2D = $SideHitbox
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

const CoinScene: PackedScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene: PackedScene = preload("res://scenes/floating_damage.tscn")
const HeartScene: PackedScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene: PackedScene = preload("res://scenes/mana_ball.tscn")
const fivecoin_scene: PackedScene = preload("res://scenes/5_coin.tscn")
const FloatingHealScene: PackedScene = preload("res://scenes/floating_heal.tscn")

# gravity well variables
var is_being_pulled_by_gravity_well: bool = false
var gravity_well_position: Vector2 = Vector2.ZERO
var gravity_well_strength: float = 0.0
var gravity_well_factor: float = 0.0

# player pushback variables
var push_direction: Vector2 = Vector2.ZERO
var is_being_pushed: bool = false
const PUSH_SPEED: float = 100.0

var player: CharacterBody2D
var is_attacking: bool = false
var attack_range: int = 60
var attack_cooldown:float = 0.5
var attack_timer: float = 0.0
var max_health: int = 20
var health: int = 20
var overlapping_player: bool = false
var damage_cooldown: float = 1.5
var damage_timer: float = 0.0
var damage: int
var minimum_damage: int = 6
var maximum_damage: int = 12
var is_dead: bool = false

var knockback_timer: float = 0.0
var knockback_duration: float = 0.15

var SPEED: float = 275.0

enum State {CHASE, WANDER, FLANK}
var current_state: State = State.CHASE
var state_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var flank_direction: Vector2 = Vector2.ZERO

var optimal_distance: float = 50.0
var ai_velocity: Vector2 = Vector2.ZERO
var distance_to_player: float
var ai_direction: Vector2
var push_velocity: Vector2
var pull_direction: Vector2 = Vector2.ZERO
var pull_velocity: Vector2 = Vector2.ZERO
var pull_dominance: float = 0.0

#var physics_frame_counter: int = 0

var special_variant_1: bool = false

func enable_special_variant_1():
	special_variant_1 = true
	
	scale = scale * 2.0
	
	minimum_damage *= 2
	maximum_damage *= 2
	
	SPEED *= 1.5
	
	max_health *= 5
	health = max_health
	
	enable_outline()

func _ready() -> void:
	if not special_variant_1:
		disable_outline()
	player = get_node("/root/world/player")
	animated_sprite.play("run")
	
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	facing_away_hitbox.monitoring = false
	facing_camera_hitbox.monitoring = false
	side_hitbox.monitoring = false
	
	#print("MOB1 SPAWN - Position: ", global_position)
	
	
			
func _physics_process(delta: float) -> void:
	#print("MOB1 DEBUG - Position: ", global_position, " Velocity: ", velocity)
	if is_dead:
		return
		
	#physics_frame_counter = (physics_frame_counter + 1) % 3
	#if physics_frame_counter != 0:
		#return
	
	if is_being_pushed and player:
		push_velocity = push_direction * PUSH_SPEED
		velocity = push_velocity
		move_and_slide()
		return
	
	if knockback_timer > 0:
		knockback_timer -= delta
		move_and_slide()
		return
	
	#state_timer += delta
	#
	#if state_timer >= 2.0:
		#state_timer = 0
		#
		#if current_state == State.CHASE:
			#var rand_value: float = randf()
			#if rand_value <= 0.15:
				#current_state = State.WANDER
				#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			#elif rand_value <= 0.35:
				#current_state = State.FLANK
				#flank_direction = calculate_flank_direction()
		#
		#elif current_state == State.WANDER:
			#var rand_value: float = randf()
			#if rand_value <= 0.70:
				#current_state = State.CHASE
			#elif rand_value <= 0.85:
				#current_state = State.FLANK
				#flank_direction = calculate_flank_direction()
		#
		#elif current_state == State.FLANK:
			#var rand_value: float = randf()
			#if rand_value <= 0.70:
				#current_state = State.CHASE
			#elif rand_value <= 0.80:
				#current_state = State.WANDER
				#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	attack_timer += delta
	
	if not is_inside_play_area():
		ai_direction = global_position.direction_to(Vector2.ZERO)
		#print("MOB1 DIRECTION - AI Direction (if outside play area): ", ai_direction, " Current state: ", current_state)
	elif current_state == State.CHASE:
		ai_direction = global_position.direction_to(player.global_position)
		#print("MOB1 DIRECTION - AI Direction (if in CHASE state): ", ai_direction, " Current state: ", current_state)
	#elif current_state == State.FLANK:
		#ai_direction = flank_direction
	#else:
		#ai_direction = wander_direction
	
	
	distance_to_player = global_position.distance_to(player.global_position)
	
	if not is_attacking and distance_to_player <= attack_range and attack_timer >= attack_cooldown:
		start_attack()
		attack_timer = 0.0
	
	
	if not is_attacking:
		if distance_to_player > optimal_distance:
			ai_velocity = ai_direction * SPEED
		
		if is_being_pulled_by_gravity_well:
			#print("MOB1 PULLED (before new calc) - Factor: ", gravity_well_factor, " Pull direction: ", pull_direction)
			#print("MOB1 PULLED (before new calc) - Pull velocity: ", pull_velocity, " Pull dominance: ", pull_dominance)
			pull_direction = global_position.direction_to(gravity_well_position)
			
			pull_velocity = pull_direction * gravity_well_strength * gravity_well_factor
			
			pull_dominance = pow(gravity_well_factor, 1.5)
			velocity = ai_velocity * (1.0 - pull_dominance) + pull_velocity * pull_dominance
			#print("MOB1 PULLED (AFTER new calc)- Factor: ", gravity_well_factor, " Pull direction: ", pull_direction)
			#print("MOB1 PULLED (AFTER new calc)- Pull velocity: ", pull_velocity, " Pull dominance: ", pull_dominance)
		else:
			velocity = ai_velocity
			
		if ai_direction.x != 0:
			animated_sprite.flip_h = ai_direction.x < 0
		
		if velocity != Vector2.ZERO:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
		
		#print("MOB1 FINAL VELOCITY: ", velocity, " Length: ", velocity.length())
		move_and_slide()
		
	if overlapping_player:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			damage = randi_range(minimum_damage, maximum_damage)
			if player.has_method("take_damage_from_mob1"):
				player.take_damage_from_mob1(damage)
			damage_timer = 0.0
	
func enable_outline() -> void:
	animated_sprite.material.set_shader_parameter("outline_enabled", true)

func disable_outline() -> void:
	animated_sprite.material.set_shader_parameter("outline_enabled", false)
			
			
func _on_frame_changed() -> void:
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
		

func start_attack() -> void:
	if is_dead:
		return
		
	is_attacking = true
	
	facing_away_hitbox.monitoring = false
	facing_camera_hitbox.monitoring = false
	side_hitbox.monitoring = false
	
	play_attack_animation()
	await animated_sprite.animation_finished
	end_attack()


func end_attack() -> void:
	if is_dead:
		return
		
	is_attacking = false
	facing_away_hitbox.monitoring = false
	facing_camera_hitbox.monitoring = false
	side_hitbox.monitoring = false
	attack_timer = 0.0
	animated_sprite.play("run")

func play_attack_animation() -> void:
	if is_dead:
		return
		
	var to_player: Vector2 = player.global_position - global_position
	
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
	return global_position.x >= -2050 and global_position.x <= 2050 and \
		   global_position.y >= -1470 and global_position.y <= 1430
		
func calculate_flank_direction() -> Vector2:
	var to_player: Vector2 = player.global_position - global_position
	var perpendicular: Vector2 = Vector2(-to_player.y, to_player.x).normalized()
	if randf() > 0.5:
		perpendicular = -perpendicular
	return (perpendicular * 0.8 + to_player.normalized() * 0.2).normalized()
			


func take_damage(damage_dealt: float = 10.0, knockback_amount: float = 250.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	
	health -= damage_dealt
	
	var damage_number: Node2D = FloatingDamageScene.instantiate()
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
		
		play_random_goblin_death_sound()
		
		stats_manager.add_enemy_kill("Torch Goblin")
		
		var coin_number: int = randi_range(1, 3)
		var x_offset: int = randi_range(-25, 25)
		var y_offset: int = randi_range(-25, 25)
		
		for i in range(coin_number):
			x_offset = randi_range(-25, 25)
			y_offset = randi_range(-25, 25)
			
			var coin: Area2D = CoinPoolManager.get_coin()
			if is_instance_valid(coin):
				coin.global_position = global_position + Vector2(x_offset, y_offset)
			else:
				print("ERROR: Failed to get coin from pool")
			
		if randf() < 0.03:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart: Area2D = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
		
		if randf() < 0.02:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball: Area2D = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		#var xp_amount = randi_range(2, 5)
		var xp_amount: int = 30
		var ui: CanvasLayer = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(1)
		queue_free()
	
	animation_player.stop()
	animation_player.play("hit_flash")
	
func play_random_goblin_death_sound():
	AudioManager.play_sound("goblin_death", global_position)


func heal(amount: int) -> void:
	if not is_instance_valid(self) or is_dead or health >= max_health:
		return
	
	var actual_heal: int = min(amount, max_health - health)
	health += actual_heal
	
	var heal_number: Node2D = FloatingHealScene.instantiate()
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
