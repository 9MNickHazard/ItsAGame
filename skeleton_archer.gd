extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_flash: AnimationPlayer = $HitFlash
@onready var attack_release_point: Marker2D = $AttackReleasePoint
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

const CoinScene: PackedScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene: PackedScene = preload("res://scenes/floating_damage.tscn")
const ATTACK: PackedScene = preload("res://scenes/skeleton_archer_arrow.tscn")
const HeartScene: PackedScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene: PackedScene = preload("res://scenes/mana_ball.tscn")
const fivecoin_scene: PackedScene = preload("res://scenes/5_coin.tscn")
const twentyfivecoin_scene: PackedScene = preload("res://scenes/25_coin.tscn")
const FloatingHealScene: PackedScene = preload("res://scenes/floating_heal.tscn")

var is_being_pulled_by_gravity_well: bool = false
var gravity_well_position: Vector2 = Vector2.ZERO
var gravity_well_strength: float = 0.0
var gravity_well_factor: float = 0.0

var push_direction: Vector2 = Vector2.ZERO
var is_being_pushed: bool = false
const PUSH_SPEED: int = 100

var player: CharacterBody2D
var attack_range: int = 800
var attack_cooldown: float = 2.0
var attack_timer: float = 0.0
var max_health: int = 70
var health: int = 70
var is_attacking: bool = false
var is_dead: bool = false

var knockback_timer: float = 0.0
var knockback_duration: float = 0.15
const KNOCKBACK_AMOUNT: int = 250

var SPEED: int = 175

enum State {CHASE, WANDER}
var current_state: State = State.CHASE
var state_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO

var optimal_distance: float = 600.0
var ai_velocity: Vector2 = Vector2.ZERO
var distance_to_player: float
var ai_direction: Vector2
var push_velocity: Vector2
var pull_direction: Vector2
var pull_velocity: Vector2
var pull_dominance: float

func _ready() -> void:
	player = get_node("/root/world/player")
	animated_sprite.play("Walk")
	animated_sprite.frame_changed.connect(_on_frame_changed)

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
	
	#state_timer += delta
	#
	#if state_timer >= 2.0:
		#state_timer = 0
		#if current_state == State.CHASE and randf() <= 0.2:
			#current_state = State.WANDER
			#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		#
		#elif current_state == State.WANDER and randf() <= 0.8:
			#current_state = State.CHASE
	
	attack_timer += delta
	
	if not is_inside_play_area():
		ai_direction = global_position.direction_to(Vector2.ZERO)
	elif current_state == State.CHASE:
		ai_direction = global_position.direction_to(player.global_position)
	#else:
		#ai_direction = wander_direction
		
	distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= attack_range and attack_timer >= attack_cooldown:
		use_attack()
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
			animated_sprite.play("Walk")
		else:
			animated_sprite.play("Idle")
			
		move_and_slide()
			

func _on_frame_changed() -> void:
	if is_attacking and animated_sprite.animation == "Attack" and animated_sprite.frame == 6:
		var attack_projectile: Node2D = ATTACK.instantiate()
		attack_projectile.global_position = attack_release_point.global_position
		attack_projectile.fire_projectile(player.global_position)
		get_parent().add_child(attack_projectile)
		
		
func use_attack() -> void:
	if is_dead:
		return
		
	is_attacking = true
	animated_sprite.play("Attack")
	await animated_sprite.animation_finished
	is_attacking = false
	animated_sprite.play("Walk")
	
	
func is_inside_play_area() -> bool:
	return global_position.x >= -2050 and global_position.x <= 2050 and \
		   global_position.y >= -1470 and global_position.y <= 1430

func take_damage(damage_dealt: int = 10, knockback_amount: int = 250, knockback_dir: Vector2 = Vector2.ZERO) -> void:
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
		
		stats_manager.add_enemy_kill("Skeleton Archer")
		
		var coin_number: int = randi_range(4, 12)
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
				var twentyfivecoin: Area2D = twentyfivecoin_scene.instantiate()
				twentyfivecoin.global_position = global_position + Vector2(x_offset, y_offset)
				get_parent().call_deferred("add_child", twentyfivecoin)
				
		if five_count != 0:
			for i in range(five_count):
				x_offset = randi_range(-25, 25)
				y_offset = randi_range(-25, 25)
				var fivecoin: Area2D = fivecoin_scene.instantiate()
				fivecoin.global_position = global_position + Vector2(x_offset, y_offset)
				get_parent().call_deferred("add_child", fivecoin)
				
		if one_count != 0:
			for i in range(one_count):
				x_offset = randi_range(-25, 25)
				y_offset = randi_range(-25, 25)
				var coin: Area2D = CoinPoolManager.get_coin()
				coin.global_position = global_position + Vector2(x_offset, y_offset)
			
					
		if randf() < 0.06:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart: Area2D = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
			
		if randf() < 0.04:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball: Area2D = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		var xp_amount: int = 80
		var ui: CanvasLayer = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(3)
		animated_sprite.play("Death")
		await animated_sprite.animation_finished
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
	heal_number.global_position = global_position + Vector2(0, -30)
	
	
func _on_player_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = true
		push_direction = (global_position - player.global_position).normalized()


func _on_player_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = false
