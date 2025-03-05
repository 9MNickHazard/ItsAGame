extends CharacterBody2D


@onready var animated_sprite = $AnimatedSprite2D
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
@onready var los_ray: RayCast2D = $LOSRayCast

const TNTScene = preload("res://scenes/tnt.tscn")
const CoinScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene = preload("res://scenes/floating_damage.tscn")
const HeartScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene = preload("res://scenes/mana_ball.tscn")



# player pushback variables
var push_direction = Vector2.ZERO
var is_being_pushed = false
const PUSH_SPEED = 100.0

var player
var throw_range = 500.0
var throw_cooldown = 2.0
var throw_timer = 0.0
var health = 30.0
var is_throwing = false

var knockback_timer = 0.0
var knockback_duration = 0.15
const KNOCKBACK_AMOUNT = 250

const SPEED = 250.0

enum State {CHASE, WANDER}
var current_state = State.CHASE
var state_timer = 0.0
var wander_direction = Vector2.ZERO

func _ready() -> void:
	player = get_node("/root/world/player")
	animated_sprite.play("run")
	animated_sprite.frame_changed.connect(_on_frame_changed)
	

func _physics_process(delta):
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
			
	throw_timer += delta
			
	var direction
			
	if not is_inside_play_area():
		direction = global_position.direction_to(Vector2.ZERO)
	elif current_state == State.CHASE:
		direction = global_position.direction_to(player.global_position)
	else:
		direction = wander_direction
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Handle TNT throwing
	if distance_to_player <= throw_range and throw_timer >= throw_cooldown:
		throw_tnt()
		throw_timer = 0.0
	
	var optimal_distance = 400.0
	# Handle movement when not throwing
	if not is_throwing:
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
			

	

func throw_tnt():
	is_throwing = true
	animated_sprite.play("throw")
	await animated_sprite.animation_finished
	is_throwing = false
	animated_sprite.play("run")

func _on_frame_changed():
	if is_throwing and animated_sprite.animation == "throw" and animated_sprite.frame == 3:
		var new_tnt = TNTScene.instantiate()
		new_tnt.global_position = tnt_release_point.global_position
		get_parent().add_child(new_tnt)
		
		if player.velocity.length() > 0:
			var distance_to_player = global_position.distance_to(player.global_position)
			var time_to_reach = distance_to_player / new_tnt.TNT_SPEED
			
			var predicted_position = player.global_position + player.velocity * time_to_reach
			new_tnt.throw(predicted_position)
		else:
			new_tnt.throw(player.global_position)
			
func is_inside_play_area() -> bool:
	return global_position.x >= -1570 and global_position.x <= 1570 and \
		   global_position.y >= -970 and global_position.y <= 950

func take_damage(damage_dealt: float = 10.0, knockback_amount: float = 250.0, knockback_dir: Vector2 = Vector2.ZERO):
	health -= damage_dealt
	
	var damage_number = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage_dealt
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -30)
	
	if knockback_dir != Vector2.ZERO:
		velocity = knockback_dir * knockback_amount
		knockback_timer = knockback_duration
		
	if health <= 0:
		var coin_number = randi_range(2, 8)
		var x_offset = randi_range(5, 25)
		var y_offset = randi_range(5, 25)
		for i in range(coin_number):
			if randi() % 2 == 0 and coin_number > 1:
				x_offset = -x_offset
			if randi() % 2 == 0 and coin_number > 1:
				y_offset = -y_offset
			
			var coin = CoinPoolManager.get_coin()
			coin.global_position = global_position + Vector2(x_offset, y_offset)
			
		if randf() < 0.05:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var heart = HeartScene.instantiate()
			heart.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", heart)
		
		if randf() < 0.03:
			x_offset = randi_range(1, 25)
			y_offset = randi_range(1, 25)
			var manaball = ManaBallScene.instantiate()
			manaball.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", manaball)
			
		var xp_amount = 45
		var ui = get_node("/root/world/UI")
		if ui and ui.experience_manager:
			ui.experience_manager.add_experience(xp_amount)
			ui.increase_score(1)
		play_random_goblin_death_sound()
		goblin_death_sfx.play("DeathSFX")
		queue_free()
	
	animation_player.stop()
	animation_player.play("HitFlashTNTGoblin")

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
		
func _on_player_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = true
		push_direction = (global_position - player.global_position).normalized()


func _on_player_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		is_being_pushed = false
