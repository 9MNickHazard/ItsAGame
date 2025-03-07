extends Node

var coin_pool = []
var target_pool_size = 600
var initial_pool_size = 150
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
	for c in coin_pool:
		if c and not c.visible:
			c.visible = true
			c.set_physics_process(true)
			if c.has_node("DespawnTimer"):
				c.get_node("DespawnTimer").stop()
				c.get_node("DespawnTimer").start()
			return c
	
	if coin_pool.size() < target_pool_size:
		var addedcoin = coin_scene.instantiate()
		add_child(addedcoin)
		coin_pool.append(addedcoin)
		if addedcoin.has_node("DespawnTimer"):
			addedcoin.get_node("DespawnTimer").stop()
			addedcoin.get_node("DespawnTimer").start()
		return addedcoin
	
	if coin_pool.size() == 0:
		var newcoin = coin_scene.instantiate()
		add_child(newcoin)
		coin_pool.append(newcoin)
		if newcoin.has_node("DespawnTimer"):
			newcoin.get_node("DespawnTimer").stop()
			newcoin.get_node("DespawnTimer").start()
		return newcoin
	
	var coin = coin_pool[0]
	
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

func release_coin(coin):
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
		
func reset_for_new_game():
	# Hide all coins
	for coin in coin_pool:
		if is_instance_valid(coin):
			coin.visible = false
			coin.position = inactive_position
			coin.set_physics_process(false)
