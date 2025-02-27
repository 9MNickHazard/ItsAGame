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

signal health_changed(new_health)
signal health_depleted
signal max_health_changed(new_max_health)
signal mana_changed(new_mana)
signal max_mana_changed(new_max_mana)

const FloatingDamageScene = preload("res://scenes/player_floating_damage.tscn")
const FireBlinkScene = preload("res://scenes/fire_blink.tscn")
const ShockwaveScene = preload("res://scenes/shockwave.tscn")

#const PauseMenuScript = preload("res://scripts/pause_menu.gd")


# blink variables
#var can_blink = true
#static var blink_cooldown = 10.0
#var blink_timer = 0.0
static var blink_distance = 300.0
var blinking = false
static var BLINK_SPEED = 1500.0
var blink_target_position = Vector2.ZERO
var blink_direction = Vector2.ZERO

# mana variables
static var max_mana = 100.0
var current_mana = 100.0
var mana_cost_per_blink = 50.0
var shockwave_mana_cost = 100.0

static var max_health = 100.0
var health = 100.0
var speed: float = 450.0  
var acceleration: float = 2000.0
var friction: float = 1500.0
var direction = "none"

# upgrade related variables
var owns_gun1 = true
var owns_gun2 = false
var owns_sniper1 = false
var owns_rocketlauncher = false
var owns_fire_blink = false

var equip_gun1 = true
var equip_gun2 = false
var equip_sniper1 = false
var equip_rocketlauncher = false

func _ready() -> void:
	update_gun_states()
	mana_bar.max_value = max_mana
	mana_bar.value = current_mana
	mana_particles.emitting = current_mana >= mana_cost_per_blink

func _physics_process(delta: float) -> void:
	# blink
	if blinking:
		var distance_to_target = global_position.distance_to(blink_target_position)
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
	
	if Input.is_action_just_released("scroll_up"):
		switch_weapon(1)
	elif Input.is_action_just_released("scroll_down"):
		switch_weapon(-1)
		
static func set_max_health(value: float):
	max_health = value
	
	var player = Engine.get_main_loop().get_root().get_node("world/player")
	if player:
		player.max_health_changed.emit(value)
		
static func set_max_mana(value: float):
	max_mana = value
	
	var player = Engine.get_main_loop().get_root().get_node("world/player")
	if player:
		player.max_mana_changed.emit(value)
		

func switch_weapon(direction_num: int):
	var owned_weapons = []
	if owns_gun1:
		owned_weapons.append("gun1")
	if owns_gun2:
		owned_weapons.append("gun2")
	if owns_sniper1:
		owned_weapons.append("sniper1")
	if owns_rocketlauncher:
		owned_weapons.append("rocketlauncher")
		
	if owned_weapons.size() <= 1:
		return
		
	var current_index = -1
	if equip_gun1:
		current_index = owned_weapons.find("gun1")
	elif equip_gun2:
		current_index = owned_weapons.find("gun2")
	elif equip_sniper1:
		current_index = owned_weapons.find("sniper1")
	elif equip_rocketlauncher:
		current_index = owned_weapons.find("rocketlauncher")
		
	var new_index = (current_index + direction_num) % owned_weapons.size()
	if new_index < 0:
		new_index = owned_weapons.size() - 1
		
	var new_weapon = owned_weapons[new_index]
	equip_gun1 = (new_weapon == "gun1")
	equip_gun2 = (new_weapon == "gun2")
	equip_sniper1 = (new_weapon == "sniper1")
	equip_rocketlauncher = (new_weapon == "rocketlauncher")
	
	update_gun_states()

func handle_shockwave() -> void:
	mana_particles.emitting = current_mana >= max_mana
	
	if Input.is_action_just_pressed("Ability 1") and current_mana >= shockwave_mana_cost:
		var shockwave = ShockwaveScene.instantiate()
		shockwave.global_position = global_position
		get_parent().add_child(shockwave)
		shockwave.animated_sprite.play("shockwave")
		
		# Use mana and update UI
		current_mana -= shockwave_mana_cost
		mana_bar.value = current_mana
		mana_changed.emit(current_mana)
	
func handle_blink() -> void:
	mana_particles.emitting = current_mana >= max_mana
	
	if Input.is_action_just_pressed("Blink") and current_mana >= mana_cost_per_blink:
		mana_particles.emitting = false
		perform_blink()


func perform_blink() -> void:
	if velocity.length() > 0:
		blink_direction = velocity.normalized()
	else:
		var input_dir = Vector2.ZERO
		
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
	
	blink_target_position = global_position + blink_direction * blink_distance
	
	collision_shape.disabled = true
	hurtbox_collision.disabled = true
	
	blinking = true
	current_mana -= mana_cost_per_blink
	mana_bar.value = current_mana
	mana_changed.emit(current_mana)
	
	blink.play("blink_out")
	
	if owns_fire_blink:
		var anim_length = blink.current_animation_length
		
		for i in range(3):
			var fire_blink = FireBlinkScene.instantiate()
			fire_blink.global_position = global_position + (blink_direction.normalized() * -30)
			fire_blink.rotation = blink_direction.angle() + PI/2
			get_parent().add_child(fire_blink)
			
			var tween = create_tween()
			tween.tween_interval(0.1 * i)
			tween.tween_property(fire_blink, "global_position", 
				blink_target_position, 
				anim_length)
			tween.tween_callback(fire_blink.queue_free)

	
func update_gun_states():
	if owns_gun1 and equip_gun1:
		gun.process_mode = Node.PROCESS_MODE_INHERIT
		gun.visible = true
		gun_2.process_mode = Node.PROCESS_MODE_DISABLED
		gun_2.visible = false
		sniper_1.process_mode = Node.PROCESS_MODE_DISABLED
		sniper_1.visible = false
		rocket_launcher.process_mode = Node.PROCESS_MODE_DISABLED
		rocket_launcher.visible = false
	if owns_gun2 and equip_gun2:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		gun.visible = false
		gun_2.process_mode = Node.PROCESS_MODE_INHERIT
		gun_2.visible = true
		sniper_1.process_mode = Node.PROCESS_MODE_DISABLED
		sniper_1.visible = false
		rocket_launcher.process_mode = Node.PROCESS_MODE_DISABLED
		rocket_launcher.visible = false
	if owns_sniper1 and equip_sniper1:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		gun.visible = false
		gun_2.process_mode = Node.PROCESS_MODE_DISABLED
		gun_2.visible = false
		sniper_1.process_mode = Node.PROCESS_MODE_INHERIT
		sniper_1.visible = true
		rocket_launcher.process_mode = Node.PROCESS_MODE_DISABLED
		rocket_launcher.visible = false
	if owns_rocketlauncher and equip_rocketlauncher:
		gun.process_mode = Node.PROCESS_MODE_DISABLED
		gun.visible = false
		gun_2.process_mode = Node.PROCESS_MODE_DISABLED
		gun_2.visible = false
		sniper_1.process_mode = Node.PROCESS_MODE_DISABLED
		sniper_1.visible = false
		rocket_launcher.process_mode = Node.PROCESS_MODE_INHERIT
		rocket_launcher.visible = true

func acquire_fire_blink():
	owns_fire_blink = true

func acquire_gun2():
	owns_gun2 = true
	
	equip_gun1 = false
	equip_gun2 = true
	equip_sniper1 = false
	equip_rocketlauncher = false
	update_gun_states()
	
func acquire_sniper1():
	owns_sniper1 = true
	
	equip_gun1 = false
	equip_gun2 = false
	equip_sniper1 = true
	equip_rocketlauncher = false
	update_gun_states()
	
func acquire_rocketlauncher():
	owns_rocketlauncher = true
	
	equip_gun1 = false
	equip_gun2 = false
	equip_sniper1 = false
	equip_rocketlauncher = true
	update_gun_states()

func player_movement(delta):
	var input_direction = Vector2.ZERO

	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
	if Input.is_action_pressed("down"):
		input_direction.y += 1

	input_direction = input_direction.normalized()

	var target_velocity = input_direction * speed

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

	var is_moving = input_direction != Vector2.ZERO
	play_animation(direction, int(is_moving))

	move_and_slide()

func play_animation(dir, movement):
	if dir == "right":
		animated_sprite.flip_h = false
	elif dir == "left":
		animated_sprite.flip_h = true

	if movement == 1:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
		
func take_damage_from_mob1(damage):
	var damage_number = FloatingDamageScene.instantiate()
	damage_number.damage_amount = damage
	get_parent().add_child(damage_number)
	damage_number.global_position = global_position + Vector2(0, -30)
	
	health -= damage
	health_changed.emit(health)
	if health <= 0:
		health_depleted.emit()
		
	var camera = $Camera2D
	if camera and camera.has_method("add_trauma"):
		# Amount of trauma proportional to damage (adjust as needed)
		var trauma_amount = clamp(damage / 40.0, 0.3, 0.6)
		camera.add_trauma(trauma_amount)
	
	animation_player.stop()
	animation_player.play("player_damage_flash")
