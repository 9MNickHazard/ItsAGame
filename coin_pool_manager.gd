extends Node

var coin_pool = []
var target_pool_size = 900
var initial_pool_size = 200
var coins_per_batch = 5
var coin_scene = preload("res://scenes/coin.tscn")
var pool_timer: Timer
var inactive_position = Vector2(10000, 10000)

func _ready():
	for i in range(initial_pool_size):
		create_coin_for_pool()
	
	pool_timer = Timer.new()
	add_child(pool_timer)
	pool_timer.wait_time = 0.5
	pool_timer.timeout.connect(_on_pool_timer_timeout)
	pool_timer.start()
	
func _process(delta):
	# Only run every 5 seconds to avoid spam
	if Engine.get_physics_frames() % 60 == 0:
		var active_coins = 0
		var inactive_coins = 0
		
		for coin in coin_pool:
			if coin.visible:
				active_coins += 1
			else:
				inactive_coins += 1
				

func _on_pool_timer_timeout():
	for i in range(coins_per_batch):
		create_coin_for_pool()
	
	if coin_pool.size() >= target_pool_size:
		pool_timer.stop()

func create_coin_for_pool():
	var coin = coin_scene.instantiate()
	add_child(coin)
	
	coin.visible = false
	coin.position = inactive_position
	coin.set_physics_process(false)
	
	coin_pool.append(coin)


func get_coin():
	# Find an inactive coin
	for coin in coin_pool:
		if coin and not coin.visible:
			coin.visible = true
			coin.set_physics_process(true)
			return coin
	
	# Create new coin if needed
	if coin_pool.size() < target_pool_size:
		var coin = coin_scene.instantiate()
		add_child(coin)
		coin_pool.append(coin)
		return coin
	
	# Check if any coins exist at all
	if coin_pool.size() == 0:
		var coin = coin_scene.instantiate()
		add_child(coin)
		coin_pool.append(coin)
		return coin
	
	# Reuse oldest coin if at capacity
	var coin = coin_pool[0]
	
	# If somehow the coin is invalid, create a new one
	if not is_instance_valid(coin):
		coin = coin_scene.instantiate()
		add_child(coin)
	else:
		coin_pool.remove_at(0)
		coin_pool.append(coin)
	
	coin.visible = true
	coin.set_physics_process(true)
	return coin

func release_coin(coin):
	if coin:
		coin.visible = false
		coin.position = inactive_position
		coin.set_physics_process(false)
		coin.is_being_pulled = false  # Reset pull state
		coin.player = null  # Clear player reference
	else:
		print("WARNING: Tried to release null coin")
		
func reset_for_new_game():
	# Hide all coins
	for coin in coin_pool:
		if is_instance_valid(coin):
			coin.visible = false
			coin.position = inactive_position
			coin.set_physics_process(false)
