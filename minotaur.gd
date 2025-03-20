extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_down_hitbox:Area2D = $AttackDownHitbox
@onready var attack_right_hitbox:Area2D = $AttackRightHitbox
@onready var attack_up_hitbox:Area2D = $AttackUpHitbox
@onready var horn_attack_down_hitbox:Area2D = $HornAttackDownHitbox
@onready var horn_attack_right_hitbox:Area2D = $HornAttackRightHitbox
@onready var horn_attack_up_hitbox:Area2D = $HornAttackUpHitbox
@onready var stomp_down_hitbox:Area2D = $StompDownHitbox
@onready var stomp_right_hitbox:Area2D = $StompRightHitbox
@onready var stomp_up_hitbox:Area2D = $StompUpHitbox
@onready var charge_hitbox:Area2D = $ChargeHitbox
@onready var stats_manager:Node2D = get_node("/root/world/StatsManager")

const CoinScene: PackedScene = preload("res://scenes/coin.tscn")
const FiveCoinScene: PackedScene = preload("res://scenes/5_coin.tscn")
const TwentyFiveCoinScene: PackedScene = preload("res://scenes/25_coin.tscn")
const FloatingDamageScene: PackedScene = preload("res://scenes/floating_damage.tscn")
const HeartScene: PackedScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene: PackedScene = preload("res://scenes/mana_ball.tscn")
const FloatingHealScene: PackedScene = preload("res://scenes/floating_heal.tscn")

# gravity well variables
var is_being_pulled_by_gravity_well: bool = false
var gravity_well_position: Vector2 = Vector2.ZERO
var gravity_well_strength: float = 0.0
var gravity_well_factor: float = 0.0

# player pushback variables
var push_direction: Vector2 = Vector2.ZERO
var is_being_pushed: bool = false
const PUSH_SPEED: float = 50.0

var player: CharacterBody2D
var is_attacking: bool = false
var attack_range: int = 150
var attack_cooldown: float = 2.0
var attack_timer: float = 0.0
var max_health: int = 500
var health: int = 500
var overlapping_player: bool = false
var damage_cooldown: float = 1.0
var damage_timer: float = 0.0
var minimum_damage: int = 15
var maximum_damage: int = 35
var horn_minimum_damage: int = 25
var horn_maximum_damage: int = 45
var charge_minimum_damage: int = 10
var charge_maximum_damage: int = 20
var damage: int

var knockback_timer: float = 0.0
var knockback_duration: float = 0.05
const KNOCKBACK_AMOUNT: float = 25.0

var SPEED: float = 415.0
const CHARGE_SPEED: float = 1100.0

# Charge attack properties
var charge_cooldown: float = 5.0
var charge_timer: float = 0.0
var is_charging: bool = false
var charge_prep_time: float = 1.0
var charge_prep_timer: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO
var charge_duration: float = 1.5
var charge_active_timer: float = 0.0
var charge_distance: float = 900.0
var charge_attack_range: float = 750.0
var charge_target_position: Vector2 = Vector2.ZERO
var distance_to_target: float

enum State {CHASE, WANDER, CHARGING, CHARGE_ATTACK}
var current_state: State = State.CHASE
var state_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO
var is_dead: bool = false

var optimal_distance: float = 100.0
var ai_velocity: Vector2 = Vector2.ZERO
var distance_to_player: float
var ai_direction: Vector2
var push_velocity: Vector2
var pull_direction: Vector2
var pull_velocity: Vector2
var pull_dominance: float

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
	animated_sprite.play("IdleDown")
	
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	disable_all_hitboxes()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if is_being_pushed and player:
		push_velocity = push_direction * PUSH_SPEED
		velocity = push_velocity
		move_and_slide()
		return
		
	if knockback_timer > 0:
		knockback_timer -= delta
		move_and_slide()
		return
	
	# Handle charging state
	if current_state == State.CHARGING:
		charge_prep_timer += delta
		if charge_prep_timer >= charge_prep_time:
			# Start the actual charge attack
			current_state = State.CHARGE_ATTACK
			charge_direction = global_position.direction_to(player.global_position).normalized()
			charge_target_position = global_position + charge_direction * charge_distance
			charge_active_timer = 0.0
			# Set appropriate running animation based on direction
			set_directional_animation("Run", charge_direction)
		return
		
	if current_state == State.CHARGE_ATTACK:
		charge_active_timer += delta
		if charge_active_timer < charge_duration:
			velocity = charge_direction * CHARGE_SPEED
			charge_hitbox.monitoring = true
			distance_to_target = global_position.distance_to(charge_target_position)
			if distance_to_target < 20:
				perform_horn_attack()
				return
			move_and_slide()
			return
		else:
			current_state = State.CHASE
			charge_hitbox.monitoring = false
			
	#state_timer += delta
	attack_timer += delta
	charge_timer += delta
	
	#if state_timer >= 2.0:
		#state_timer = 0
		#if current_state == State.CHASE and randf() <= 0.2:
			#current_state = State.WANDER
			#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		#
		#elif current_state == State.WANDER and randf() <= 0.8:
			#current_state = State.CHASE
	
	if not is_inside_play_area():
		ai_direction = global_position.direction_to(Vector2.ZERO)
	elif current_state == State.CHASE:
		ai_direction = global_position.direction_to(player.global_position)
	#else:
		#ai_direction = wander_direction
	
	distance_to_player = global_position.distance_to(player.global_position)
	
	if not is_attacking and charge_timer >= charge_cooldown and distance_to_player <= charge_attack_range and distance_to_player > optimal_distance and randf() <= 0.3:
		start_charge()
		charge_timer = 0.0
		return
	
	if not is_attacking and attack_timer >= attack_cooldown and distance_to_player <= attack_range:
		if randf() <= 0.7:
			start_attack()
		else:
			start_stomp_attack()
		attack_timer = 0.0
	
	
	if not is_attacking:
		if distance_to_player > optimal_distance:
			ai_velocity = ai_direction * SPEED
		
		if is_being_pulled_by_gravity_well:
			pull_direction = global_position.direction_to(gravity_well_position)
			
			pull_velocity = pull_direction * gravity_well_strength * gravity_well_factor
			
			pull_dominance = pow(gravity_well_factor, 1.5)
			velocity = ai_velocity * (1.0 - pull_dominance) + pull_velocity * pull_dominance
		else:
			velocity = ai_velocity
			
		if ai_direction.x != 0:
			animated_sprite.flip_h = ai_direction.x < 0
			
		if velocity != Vector2.ZERO:
			set_directional_animation("Run", ai_direction)
		else:
			set_directional_animation("Idle", ai_direction)
			
		move_and_slide()
		
	if overlapping_player:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			if player.has_method("take_damage_from_mob1"):
				player.take_damage_from_mob1(damage)
			damage_timer = 0.0

func enable_outline() -> void:
	animated_sprite.material.set_shader_parameter("outline_enabled", true)

func disable_outline() -> void:
	animated_sprite.material.set_shader_parameter("outline_enabled", false)

func set_directional_animation(anim_type, direction):
	var dir_suffix = "Down"
	
	if abs(direction.x) > abs(direction.y):
		dir_suffix = "Right"
		animated_sprite.flip_h = direction.x < 0
	else:
		animated_sprite.flip_h = false
		if direction.y < 0:
			dir_suffix = "Up"
		else:
			dir_suffix = "Down"
	
	animated_sprite.play(anim_type + dir_suffix)
	return dir_suffix

func _on_frame_changed() -> void:
	if is_attacking:
		var current_anim = animated_sprite.animation
		var current_frame = animated_sprite.frame
		
		if current_frame == 3:
			if current_anim == "AttackDown":
				attack_down_hitbox.monitoring = true
			elif current_anim == "AttackRight":
				attack_right_hitbox.monitoring = true
			elif current_anim == "AttackUp":
				attack_up_hitbox.monitoring = true
			elif current_anim == "HornAttackDown":
				horn_attack_down_hitbox.monitoring = true
			elif current_anim == "HornAttackRight":
				horn_attack_right_hitbox.monitoring = true
			elif current_anim == "HornAttackUp":
				horn_attack_up_hitbox.monitoring = true
			elif current_anim == "StompDown":
				stomp_down_hitbox.monitoring = true
			elif current_anim == "StompRight":
				stomp_right_hitbox.monitoring = true
			elif current_anim == "StompUp":
				stomp_up_hitbox.monitoring = true
		
		elif current_frame > 4:
			disable_all_hitboxes()

func start_attack() -> void:
	if is_dead:
		return
	
	is_attacking = true
	
	disable_all_hitboxes()
	
	var direction: Vector2 = global_position.direction_to(player.global_position)
	var dir_suffix = set_directional_animation("Attack", direction)
	
	await animated_sprite.animation_finished
	end_attack()

func start_stomp_attack() -> void:
	if is_dead:
		return
	
	is_attacking = true
	
	disable_all_hitboxes()
	
	var direction: Vector2 = global_position.direction_to(player.global_position)
	var dir_suffix = set_directional_animation("Stomp", direction)
	
	await animated_sprite.animation_finished
	end_attack()

func perform_horn_attack() -> void:
	if is_dead:
		return
	
	is_attacking = true
	current_state = State.CHASE
	charge_hitbox.monitoring = false
	
	disable_all_hitboxes()
	
	var dir_suffix = ""
	if abs(charge_direction.x) > abs(charge_direction.y):
		dir_suffix = "Right"
		animated_sprite.flip_h = charge_direction.x < 0
	else:
		animated_sprite.flip_h = false
		if charge_direction.y < 0:
			dir_suffix = "Up"
		else:
			dir_suffix = "Down"
	
	animated_sprite.play("HornAttack" + dir_suffix)
	
	await animated_sprite.animation_finished
	end_attack()

func end_attack() -> void:
	is_attacking = false
	disable_all_hitboxes()
	attack_timer = 0.0

func start_charge() -> void:
	current_state = State.CHARGING
	charge_prep_timer = 0.0
	animation_player.play("charge_up")

func disable_all_hitboxes() -> void:
	attack_down_hitbox.monitoring = false
	attack_right_hitbox.monitoring = false
	attack_up_hitbox.monitoring = false
	horn_attack_down_hitbox.monitoring = false
	horn_attack_right_hitbox.monitoring = false
	horn_attack_up_hitbox.monitoring = false
	stomp_down_hitbox.monitoring = false
	stomp_right_hitbox.monitoring = false
	stomp_up_hitbox.monitoring = false
	charge_hitbox.monitoring = false

func disable_attack_hitboxes() -> void:
	attack_down_hitbox.monitoring = false
	attack_right_hitbox.monitoring = false
	attack_up_hitbox.monitoring = false

func disable_horn_attack_hitboxes() -> void:
	horn_attack_down_hitbox.monitoring = false
	horn_attack_right_hitbox.monitoring = false
	horn_attack_up_hitbox.monitoring = false

func disable_stomp_hitboxes() -> void:
	stomp_down_hitbox.monitoring = false
	stomp_right_hitbox.monitoring = false
	stomp_up_hitbox.monitoring = false

func is_inside_play_area() -> bool:
	return global_position.x >= -2050 and global_position.x <= 2050 and \
		   global_position.y >= -1470 and global_position.y <= 1430

func take_damage(damage_dealt: int, knockback_amount: float = 250.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
		
	health -= damage_dealt
	
	var damage_number: Node2D = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage_dealt
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -30)
	
	#if knockback_dir != Vector2.ZERO:
		#velocity = knockback_dir * knockback_amount
		#knockback_timer = knockback_duration
		
	stats_manager.damage_dealt_to_enemies += damage_dealt
		
	if health <= 0:
		is_dead = true
		is_attacking = false
		
		stats_manager.add_enemy_kill("Minotaur")
		
		var coin_number: int = randi_range(25, 50)
		var x_offset: int = randi_range(5, 25)
		var y_offset: int = randi_range(5, 25)
		var twentyfive_count: int = int(coin_number / 25)
		var remainder: int = coin_number % 25
		var five_count: int = int(remainder / 5)
		var one_count: int = remainder % 5
		
		if twentyfive_count != 0:
			for i in range(twentyfive_count):
				x_offset = randi_range(-25, 25)
				y_offset = randi_range(-25, 25)
				var twentyfivecoin: Area2D = TwentyFiveCoinScene.instantiate()
				twentyfivecoin.global_position = global_position + Vector2(x_offset, y_offset)
				get_parent().call_deferred("add_child", twentyfivecoin)
				
		if five_count != 0:
			for i in range(five_count):
				x_offset = randi_range(-25, 25)
				y_offset = randi_range(-25, 25)
				var fivecoin: Area2D = FiveCoinScene.instantiate()
				fivecoin.global_position = global_position + Vector2(x_offset, y_offset)
				get_parent().call_deferred("add_child", fivecoin)
				
		if one_count != 0:
			for i in range(one_count):
				x_offset = randi_range(-25, 25)
				y_offset = randi_range(-25, 25)
				var coin: Area2D = CoinPoolManager.get_coin()
				if is_instance_valid(coin):
					coin.global_position = global_position + Vector2(x_offset, y_offset)
			
		if randf() < 0.13:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart: Area2D = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
			
		if randf() < 0.10:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball: Area2D = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		var xp_amount: int = 400
		var ui: CanvasLayer = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(5)
			
		var current_anim = animated_sprite.animation
		if current_anim.ends_with("Down") or current_anim == "":
			animated_sprite.play("DeathDown")
		elif current_anim.ends_with("Right"):
			animated_sprite.play("DeathRight")
		else:
			animated_sprite.play("DeathUp")
		
		await animated_sprite.animation_finished
		queue_free()
	
	animation_player.stop()
	animation_player.play("hit_flash")
	
func heal(amount: int) -> void:
	if not is_instance_valid(self) or is_dead or health >= max_health:
		return
	
	var actual_heal: int = min(amount, max_health - health)
	health += actual_heal
	
	var heal_number: Node2D = FloatingHealScene.instantiate()
	heal_number.heal_amount = actual_heal
	get_parent().add_child(heal_number)
	heal_number.global_position = global_position + Vector2(0, -30)
	
	
func _on_attack_down_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_attack_right_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_attack_up_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)


func _on_horn_attack_down_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(horn_minimum_damage, horn_maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_horn_attack_right_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(horn_minimum_damage, horn_maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_horn_attack_up_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(horn_minimum_damage, horn_maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)


func _on_stomp_down_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_stomp_right_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_stomp_up_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)


func _on_charge_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(charge_minimum_damage, charge_maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)


func _on_player_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = true
		push_direction = (global_position - player.global_position).normalized()

func _on_player_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = false


func _on_attack_down_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_attack_right_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_attack_up_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_horn_attack_down_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_horn_attack_right_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_horn_attack_up_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_stomp_down_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_stomp_right_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_stomp_up_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0

func _on_charge_hitbox_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		overlapping_player = false
		damage_timer = 0.0
