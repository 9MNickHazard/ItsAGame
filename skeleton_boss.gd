extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var hp_bar = $HpBar

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

@onready var stats_manager = get_node("/root/world/StatsManager")

const CoinScene = preload("res://scenes/coin.tscn")
const FloatingDamageScene = preload("res://scenes/floating_damage.tscn")
const HeartScene = preload("res://scenes/heart_pickup.tscn")
const ManaBallScene = preload("res://scenes/mana_ball.tscn")
const SkeletonProjectile = preload("res://scenes/skeleton_boss_projectile.tscn")
const DiamondScene = preload("res://scenes/diamond.tscn")
const fivecoin_scene = preload("res://scenes/5_coin.tscn")
const twentyfivecoin_scene = preload("res://scenes/25_coin.tscn")
const FloatingHealScene = preload("res://scenes/floating_heal.tscn")

var health = 5000.0
var max_health = 5000.0
var is_dead = false

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

const SPEED = 500.0
const CHARGE_SPEED = 1200.0

enum State {CHASE, CHARGING, CHARGE_ATTACK}
var current_state = State.CHASE
var state_timer = 0.0
var player = null

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
	
	hp_bar.max_value = max_health
	hp_bar.value = health
	
	animated_sprite.play("DownIdle")
	
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	disable_all_hitboxes()

func _physics_process(delta):
	if is_dead:
		return
	
	if current_state == State.CHARGING:
		charge_prep_timer += delta
		if charge_prep_timer >= charge_prep_time:
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
			current_state = State.CHASE
			charge_attack.monitoring = false
			
	state_timer += delta
	if state_timer >= 3.0:
		state_timer = 0
	
	attack_timer += delta
	charge_timer += delta
	
	var direction
	
	if not is_inside_play_area():
		direction = global_position.direction_to(Vector2.ZERO)
	else:
		direction = global_position.direction_to(player.global_position)

	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if not is_attacking and charge_timer >= charge_cooldown and distance_to_player <= 700 and distance_to_player > 300 and randf() <= 0.6:
		start_charge()
		charge_timer = 0.0
		return
		
	if not is_attacking and attack_timer >= attack_cooldown:
		if distance_to_player <= attack3_range and distance_to_player > attack_range:
			choose_attack(3)
			attack_timer = 0.0
			return
		elif distance_to_player <= attack_range:
			choose_attack()
			attack_timer = 0.0
			return
	
	var optimal_distance = 150.0
	
	if not is_attacking and current_state != State.CHARGING and current_state != State.CHARGE_ATTACK:
		if distance_to_player > optimal_distance:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
			
		update_animation(direction)
		move_and_slide()
	
	if overlapping_player:
		damage_timer += delta
		if damage_timer >= damage_cooldown:
			if player.has_method("take_damage_from_mob1"):
				player.take_damage_from_mob1(damage)
			damage_timer = 0.0

func update_animation(direction):
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
	
	disable_all_hitboxes()
	
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
	
	var to_player = player.global_position - global_position
	
	if abs(to_player.y) > abs(to_player.x):
		if to_player.y > 0:
			play_attack_animation("Down", attack_type)
		else:
			play_attack_animation("Up", attack_type)
	else:
		animated_sprite.flip_h = to_player.x < 0
		
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
	if is_dead:
		return
		
	is_attacking = false
	disable_all_hitboxes()
	attack_timer = 0.0
	
	var current_anim = animated_sprite.animation
	if current_anim.begins_with("Down"):
		animated_sprite.play("DownIdle")
	elif current_anim.begins_with("Up"):
		animated_sprite.play("UpIdle")
	else:
		animated_sprite.play("SideIdle")

func disable_all_hitboxes():
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
	
	if current_frame == 5:
		if current_anim == "DownAttack1":
			down_attack1.monitoring = true
		elif current_anim == "SideAttack1":
			side_attack1.monitoring = true
		elif current_anim == "UpAttack1":
			up_attack1.monitoring = true
		elif current_anim == "DownAttack3" or current_anim == "SideAttack3" or current_anim == "UpAttack3":
			spawn_projectiles()
			
	if current_anim.ends_with("Attack2"):
		if current_frame == 3:
			if current_anim == "DownAttack2":
				down_attack2_1.monitoring = true
			elif current_anim == "SideAttack2":
				side_attack2_1.monitoring = true
			elif current_anim == "UpAttack2":
				up_attack2_1.monitoring = true
		elif current_frame == 6:
			if current_anim == "DownAttack2":
				down_attack2_1.monitoring = false
				down_attack2_2.monitoring = true
			elif current_anim == "SideAttack2":
				side_attack2_1.monitoring = false
				side_attack2_2.monitoring = true
			elif current_anim == "UpAttack2":
				up_attack2_1.monitoring = false
				up_attack2_2.monitoring = true
		elif current_frame == 9:
			if current_anim == "DownAttack2":
				down_attack2_2.monitoring = false
				down_attack2_3.monitoring = true
			elif current_anim == "SideAttack2":
				side_attack2_2.monitoring = false
				side_attack2_3.monitoring = true
			elif current_anim == "UpAttack2":
				up_attack2_2.monitoring = false
				up_attack2_3.monitoring = true
		elif current_frame == 10:
			if current_anim == "DownAttack2":
				down_attack2_3.monitoring = false
			elif current_anim == "SideAttack2":
				side_attack2_3.monitoring = false
			elif current_anim == "UpAttack2":
				up_attack2_3.monitoring = false

func spawn_projectiles():
	var directions = [
		Vector2.RIGHT,                # E
		Vector2(1, -1).normalized(),  # NE
		Vector2.UP,                   # N
		Vector2(-1, -1).normalized(), # NW
		Vector2.LEFT,                 # W
		Vector2(-1, 1).normalized(),  # SW
		Vector2.DOWN,                 # S
		Vector2(1, 1).normalized()    # SE
	]
	
	for dir in directions:
		var projectile = SkeletonProjectile.instantiate()
		projectile.global_position = global_position
		projectile.direction = dir
		get_parent().add_child(projectile)

func start_charge():
	if is_dead:
		return
		
	current_state = State.CHARGING
	charge_prep_timer = 0.0
	animation_player.play("charge_up")
	

func is_inside_play_area() -> bool:
	return global_position.x >= -1570 and global_position.x <= 1570 and \
		   global_position.y >= -970 and global_position.y <= 950

func take_damage(damage_dealt: float = 10.0, knockback_amount: float = 250.0, knockback_dir: Vector2 = Vector2.ZERO):
	if is_dead:
		return
		
	health -= damage_dealt
	hp_bar.value = health
	
	var damage_number = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage_dealt
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -50)
	
	#animation_player.stop()
	#animation_player.play("hit_flash")
	
	stats_manager.damage_dealt_to_enemies += damage_dealt
	
	if health <= 0:
		die()

func die():
	is_dead = true
	is_attacking = false
	
	stats_manager.add_enemy_kill("Boss: Skeleton General")
	
	disable_all_hitboxes()
	
	var current_anim = animated_sprite.animation
	if current_anim.begins_with("Down"):
		animated_sprite.play("DownDeath")
	elif current_anim.begins_with("Up"):
		animated_sprite.play("UpDeath") 
	else:
		animated_sprite.play("SideDeath")
	
	var diamond_number = randi_range(2, 5)
	for i in range(diamond_number):
		var diamond = DiamondScene.instantiate()
		var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
		diamond.global_position = global_position + offset
		get_parent().call_deferred("add_child", diamond)
	
	var coin_number = randi_range(15, 60)
	var x_offset
	var y_offset
	
	var twentyfive_count = int(coin_number / 25)
	var remainder = coin_number % 25
	var five_count = int(remainder / 5)
	var one_count = remainder % 5
	
	if twentyfive_count != 0:
		for i in range(twentyfive_count):
			x_offset = randi_range(-80, 80)
			y_offset = randi_range(-80, 80)
			var twentyfivecoin = twentyfivecoin_scene.instantiate()
			twentyfivecoin.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", twentyfivecoin)
			
	if five_count != 0:
		for i in range(five_count):
			x_offset = randi_range(-80, 80)
			y_offset = randi_range(-80, 80)
			var fivecoin = fivecoin_scene.instantiate()
			fivecoin.global_position = global_position + Vector2(x_offset, y_offset)
			get_parent().call_deferred("add_child", fivecoin)
			
	if one_count != 0:
		for i in range(one_count):
			x_offset = randi_range(-80, 80)
			y_offset = randi_range(-80, 80)
			var coin = CoinPoolManager.get_coin()
			coin.global_position = global_position + Vector2(x_offset, y_offset)
	
	for i in range(3):
		var heart = HeartScene.instantiate()
		heart.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_parent().call_deferred("add_child", heart)
	
	for i in range(2):
		var manaball = ManaBallScene.instantiate()
		manaball.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_parent().call_deferred("add_child", manaball)
	
	var xp_amount = 6000
	var ui = get_node("/root/world/UI")
	if ui and ui.experience_manager:
		ui.experience_manager.add_experience(xp_amount)
		ui.increase_score(100)
	
	await animated_sprite.animation_finished
	queue_free()
	
func heal(amount: float):
	if not is_instance_valid(self) or is_dead or health >= max_health:
		return
	
	var actual_heal = min(amount, max_health - health)
	health += actual_heal
	
	var heal_number = FloatingHealScene.instantiate()
	heal_number.heal_amount = actual_heal
	get_parent().add_child(heal_number)
	heal_number.global_position = global_position + Vector2(0, -30)


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
