extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $HitFlashTNTGoblin
@onready var tnt_release_point: Marker2D = $"TNT Release Point"
@onready var goblin_sfx: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX
@onready var goblin_sfx_2: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX2
@onready var goblin_sfx_3: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX3
@onready var goblin_sfx_4: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX4
@onready var goblin_sfx_5: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX5
@onready var goblin_sfx_6: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX6
@onready var goblin_sfx_7: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX7
@onready var goblin_sfx_8: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX8
@onready var goblin_sfx_9: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX9
@onready var goblin_sfx_10: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX10
@onready var goblin_sfx_11: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX11
@onready var goblin_sfx_12: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX12
@onready var goblin_sfx_13: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX13
@onready var goblin_sfx_14: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX14
@onready var goblin_sfx_15: AudioStreamPlayer2D = $TNTGoblinSFX/GoblinSFX15
@onready var goblin_death_sfx: AnimationPlayer = $DeathSFX
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")

const TNTScene: PackedScene = preload("res://scenes/tnt.tscn")
const CoinScene: PackedScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene: PackedScene = preload("res://scenes/floating_damage.tscn")
const HeartScene: PackedScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene: PackedScene = preload("res://scenes/mana_ball.tscn")
const fivecoin_scene: PackedScene = preload("res://scenes/5_coin.tscn")
const FloatingHealScene: PackedScene = preload("res://scenes/floating_heal.tscn")

var is_being_pulled_by_gravity_well: bool = false
var gravity_well_position: Vector2 = Vector2.ZERO
var gravity_well_strength: float = 0.0
var gravity_well_factor: float = 0.0

var push_direction: Vector2 = Vector2.ZERO
var is_being_pushed: bool = false
const PUSH_SPEED: float = 100.0

var player: CharacterBody2D
var throw_range: float = 500.0
var throw_cooldown: float = 2.0
var throw_timer: float = 0.0
var max_health: int = 30
var health: int = 30
var is_throwing: bool = false
var is_dead: bool = false

var knockback_timer: float = 0.0
var knockback_duration: float = 0.15
const KNOCKBACK_AMOUNT: float = 250.0

var SPEED: float = 250.0

enum State {CHASE, WANDER}
var current_state: State = State.CHASE
var state_timer: float = 0.0
var wander_direction: Vector2 = Vector2.ZERO

var optimal_distance: float = 400.0
var ai_velocity: Vector2 = Vector2.ZERO
var distance_to_player: float
var ai_direction: Vector2
var push_velocity: Vector2
var pull_direction: Vector2 = Vector2.ZERO
var pull_velocity: Vector2 = Vector2.ZERO
var pull_dominance: float = 0.0

var special_variant_1: bool = false

func enable_special_variant_1():
	special_variant_1 = true
	
	scale = scale * 2.0
	
	#minimum_damage *= 2
	#maximum_damage *= 2
	
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
			
	throw_timer += delta
			
	
	if not is_inside_play_area():
		ai_direction = global_position.direction_to(Vector2.ZERO)
	elif current_state == State.CHASE:
		ai_direction = global_position.direction_to(player.global_position)
	#else:
		#ai_direction = wander_direction
	
	distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player <= throw_range and throw_timer >= throw_cooldown:
		throw_tnt()
		throw_timer = 0.0
	
	
	if not is_throwing:
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
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
			
		move_and_slide()
			

func enable_outline() -> void:
	animated_sprite.material.set_shader_parameter("outline_enabled", true)

func disable_outline() -> void:
	animated_sprite.material.set_shader_parameter("outline_enabled", false)

func throw_tnt() -> void:
	if is_dead:
		return
		
	is_throwing = true
	animated_sprite.play("throw")
	await animated_sprite.animation_finished
	is_throwing = false
	animated_sprite.play("run")

func _on_frame_changed() -> void:
	if is_throwing and animated_sprite.animation == "throw" and animated_sprite.frame == 3:
		var new_tnt: Area2D = TNTScene.instantiate()
		new_tnt.global_position = tnt_release_point.global_position
		get_parent().add_child(new_tnt)
		
		if player.velocity.length() > 0:
			var distance_to_player: float = global_position.distance_to(player.global_position)
			var time_to_reach: float = distance_to_player / new_tnt.TNT_SPEED
			
			var predicted_position: Vector2 = player.global_position + player.velocity * time_to_reach
			new_tnt.throw(predicted_position)
		else:
			new_tnt.throw(player.global_position)
			
func is_inside_play_area() -> bool:
	return global_position.x >= -2050 and global_position.x <= 2050 and \
		   global_position.y >= -1470 and global_position.y <= 1430

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
		is_throwing = false
		
		stats_manager.add_enemy_kill("TNT Goblin")
		
		var coin_number: int = randi_range(1, 5)
		var x_offset: int = randi_range(-25, 25)
		var y_offset: int = randi_range(-25, 25)
		
		if coin_number >= 5:
			var fivecoin: Area2D = fivecoin_scene.instantiate()
			fivecoin.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", fivecoin)
			
		else:
			for i in range(coin_number):
				x_offset = randi_range(-25, 25)
				y_offset = randi_range(-25, 25)
				
				var coin: Area2D = CoinPoolManager.get_coin()
				if is_instance_valid(coin):
					coin.global_position = global_position + Vector2(x_offset, y_offset)
			
		if randf() < 0.05:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart: Area2D = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
		
		if randf() < 0.03:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball: Area2D = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		var xp_amount: int = 45
		var ui: CanvasLayer = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(1)
		play_random_goblin_death_sound()
		goblin_death_sfx.play("DeathSFX")
		queue_free()
	
	animation_player.stop()
	animation_player.play("HitFlashTNTGoblin")

func play_random_goblin_death_sound() -> void:
	var sound_effect: int = randi_range(1, 15)
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
