extends Node

var coin_pool: Array = []
var target_pool_size: int = 600
var initial_pool_size: int = 150
var coins_per_batch: int = 5
var coin_scene: PackedScene = preload("res://scenes/coin.tscn")
var pool_timer: Timer
var inactive_position: Vector2 = Vector2(10000, 10000)

func _ready() -> void:
	for i in range(initial_pool_size):
		create_coin_for_pool()
	
	pool_timer = Timer.new()
	add_child(pool_timer)
	pool_timer.wait_time = 0.5
	pool_timer.timeout.connect(_on_pool_timer_timeout)
	pool_timer.start()
	
func _process(delta: float) -> void:
	if Engine.get_physics_frames() % 60 == 0:
		var active_coins: int = 0
		var inactive_coins: int = 0
		
		for coin: Area2D in coin_pool:
			if coin.visible:
				active_coins += 1
			else:
				inactive_coins += 1
				

func _on_pool_timer_timeout() -> void:
	for i in range(coins_per_batch):
		create_coin_for_pool()
	
	if coin_pool.size() >= target_pool_size:
		pool_timer.stop()

func create_coin_for_pool() -> void:
	var coin: Area2D = coin_scene.instantiate()
	add_child(coin)
	
	coin.visible = false
	coin.position = inactive_position
	coin.set_physics_process(false)
	
	coin_pool.append(coin)


func get_coin() -> Area2D:
	for c: Area2D in coin_pool:
		if c and not c.visible:
			c.visible = true
			c.set_physics_process(true)
			if c.has_node("DespawnTimer"):
				c.get_node("DespawnTimer").stop()
				c.get_node("DespawnTimer").start()
			return c
	
	if coin_pool.size() < target_pool_size:
		var addedcoin: Area2D = coin_scene.instantiate()
		add_child(addedcoin)
		coin_pool.append(addedcoin)
		if addedcoin.has_node("DespawnTimer"):
			addedcoin.get_node("DespawnTimer").stop()
			addedcoin.get_node("DespawnTimer").start()
		return addedcoin
	
	if coin_pool.size() == 0:
		var newcoin: Area2D = coin_scene.instantiate()
		add_child(newcoin)
		coin_pool.append(newcoin)
		if newcoin.has_node("DespawnTimer"):
			newcoin.get_node("DespawnTimer").stop()
			newcoin.get_node("DespawnTimer").start()
		return newcoin
	
	var coin: Area2D = coin_pool[0]
	
	if not is_instance_valid(coin):
		coin = coin_scene.instantiate()
		add_child(coin)
	else:
		coin_pool.remove_at(0)
		coin_pool.append(coin)
		
	if coin.has_node("DespawnTimer"):
		coin.get_node("DespawnTimer").stop()
		coin.get_node("DespawnTimer").start()
	
	coin.visible = true
	coin.set_physics_process(true)
	return coin

func release_coin(coin: Area2D) -> void:
	if coin:
		if coin.has_node("DespawnTimer"):
			coin.get_node("DespawnTimer").stop()
		coin.visible = false
		coin.position = inactive_position
		coin.set_physics_process(false)
		coin.is_being_pulled = false  # Reset pull state
		coin.player = null  # Clear player reference
	else:
		print("WARNING: Tried to release null coin")
		
func reset_for_new_game() -> void:
	# Hide all coins
	for coin: Area2D in coin_pool:
		if is_instance_valid(coin):
			coin.visible = false
			coin.position = inactive_position
			coin.set_physics_process(false)
