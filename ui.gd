extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel
@onready var coin_label: Label = $CoinLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var xp_label: Label = $XPLabel
@onready var level_label: Label = $LevelLabel
@onready var level_up_popup: Label = $LevelUpPopup
@onready var animation_player: AnimationPlayer = $LevelUpPopup/AnimationPlayer
@onready var health_label: Label = $HealthLabel
@onready var PlayerScript: GDScript = load("res://scripts/player.gd")
@onready var mana_bar: ProgressBar = $ManaBar
@onready var mana_amount_label: Label = $ManaBar/ManaAmountLabel
@onready var stats_manager: Node2D = get_node("/root/world/StatsManager")
@onready var fps_label: Label = $FPSLabel

var coins_collected: int = 0
var score: int = 0
var experience_manager: Node = null

static var gold_bonus_multiplier: float = 1.0

func _ready() -> void:
	var player: CharacterBody2D = get_node("/root/world/player")
	player.health_changed.connect(_on_player_health_changed)
	player.max_health_changed.connect(_on_max_health_changed)
	player.mana_changed.connect(_on_player_mana_changed)
	player.max_mana_changed.connect(_on_max_mana_changed)
	
	#health_bar.max_value = player.health
	#health_bar.value = player.health
	
	experience_manager = load("res://scripts/experience_manager.gd").new()
	add_child(experience_manager)
	
	xp_bar.max_value = experience_manager.get_xp_for_next_level()
	xp_bar.value = 0
	xp_label.text = "0/" + str(experience_manager.get_xp_for_next_level())

	
	experience_manager.level_up.connect(_on_level_up)
	experience_manager.experience_gained.connect(_on_experience_gained)
	
	level_up_popup.modulate.a = 0.7
	level_up_popup.visible = false
	_create_level_up_animation()
	
func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_max_health_changed(new_max_health: float) -> void:
	health_bar.max_value = new_max_health
	health_label.text = str(int(health_bar.value)) + "/" + str(int(new_max_health))

func _on_player_health_changed(new_health: float) -> void:
	health_bar.value = new_health
	health_label.text = str(int(new_health)) + "/" + str(int(PlayerScript.max_health))
	
func _on_player_mana_changed(new_mana: float) -> void:
	mana_bar.value = new_mana
	mana_amount_label.text = str(int(new_mana)) + "/" + str(int(PlayerScript.max_mana))

func _on_max_mana_changed(new_max_mana: float) -> void:
	mana_bar.max_value = new_max_mana
	mana_amount_label.text = str(int(mana_bar.value)) + "/" + str(int(new_max_mana))

func increase_score(amount: int) -> void:
	score += amount
	score_label.text = "Score: " + str(score)
	
func add_coin(amount: int = 1) -> void:
	amount = int(ceil(amount * gold_bonus_multiplier))
	coins_collected += amount
	coin_label.text = "Coins: " + str(coins_collected)
	
	stats_manager.total_coins_collected += amount
	

func _on_level_up(new_level: int) -> void:
	level_label.text = "Level: " + str(new_level)
	
	level_up_popup.text = "LEVEL " + str(new_level) + "!"
	level_up_popup.visible = true
	animation_player.stop()
	animation_player.play("level_up")
	
	await animation_player.animation_finished
	level_up_popup.visible = false
	
func _on_experience_gained(current_xp: int, xp_for_next: int) -> void:
	if xp_for_next > 0:
		var prev_level_xp: int = 0
		if experience_manager.current_level > 1:
			prev_level_xp = experience_manager.xp_table[experience_manager.current_level]
		
		var level_progress: int = current_xp - prev_level_xp
		var level_total: int = xp_for_next - prev_level_xp
		
		xp_bar.max_value = level_total
		xp_bar.value = level_progress
		xp_label.text = str(current_xp) + "/" + str(xp_for_next)
	else:
		xp_bar.value = xp_bar.max_value
		xp_label.text = "Max Level!"

static func change_gold_bonus(bonus) -> void:
	gold_bonus_multiplier = bonus


func _create_level_up_animation() -> void:
	var animation_library: AnimationLibrary = AnimationLibrary.new()
	var animation: Animation = Animation.new()
	var track_index: int = animation.add_track(Animation.TYPE_VALUE)
	
	animation.track_set_path(track_index, ":position:y")
	animation.track_insert_key(track_index, 0.0, 100)
	animation.track_insert_key(track_index, 0.5, 70)
	animation.track_insert_key(track_index, 1.5, 70)
	animation.track_insert_key(track_index, 2.0, 40)
	
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":scale")
	animation.track_insert_key(track_index, 0.0, Vector2(1, 1))
	animation.track_insert_key(track_index, 0.2, Vector2(1.5, 1.5))
	animation.track_insert_key(track_index, 0.4, Vector2(1, 1))
	
	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, ":modulate:a")
	animation.track_insert_key(track_index, 0.0, 0.8)
	animation.track_insert_key(track_index, 1.5, 0.8)
	animation.track_insert_key(track_index, 2.0, 0.0)
	
	animation.length = 2.0
	
	animation_library.add_animation("level_up", animation)
	animation_player.add_animation_library("", animation_library)
