# player.gd
extends CharacterBody2D

@onready var gun: Area2D = $gun
@onready var gun_2: Area2D = $gun2
@onready var sniper_1: Area2D = $sniper1
@onready var rocket_launcher: Area2D = $RocketLauncher
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var blink: AnimationPlayer = $blink
@onready var mana_bar: ProgressBar = get_node("/root/world/UI/ManaBar")
@onready var mana_particles: GPUParticles2D = get_node("/root/world/UI/ManaBar/ManaBarFullParticles")
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_collision: CollisionShape2D = $player_hurtbox/CollisionShape2D
@onready var blink_cooldown_bar: ProgressBar = $BlinkCooldownBar
@onready var player_health_bar: ProgressBar = $HealthBar
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")
@onready var shotgun: Area2D = $Shotgun

signal health_changed(new_health)
signal health_depleted
signal max_health_changed(new_max_health)
signal mana_changed(new_mana: float)
signal max_mana_changed(new_max_mana: float)

const FloatingDamageScene: PackedScene = preload("res://scenes/player_floating_damage.tscn")
const FireBlinkScene: PackedScene = preload("res://scenes/fire_blink.tscn")
const ShockwaveScene: PackedScene = preload("res://scenes/shockwave.tscn")
const GravityWellScene: PackedScene = preload("res://scenes/gravity_well.tscn")
const OrbitalAbilityScene: PackedScene = preload("res://scenes/orbital_ability.tscn")

#const PauseMenuScript = preload("res://scripts/pause_menu.gd")

# gravity well ability
var gravity_well_mana_cost: float = 50.0
var gravity_well_cooldown: float = 8.0
var gravity_well_timer: float = 0.0


# blink variables
var can_blink: bool = true
var blink_cooldown: float = 5.0
var blink_timer: float = 0.0
var blink_cooldown_progress: float = 1.0


const BLINK_DISTANCE = 400.0
var blinking: bool = false
const BLINK_SPEED = 1700.0
var blink_target_position: Vector2 = Vector2.ZERO
var blink_direction: Vector2 = Vector2.ZERO

# mana variables
static var max_mana: float = 100.0
var current_mana: float = 100.0
static var permanent_mana_bonus: float = 0.0

var shockwave_mana_cost: float = 50.0
var orbital_ability_mana_cost: float = 50.0
var orbital_ability_active: bool = false

static var max_health: float = 100.0
var health: float = 100.0
static var permanent_health_bonus: float = 0.0

static var speed: float = 450.0 
static var permanent_speed_bonus: float = 0.0 
var acceleration: float = 4000.0
var friction: float = 4000.0
var direction: String = "none"

# upgrade related variables
var owns_gun1: bool = true
var owns_gun2: bool = false
var owns_sniper1: bool = false
var owns_rocketlauncher: bool = false
var owns_shotgun: bool = false
var owns_fire_blink: bool = false
var owns_gravity_well: bool = false
var owns_orbital_ability: bool = true

var equip_gun1: bool = true
var equip_gun2: bool = false
var equip_sniper1: bool = false
var equip_rocketlauncher: bool = false
var equip_shotgun: bool = false

# curesed powerup variables
static var damage_multiplier: bool = false
static var weapon_restriction: bool = false
static var ability_mana_reduction: bool = false

static var has_revive: bool = false
var revive_used: bool = false

static var mana_regen_rate: float = 0.0
var total_mana_regen_rate: float
static var hp_regen_rate: float = 0.0

static var armor: int = 0

func _ready() -> void:
	update_gun_states()
	
	speed += permanent_speed_bonus
	
	max_mana += permanent_mana_bonus
	current_mana = max_mana
	mana_bar.max_value = int(max_mana)
	mana_bar.value = int(current_mana)
	
	blink_cooldown_bar.visible = false
	blink_cooldown_bar.value = 0.0
	
	can_blink = true
	blink_cooldown_progress = 1.0
	
	max_health += permanent_health_bonus
	health = max_health
	player_health_bar.max_value = int(floor(max_health))
	player_health_bar.value = int(floor(health))
	
	health_changed.connect(_on_player_health_changed_local)
	max_health_changed.connect(_on_player_max_health_changed_local)

func _physics_process(delta: float) -> void:
	total_mana_regen_rate = mana_regen_rate
	
	if weapon_restriction:
		total_mana_regen_rate += 1.0
	
	if total_mana_regen_rate > 0.0 and current_mana < max_mana:
		current_mana = min(current_mana + total_mana_regen_rate * delta, max_mana)
		mana_bar.value = current_mana
		mana_changed.emit(current_mana)
		
	if hp_regen_rate > 0.0 and health < max_health:
		health = min(health + hp_regen_rate * delta, max_health)
		player_health_bar.value = health
		health_changed.emit(health)
		
	if !can_blink:
		if !blink_cooldown_bar.visible:
			blink_cooldown_bar.visible = true
			
		blink_timer += delta
		blink_cooldown_progress = blink_timer / blink_cooldown
		
		blink_cooldown_bar.value = blink_cooldown_progress
		
		if blink_timer >= blink_cooldown:
			can_blink = true
			blink_cooldown_progress = 1.0
			blink_timer = 0.0
			
			blink_cooldown_bar.visible = false
	
	if gravity_well_timer > 0:
		gravity_well_timer -= delta
		
	
	if blinking:
		var distance_to_target: float = global_position.distance_to(blink_target_position)
		if distance_to_target > 10:
			velocity = blink_direction * BLINK_SPEED
			move_and_slide()
		else:
			blinking = false
			blink.play("blink_in")
			velocity = Vector2.ZERO
			
			collision_shape.disabled = false
			hurtbox_collision.disabled = false
	else:
		player_movement(delta)
		handle_blink()
		handle_shockwave()
		handle_gravity_well()
		handle_orbital_ability()
	
	if Input.is_action_just_released("scroll_up"):
		switch_weapon(-1)
	elif Input.is_action_just_released("scroll_down"):
		switch_weapon(1)
		
static func set_max_health(value: float) -> void:
	max_health = value + permanent_health_bonus
	
	var player: CharacterBody2D = Engine.get_main_loop().get_root().get_node("world/player")
	if player:
		player.max_health_changed.emit(value + permanent_health_bonus)
		
static func set_max_mana(value: float) -> void:
	max_mana = float(value) + permanent_mana_bonus
	
	var player: CharacterBody2D = Engine.get_main_loop().get_root().get_node("world/player")
	if player:
		player.max_mana_changed.emit(value + permanent_mana_bonus)
		
func _on_player_health_changed_local(new_health: float) -> void:
	player_health_bar.value = new_health

func _on_player_max_health_changed_local(new_max_health: float) -> void:
	player_health_bar.max_value = int(new_max_health)
		

func handle_gravity_well() -> void:
	if ability_mana_reduction:
		gravity_well_mana_cost = 20.0
	
	if Input.is_action_just_pressed("Ability 2") and current_mana >= gravity_well_mana_cost and gravity_well_timer <= 0 and owns_gravity_well:
		stats_manager.total_gravity_wells_used += 1
		
		var gravity_well: Node2D = GravityWellScene.instantiate()
		
		var mouse_pos: Vector2 = get_global_mouse_position()
		gravity_well.global_position = mouse_pos
		
		get_parent().add_child(gravity_well)
		
		current_mana -= gravity_well_mana_cost
		mana_bar.value = current_mana
		mana_changed.emit(current_mana)
		gravity_well_timer = gravity_well_cooldown


func switch_weapon(direction_num: int) -> void:
	if weapon_restriction:
		return
	
	var owned_weapons: Array = []
	if owns_gun1:
		owned_weapons.append("gun1")
	if owns_gun2:
		owned_weapons.append("gun2")
	if owns_sniper1:
		owned_weapons.append("sniper1")
	if owns_rocketlauncher:
		owned_weapons.append("rocketlauncher")
	if owns_shotgun:
		owned_weapons.append("shotgun")
		
	if owned_weapons.size() <= 1:
		return
		
	var current_index: int = -1
	if equip_gun1:
		current_index = owned_weapons.find("gun1")
	elif equip_gun2:
		current_index = owned_weapons.find("gun2")
	elif equip_sniper1:
		current_index = owned_weapons.find("sniper1")
	elif equip_rocketlauncher:
		current_index = owned_weapons.find("rocketlauncher")
	elif equip_shotgun:
		current_index = owned_weapons.find("shotgun")
		
	var new_index = (current_index + direction_num) % owned_weapons.size()
	if new_index < 0:
		new_index = owned_weapons.size() - 1
		
	var new_weapon = owned_weapons[new_index]
	equip_gun1 = (new_weapon == "gun1")
	equip_gun2 = (new_weapon == "gun2")
	equip_sniper1 = (new_weapon == "sniper1")
	equip_rocketlauncher = (new_weapon == "rocketlauncher")
	equip_shotgun = (new_weapon == "shotgun")
	
	var weapon_hud = get_node_or_null("/root/world/UI/WeaponHUD")
	if weapon_hud:
		weapon_hud.update_weapon_display()
	
	update_gun_states()

func handle_shockwave() -> void:
	if ability_mana_reduction:
		shockwave_mana_cost = 20.0
		
	mana_particles.emitting = current_mana >= max_mana
	
	if Input.is_action_just_pressed("Ability 1") and current_mana >= shockwave_mana_cost:
		stats_manager.total_shockwaves_used += 1
		
		var shockwave: Area2D = ShockwaveScene.instantiate()
		shockwave.global_position = global_position
		get_parent().add_child(shockwave)
		shockwave.animated_sprite.play("shockwave")
		
		current_mana -= shockwave_mana_cost
		mana_bar.value = current_mana
		mana_changed.emit(current_mana)

func handle_orbital_ability() -> void:
	if ability_mana_reduction:
		orbital_ability_mana_cost = 20.0
		
	if Input.is_action_just_pressed("Ability 3") and current_mana >= orbital_ability_mana_cost and owns_orbital_ability and not orbital_ability_active:
		stats_manager.total_orbital_abilities_used += 1
		
		var orbital_ability: Node2D = OrbitalAbilityScene.instantiate()
		orbital_ability_active = true
		orbital_ability.get_node("DurationTimer").timeout.connect(_on_orbital_ability_finished)
		
		get_parent().add_child(orbital_ability)
		
		current_mana -= orbital_ability_mana_cost
		mana_bar.value = current_mana
		mana_changed.emit(current_mana)

func _on_orbital_ability_finished() -> void:
	orbital_ability_active = false
	
func handle_blink() -> void:
	if Input.is_action_just_pressed("Blink") and can_blink:
		perform_blink()


func perform_blink() -> void:
	stats_manager.total_blinks_used += 1
	
	if velocity.length() > 0:
		blink_direction = velocity.normalized()
	else:
		var input_dir: Vector2 = Vector2.ZERO
		
		if Input.is_action_pressed("right"):
			input_dir.x += 1
		if Input.is_action_pressed("left"):
			input_dir.x -= 1
		if Input.is_action_pressed("up"):
			input_dir.y -= 1
		if Input.is_action_pressed("down"):
			input_dir.y += 1
			
		if input_dir == Vector2.ZERO:
			return
			
		blink_direction = input_dir.normalized()
	
	blink_target_position = global_position + blink_direction * BLINK_DISTANCE
	
	collision_shape.disabled = true
	hurtbox_collision.disabled = true
	
	blinking = true
	
	can_blink = false
	blink_timer = 0.0
	blink_cooldown_progress = 0.0
	
	blink_cooldown_bar.value = 0.0
	blink_cooldown_bar.visible = true
	
	blink.play("blink_out")
	
	if owns_fire_blink:
		var anim_length = blink.current_animation_length
		
		for i in range(3):
			var fire_blink: Area2D = FireBlinkScene.instantiate()
			fire_blink.global_position = global_position + (blink_direction.normalized() * -30)
			fire_blink.rotation = blink_direction.angle() + PI/2
			get_parent().add_child(fire_blink)
			
			var tween: Tween = create_tween()
			tween.tween_interval(0.1 * i)
			tween.tween_property(fire_blink, "global_position", 
				blink_target_position, 
				anim_length)
			tween.tween_callback(fire_blink.queue_free)

	
func update_gun_states() -> void:
	if weapon_restriction:
		return
	
	if owns_gun1 and equip_gun1:
		gun.process_mode = Node.PROCESS_MODE_INHERIT
		gun.visible = true
		gun_2.process_mode = Node.PROCESS_MODE_DISABLED
		gun_2.visible = false
		sniper_1.process_mode = Node.PROCESS_MODE_DISABLED
		sniper_1.visible = false
		rocket_launcher.process_mode = Node.PROCESS_MODE_DISABLED
		rocket_launcher.visible = false
		shotgun.process_mode = Node.PROCESS_MODE_DISABLED
		shotgun.visible = false
	if owns_gun2 and equip_gun2:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		gun.visible = false
		gun_2.process_mode = Node.PROCESS_MODE_INHERIT
		gun_2.visible = true
		sniper_1.process_mode = Node.PROCESS_MODE_DISABLED
		sniper_1.visible = false
		rocket_launcher.process_mode = Node.PROCESS_MODE_DISABLED
		rocket_launcher.visible = false
		shotgun.process_mode = Node.PROCESS_MODE_DISABLED
		shotgun.visible = false
	if owns_sniper1 and equip_sniper1:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		gun.visible = false
		gun_2.process_mode = Node.PROCESS_MODE_DISABLED
		gun_2.visible = false
		sniper_1.process_mode = Node.PROCESS_MODE_INHERIT
		sniper_1.visible = true
		rocket_launcher.process_mode = Node.PROCESS_MODE_DISABLED
		rocket_launcher.visible = false
		shotgun.process_mode = Node.PROCESS_MODE_DISABLED
		shotgun.visible = false
	if owns_rocketlauncher and equip_rocketlauncher:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		gun.visible = false
		gun_2.process_mode = Node.PROCESS_MODE_DISABLED
		gun_2.visible = false
		sniper_1.process_mode = Node.PROCESS_MODE_DISABLED
		sniper_1.visible = false
		rocket_launcher.process_mode = Node.PROCESS_MODE_INHERIT
		rocket_launcher.visible = true
		shotgun.process_mode = Node.PROCESS_MODE_DISABLED
		shotgun.visible = false
	if owns_shotgun and equip_shotgun:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		gun.visible = false
		gun_2.process_mode = Node.PROCESS_MODE_DISABLED
		gun_2.visible = false
		sniper_1.process_mode = Node.PROCESS_MODE_DISABLED
		sniper_1.visible = false
		rocket_launcher.process_mode = Node.PROCESS_MODE_DISABLED
		rocket_launcher.visible = false
		shotgun.process_mode = Node.PROCESS_MODE_INHERIT
		shotgun.visible = true

func acquire_fire_blink() -> void:
	owns_fire_blink = true
	
func acquire_gravity_well() -> void:
	owns_gravity_well = true
	
func acquire_orbital_ability() -> void:
	owns_orbital_ability = true

func acquire_gun2() -> void:
	owns_gun2 = true
	
	equip_gun1 = false
	equip_gun2 = true
	equip_sniper1 = false
	equip_rocketlauncher = false
	equip_shotgun = false
	update_gun_states()
	
func acquire_sniper1() -> void:
	owns_sniper1 = true
	
	equip_gun1 = false
	equip_gun2 = false
	equip_sniper1 = true
	equip_rocketlauncher = false
	equip_shotgun = false
	update_gun_states()
	
func acquire_rocketlauncher() -> void:
	owns_rocketlauncher = true
	
	equip_gun1 = false
	equip_gun2 = false
	equip_sniper1 = false
	equip_rocketlauncher = true
	equip_shotgun = false
	update_gun_states()

func acquire_shotgun() -> void:
	owns_shotgun = true
	
	equip_gun1 = false
	equip_gun2 = false
	equip_sniper1 = false
	equip_rocketlauncher = false
	equip_shotgun = true
	update_gun_states()

func player_movement(delta: float) -> void:
	var input_direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
	if Input.is_action_pressed("down"):
		input_direction.y += 1

	input_direction = input_direction.normalized()
	
	#if speed_multiplier:
		#speed = speed * 1.5
	
	var target_velocity: Vector2 = input_direction * speed

	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	if input_direction.x > 0:
		direction = "right"
	elif input_direction.x < 0:
		direction = "left"
	elif input_direction.y < 0:
		direction = "up"
	elif input_direction.y > 0:
		direction = "down"
	else:
		direction = "none"

	var is_moving: bool = input_direction != Vector2.ZERO
	play_animation(direction, int(is_moving))

	move_and_slide()

func play_animation(dir: String, movement: int) -> void:
	if dir == "right":
		animated_sprite.flip_h = false
	elif dir == "left":
		animated_sprite.flip_h = true

	if movement == 1:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

func handle_death() -> void:
	if has_revive and !revive_used:
		revive_used = true
		health = (max_health + permanent_health_bonus) * 0.5
		health_changed.emit(health)
		
		# need to add a revive animation here
	else:
		health_depleted.emit()
		
func take_damage_from_mob1(damage: int) -> void:
	damage = max(damage - armor, 1)
	if damage_multiplier:
		damage = damage * 2
		
	var damage_number: Node2D = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -30)
	
	health -= damage
	health_changed.emit(health)
	if health <= 0:
		handle_death()
		
	var camera: Camera2D = $Camera2D
	if camera and camera.has_method("add_trauma"):
		var trauma_amount: float = clamp(damage / 40.0, 0.3, 0.6)
		camera.add_trauma(trauma_amount)
	
	animation_player.stop()
	animation_player.play("player_damage_flash")
	
	stats_manager.damage_taken_from_enemies += damage
