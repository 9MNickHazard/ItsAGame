extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: CollisionShape2D = $Hurtbox
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var player_detector: Area2D = $PlayerDetector
@onready var hitbox: Area2D = $Hitbox
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

const CoinScene: PackedScene = preload("res://scenes/coin.tscn")
const FiveCoinScene: PackedScene = preload("res://scenes/5_coin.tscn")
const TwentyFiveCoinScene: PackedScene = preload("res://scenes/25_coin.tscn")
const FloatingDamageScene: PackedScene = preload("res://scenes/floating_damage.tscn")
const HeartScene: PackedScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene: PackedScene = preload("res://scenes/mana_ball.tscn")
const FloatingHealScene: PackedScene = preload("res://scenes/floating_heal.tscn")
const TreasureChestScene: PackedScene = preload("res://scenes/treasure_chest_pickup.tscn")

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
var normal_attack_range: int = 100
var whirlwind_charge_range: int = 600
var attack_cooldown: float = 2.0
var attack_timer: float = 0.0
var max_health: int = 200
var health: int = 200
var overlapping_player: bool = false
var damage_cooldown: float = 1.0
var damage_timer: float = 0.0
var minimum_damage: int = 10
var maximum_damage: int = 25
var damage: int

var knockback_timer: float = 0.0
var knockback_duration: float = 0.05

var SPEED: float = 320.0
var CHARGE_SPEED: float = SPEED * 1.5

# whirlwind charge attack
var is_charging_whirlwind: bool = false
var whirlwind_target_position: Vector2 = Vector2.ZERO
var whirlwind_direction: Vector2 = Vector2.ZERO
var optimal_distance: float = 100.0
var hitbox_active: bool = false

enum State {CHASE, CHARGING_WHIRLWIND}
var current_state: State = State.CHASE
var is_dead: bool = false

var ai_velocity: Vector2 = Vector2.ZERO
var distance_to_player: float
var ai_direction: Vector2
var push_velocity: Vector2
var pull_direction: Vector2 = Vector2.ZERO
var pull_velocity: Vector2 = Vector2.ZERO
var pull_dominance: float = 0.0

var special_variant_1: bool = false
var outline_material = null
var should_enable_outline: bool = false

var is_slowed: bool = false
var slow_timer: float = 0.0
var slow_duration: float = 0.0
var original_speed: float = 0.0

func enable_special_variant_1():
	special_variant_1 = true
	
	scale = scale * 2.0
	
	minimum_damage *= 2
	maximum_damage *= 2
	
	SPEED *= 1.5
	CHARGE_SPEED = SPEED * 1.5
	
	max_health *= 5
	health = max_health
	
	should_enable_outline = true

func _ready() -> void:
	player = get_node("/root/world/player")
	animated_sprite_2d.play("Idle")
	
	animated_sprite_2d.frame_changed.connect(_on_frame_changed)
	hitbox.monitoring = false
	
	if should_enable_outline:
		enable_outline()
	elif not special_variant_1:
		disable_outline()

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
	
	if is_slowed:
		slow_timer += delta
		if slow_timer >= slow_duration:
			is_slowed = false
			SPEED = original_speed
			CHARGE_SPEED = SPEED * 1.5
			animated_sprite_2d.speed_scale = 1.0
			animated_sprite_2d.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	if current_state == State.CHARGING_WHIRLWIND:
		velocity = whirlwind_direction * CHARGE_SPEED
		
		var distance_to_target = global_position.distance_to(whirlwind_target_position)
		if distance_to_target < 20:
			end_whirlwind()
			
		move_and_slide()
		return
	
	attack_timer += delta
	
	if not is_inside_play_area():
		ai_direction = global_position.direction_to(Vector2.ZERO)
	else:
		ai_direction = global_position.direction_to(player.global_position)
	
	distance_to_player = global_position.distance_to(player.global_position)
	
	if not is_attacking and attack_timer >= attack_cooldown and distance_to_player <= normal_attack_range:
		start_normal_attack()
		attack_timer = 0.0
	elif not is_attacking and not is_charging_whirlwind and attack_timer >= attack_cooldown and distance_to_player <= whirlwind_charge_range and distance_to_player > normal_attack_range and randf() <= 0.25:
		start_whirlwind_charge()
		attack_timer = 0.0
	
	if not is_attacking and current_state != State.CHARGING_WHIRLWIND:
		if distance_to_player > optimal_distance:
			ai_velocity = ai_direction * SPEED
		
		if is_being_pulled_by_gravity_well:
			pull_direction = global_position.direction_to(gravity_well_position)
			
			pull_velocity = pull_direction * gravity_well_strength * gravity_well_factor
			
			pull_dominance = pow(gravity_well_factor, 1.5)
			velocity = ai_velocity * (1.0 - pull_dominance) + pull_velocity * pull_dominance
		else:
			velocity = ai_velocity
		
		if velocity != Vector2.ZERO:
			animated_sprite_2d.play("Run")
			animated_sprite_2d.flip_h = velocity.x < 0
		else:
			animated_sprite_2d.play("Idle")
			
		move_and_slide()
	
	if overlapping_player:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			damage = randi_range(minimum_damage, maximum_damage)
			if player.has_method("take_damage_from_mob1"):
				player.take_damage_from_mob1(damage)
			damage_timer = 0.0

func enable_outline() -> void:
	if outline_material != null:
		animated_sprite_2d.material = outline_material
	elif animated_sprite_2d.material != null:
		animated_sprite_2d.material.set_shader_parameter("outline_enabled", true)

func disable_outline() -> void:
	if animated_sprite_2d.material != null:
		outline_material = animated_sprite_2d.material
		animated_sprite_2d.material = null

func _on_frame_changed() -> void:
	var current_anim = animated_sprite_2d.animation
	var current_frame = animated_sprite_2d.frame
	
	if current_anim == "WhirlwindAttack":
		if current_frame >= 2 and current_frame <= 8:
			if not hitbox_active:
				hitbox_active = true
				hitbox.monitoring = true
		else:
			hitbox_active = false
			hitbox.monitoring = false

func start_normal_attack() -> void:
	if is_dead:
		return
	
	is_attacking = true
	hitbox_active = false
	hitbox.monitoring = false
	
	animated_sprite_2d.play("WhirlwindAttack")
	
	await animated_sprite_2d.animation_finished
	end_attack()

func start_whirlwind_charge() -> void:
	if is_dead or is_being_pulled_by_gravity_well:
		return
	
	current_state = State.CHARGING_WHIRLWIND
	is_charging_whirlwind = true
	
	whirlwind_direction = global_position.direction_to(player.global_position).normalized()
	whirlwind_target_position = player.global_position + whirlwind_direction * 300.0
	
	hurtbox.disabled = true
	
	animated_sprite_2d.play("WhirlwindAttack")

func end_whirlwind() -> void:
	current_state = State.CHASE
	is_charging_whirlwind = false
	
	hurtbox.disabled = false
	
	hitbox_active = false
	hitbox.monitoring = false

func end_attack() -> void:
	is_attacking = false
	hitbox_active = false
	hitbox.monitoring = false
	attack_timer = 0.0

func is_inside_play_area() -> bool:
	return global_position.x >= -2050 and global_position.x <= 2050 and \
		   global_position.y >= -1470 and global_position.y <= 1430

func apply_slow_effect(duration: float) -> void:
	if not is_slowed:
		is_slowed = true
		original_speed = SPEED
		SPEED = SPEED * 0.5
		CHARGE_SPEED = SPEED * 1.5
		animated_sprite_2d.speed_scale = 0.5
		animated_sprite_2d.modulate = Color(0.5, 0.5, 1.0, 1.0) # blue
		
	slow_duration = duration
	slow_timer = 0.0

func take_damage(damage_dealt: int, knockback_amount: float = 250.0, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
		
	health -= damage_dealt
	
	var damage_number: Node2D = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage_dealt
	get_parent().add_child(damage_number)
	if special_variant_1:
		damage_number.global_position = global_position + Vector2(0, -130)
	else:
		damage_number.global_position = global_position + Vector2(0, -30)
	
	if knockback_dir != Vector2.ZERO:
		velocity = knockback_dir * knockback_amount
		knockback_timer = knockback_duration
		
	stats_manager.damage_dealt_to_enemies += damage_dealt
		
	if health <= 0:
		is_dead = true
		is_attacking = false
		
		if special_variant_1:
			stats_manager.add_enemy_kill("Special Elite Orc")
			
			var treasure_chest = TreasureChestScene.instantiate()
			treasure_chest.global_position = global_position
			get_parent().call_deferred("add_child", treasure_chest)
			
			var xp_amount: int = 600
			var ui: CanvasLayer = get_node("/root/world/UI")
			if ui and ui.experience_manager:
				ui.experience_manager.add_experience(xp_amount)
				ui.increase_score(15)
		else:
			stats_manager.add_enemy_kill("Elite Orc")
			
			var coin_number: int = randi_range(18, 38)
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
			
			if randf() < 0.08:
				x_offset = randi_range(1, 25)
				y_offset = randi_range(1, 25)
				var heart: Area2D = HeartScene.instantiate()
				heart.global_position = global_position + Vector2(x_offset, y_offset)
				get_parent().call_deferred("add_child", heart)
			
			if randf() < 0.05:
				x_offset = randi_range(1, 25)
				y_offset = randi_range(1, 25)
				var manaball: Area2D = ManaBallScene.instantiate()
				manaball.global_position = global_position + Vector2(x_offset, y_offset)
				get_parent().call_deferred("add_child", manaball)
			
			var xp_amount: int = 200
			var ui: CanvasLayer = get_node("/root/world/UI")
			if ui and ui.experience_manager:
				ui.experience_manager.add_experience(xp_amount)
				ui.increase_score(3)
		
		animated_sprite_2d.play("Death")
		await animated_sprite_2d.animation_finished
		queue_free()
	
	hit_flash.stop()
	hit_flash.play("hit_flash")

func heal(amount: int) -> void:
	if not is_instance_valid(self) or is_dead or health >= max_health:
		return
	
	var actual_heal: int = min(amount, max_health - health)
	health += actual_heal
	
	var heal_number: Node2D = FloatingHealScene.instantiate()
	heal_number.heal_amount = actual_heal
	get_parent().add_child(heal_number)
	if special_variant_1:
		heal_number.global_position = global_position + Vector2(0, -130)
	else:
		heal_number.global_position = global_position + Vector2(0, -30)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		damage = randi_range(minimum_damage, maximum_damage)
		overlapping_player = true
		if area.get_parent().has_method("take_damage_from_mob1"):
			area.get_parent().take_damage_from_mob1(damage)

func _on_hitbox_area_exited(area: Area2D) -> void:
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
