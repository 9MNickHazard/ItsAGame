# VISIBILITY GRID SCRIPT
# extends Node2D
#
#var grid_points = {}  # Dictionary to store grid points and their visibility values
#var grid_size = Vector2(52, 33)  # Grid dimensions in points
#var cell_size = 64  # Size of each grid cell in pixels
#var debug_draw = false
#
#var player = null
#var update_timer = 0.0
#const UPDATE_INTERVAL = 0.25
#const UPDATE_RADIUS = 1000.0
#
## Calculate grid offset to center it
#var grid_offset = Vector2(
	#-(grid_size.x * cell_size) / 2,
	#-(grid_size.y * cell_size) / 2
#)
#
#func _ready():
	##print("VisibilityGrid: Initializing...")
	#player = get_node("/root/world/player")
	#
	## Initialize grid points with offset
	#for x in range(grid_size.x):
		#for y in range(grid_size.y):
			#var point_pos = Vector2(
				#grid_offset.x + (x * cell_size) + cell_size/2,
				#grid_offset.y + (y * cell_size) + cell_size/2
			#)
			#grid_points[Vector2(x, y)] = {
				#"position": point_pos,
				#"visible_to_player": false
			#}
	##print("VisibilityGrid: Created ", grid_points.size(), " points")
#
#func _physics_process(delta):
	#if not player:
		#return
	#
	#update_timer += delta
	#if update_timer >= UPDATE_INTERVAL:
		#update_timer = 0
		#update_visibility()
		#queue_redraw()
#
#func update_visibility():
	#var space_state = get_world_2d().direct_space_state
	#var visible_count = 0
	#
	#for grid_pos in grid_points:
		#var point = grid_points[grid_pos]
		#var query = PhysicsRayQueryParameters2D.create(
			#point.position,
			#player.global_position,
			#pow(2, 6)  # Collision layer 7 (2^6)
		#)
		#
		#var result = space_state.intersect_ray(query)
		#point.visible_to_player = not result
		#if point.visible_to_player:
			#visible_count += 1
			#
	## for only updateing points around a certain radius of the player:
	##var space_state = get_world_2d().direct_space_state
	##
	##for grid_pos in grid_points:
		##var point = grid_points[grid_pos]
		##
		### Check if point is within update radius
		##if point.position.distance_to(player.global_position) <= UPDATE_RADIUS:
			##var query = PhysicsRayQueryParameters2D.create(
				##point.position,
				##player.global_position,
				##pow(2, 6)  # Collision layer 7 (2^6)
			##)
			##
			##var result = space_state.intersect_ray(query)
			##point.visible_to_player = not result
		##else:
			### Points outside radius are automatically not visible
			##point.visible_to_player = false
#
#func world_to_grid(world_pos: Vector2) -> Vector2:
	#var adjusted_pos = world_pos - grid_offset
	#return Vector2(
		#floor(adjusted_pos.x / cell_size),
		#floor(adjusted_pos.y / cell_size)
	#)
#
##func find_visible_point_near(enemy_pos: Vector2, radius: int = 4) -> Vector2:
	###print("Finding visible point near: ", enemy_pos)
	##
	### Convert enemy position to grid coordinates
	##var grid_pos = world_to_grid(enemy_pos)
	##
	##var best_point = null
	##var best_distance = INF
	##
	### Check points in a circular radius
	##for x in range(-radius, radius + 1):
		##for y in range(-radius, radius + 1):
			### Skip points outside our circular radius
			##if x*x + y*y > radius*radius:
				##continue
				##
			##var check_pos = grid_pos + Vector2(x, y)
			##
			### Skip if point doesn't exist in grid
			##if not grid_points.has(check_pos):
				##continue
			##
			##var point = grid_points[check_pos]
			##
			### Skip if point isn't visible to player
			##if not point.visible_to_player:
				##continue
			##
			### Check if enemy has LoS to this point
			##if has_los_between_points(enemy_pos, point.position):
				##var dist = enemy_pos.distance_squared_to(point.position)
				##if dist < best_distance:
					##best_distance = dist
					##best_point = point.position
	##
	##if best_point:
		###print("Found valid point: ", best_point)
		##return best_point
		##
	###print("No valid point found")
	##return enemy_pos
	#
#func find_visible_point_near(enemy_pos: Vector2, radius: int = 4) -> Dictionary:
	## Convert enemy position to grid coordinates
	#var grid_pos = world_to_grid(enemy_pos)
	#
	#var best_point = null
	#var next_point = null
	#var best_distance = INF
	#var direction_to_player = enemy_pos.direction_to(player.global_position)
	#
	## Check points in a circular radius
	#for x in range(-radius, radius + 1):
		#for y in range(-radius, radius + 1):
			## Skip points outside our circular radius
			#if x*x + y*y > radius*radius:
				#continue
				#
			#var check_pos = grid_pos + Vector2(x, y)
			#
			## Skip if point doesn't exist in grid
			#if not grid_points.has(check_pos):
				#continue
			#
			#var point = grid_points[check_pos]
			#
			## Skip if point isn't visible to player
			#if not point.visible_to_player:
				#continue
			#
			## Check if enemy has LoS to this point
			#if has_los_between_points(enemy_pos, point.position):
				#var dist = enemy_pos.distance_squared_to(point.position)
				#if dist < best_distance:
					#best_distance = dist
					#best_point = point.position
					#
					## Look for a next point in the general direction towards the player
					#var next_pos = check_pos + (direction_to_player * 2).round()
					#if grid_points.has(next_pos) and grid_points[next_pos].visible_to_player:
						#next_point = grid_points[next_pos].position
	#
	#return {
		#"current": best_point if best_point else enemy_pos,
		#"next": next_point if next_point else best_point if best_point else enemy_pos
	#}
#
#func has_los_between_points(from_pos: Vector2, to_pos: Vector2) -> bool:
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsRayQueryParameters2D.create(
		#from_pos,
		#to_pos,
		#pow(2, 6)  # Collision layer 7 (2^6)
	#)
	#var result = space_state.intersect_ray(query)
	#return not result
#
#func _draw():
	#if not debug_draw:
		#return
		#
	## Draw all grid points
	#for point in grid_points.values():
		#var color = Color.RED
		#if point.visible_to_player:
			#color = Color.GREEN
		#draw_circle(point.position, 4, color)








# TNT GOBLIN LoS SCRIPT

## LoS Variables
#var visibility_grid = null
#var has_los = false
#var target_point = null
#var next_target_point = null
#var path_update_timer = 0.0
#const PATH_UPDATE_INTERVAL = 0.25
#const LOS_ACTIVATION_RANGE = 900.0
#const POINT_SEARCH_RADIUS = 10


#if is_being_pushed and player:
		#var push_velocity = push_direction * PUSH_SPEED
		#velocity = push_velocity
		#move_and_slide()
		#return
	#
	#if knockback_timer > 0:
		#knockback_timer -= delta
		#move_and_slide()
		#return
	#
	#path_update_timer += delta
	#throw_timer += delta
	#
	#if player:
		#check_los()
		#
		#state_timer += delta
		#if state_timer >= 2.0:
			#state_timer = 0
			#update_state()
		#
		#var move_dir = get_movement_direction(delta)
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		## Handle TNT throwing
		#if distance_to_player <= throw_range and throw_timer >= throw_cooldown:
			#throw_tnt()
			#throw_timer = 0.0
		#
		## Handle movement when not throwing
		#if not is_throwing:
			#velocity = move_dir * SPEED
			#move_and_slide()
			#
			#if move_dir.x != 0:
				#animated_sprite.flip_h = move_dir.x < 0
			#animated_sprite.play("run")

## LoS function
#func check_los() -> void:
	#if not los_ray:
		#return
	#
	#los_ray.target_position = to_local(player.global_position)
	#los_ray.force_raycast_update()
	#has_los = !los_ray.is_colliding()
	

#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		## Only use LoS system when close enough to player
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				## Direct line to player
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
			#else:
				## Lost sight of player, find a path
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					## Note: POINT_SEARCH_RADIUS is used here
					#target_point = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					## If we're close to target point, clear it and check LoS again
					#if global_position.distance_to(target_point) < 20:
						#target_point = null
						#check_los()
		#else:
			## Too far from player, move directly towards them
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction
	

## LoS function
#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
				#next_target_point = null
			#else:
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					#var points = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
					#target_point = points.current
					#next_target_point = points.next
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					#if global_position.distance_to(target_point) < 20:
						#if next_target_point and next_target_point != target_point:
							#target_point = next_target_point
							#next_target_point = null
						#else:
							#target_point = null
							#next_target_point = null
							#check_los()
		#else:
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
			#next_target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction

## LoS function
#func update_state() -> void:
	#if target_point != null or next_target_point != null:
		#return
	#
	#if current_state == State.CHASE and randf() <= 0.2:
		#current_state = State.WANDER
		#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	#elif current_state == State.WANDER and randf() <= 0.6:
		#current_state = State.CHASE






# GOBLIN LoS SCRIPT

# IN READY FUNCTION
## LoS function
	#visibility_grid = get_node("/root/world/VisibilityGrid")
	#
	## Set up debug drawing for raycast
	#if los_ray:
		#los_ray.global_rotation = 0




## LoS Variables
#var visibility_grid = null
#var has_los = false
#var target_point = null
#var next_target_point = null
#var path_update_timer = 0.0
#const PATH_UPDATE_INTERVAL = 0.25
#const LOS_ACTIVATION_RANGE = 900.0
#const POINT_SEARCH_RADIUS = 10


# LoS function
	#if is_being_pushed and player:
		#var push_velocity = push_direction * PUSH_SPEED
		#velocity = push_velocity
		#move_and_slide()
		#return
	#
	#if knockback_timer > 0:
		#knockback_timer -= delta
		#move_and_slide()
		#return
	#
	#path_update_timer += delta
	#
	#if player:
		#check_los()
		#
		#state_timer += delta
		#if state_timer >= 2.0:
			#state_timer = 0
			#update_state()
		#
		#var move_dir = get_movement_direction(delta)
		#
		#if not is_attacking:
			#velocity = move_dir * SPEED
			#move_and_slide()
			#
			#if move_dir.x != 0:
				#animated_sprite.flip_h = move_dir.x < 0
			#animated_sprite.play("run")
		#
		## Attack logic
		#var distance_to_player = global_position.distance_to(player.global_position)
		#if not is_attacking and distance_to_player <= attack_range and attack_timer >= attack_cooldown:
			#start_attack()
			#attack_timer = 0.0
		#
		#attack_timer += delta
		#
		#if overlapping_player:
			#damage_timer += delta
			#if damage_timer >= damage_cooldown:
				#if player.has_method("take_damage_from_mob1"):
					#player.take_damage_from_mob1(20)
				#damage_timer = 0.0
				
## LoS function
#func check_los() -> void:
	#if not los_ray:
		#return
	#
	#los_ray.target_position = to_local(player.global_position)
	#los_ray.force_raycast_update()
	#has_los = !los_ray.is_colliding()


#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		## Only use LoS system when close enough to player
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				## Direct line to player
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
			#else:
				## Lost sight of player, find a path
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					## Note: POINT_SEARCH_RADIUS is used here
					#target_point = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					## If we're close to target point, clear it and check LoS again
					#if global_position.distance_to(target_point) < 20:
						#target_point = null
						#check_los()
		#else:
			## Too far from player, move directly towards them
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction
	
## LoS function
#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
				#next_target_point = null
			#else:
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					#var points = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
					#target_point = points.current
					#next_target_point = points.next
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					## If we're close to current target point, switch to next point
					#if global_position.distance_to(target_point) < 20:
						#if next_target_point and next_target_point != target_point:
							#target_point = next_target_point
							#next_target_point = null
						#else:
							#target_point = null
							#next_target_point = null
							#check_los()
		#else:
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
			#next_target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction

## debug functions for seeing where mobs are moving to:
#var debug_draw = true  # Set to true to see debug visualization
#
#func _draw():
	#if not debug_draw:
		#return
	#
	#if target_point:
		#draw_line(Vector2.ZERO, to_local(target_point), Color.YELLOW, 2.0)
		#draw_circle(to_local(target_point), 5, Color.YELLOW)
		#
		## Draw line between points if both exist
		#if next_target_point:
			#draw_line(to_local(target_point), to_local(next_target_point), Color.RED, 2.0)
			#draw_circle(to_local(next_target_point), 5, Color.RED)
#
#func _process(_delta):
	#queue_redraw()

## LoS function
#func update_state() -> void:
	##if target_point != null:
		##return
		#
	#if target_point != null or next_target_point != null:
		#return
	#
	#if current_state == State.CHASE and randf() <= 0.2:
		#current_state = State.WANDER
		#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		##print(name, ": Switching to WANDER")
	#elif current_state == State.WANDER and randf() <= 0.6:
		#current_state = State.CHASE
		##print(name, ": Switching to CHASE")






# WIZARD LoS FUNCTIONS

## LoS function
	#if is_dead:
		#return
		#
	#if is_being_pushed and player:
		#var push_velocity = push_direction * PUSH_SPEED
		#velocity = push_velocity
		#move_and_slide()
		#return
		#
	#if knockback_timer > 0:
		#knockback_timer -= delta
		#move_and_slide()
		#return
	#
	#path_update_timer += delta
	#attack_timer += delta
	#
	#if player:
		#check_los()
		#
		#state_timer += delta
		#if state_timer >= 2.0:
			#state_timer = 0
			#update_state()
		#
		#var move_dir = get_movement_direction(delta)
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		## Handle attacks
		#if distance_to_player <= attack_range and attack_timer >= attack_cooldown:
			#if randf() <= 0.3:
				#use_attack1()
				#attack_timer = 0.0
			#else:
				#use_attack2()
				#attack_timer = 0.0
		#
		## Handle movement when not attacking
		#if not is_attacking:
			#velocity = move_dir * SPEED
			#move_and_slide()
			#
			#if move_dir.x != 0:
				#animated_sprite.flip_h = move_dir.x < 0
			#animated_sprite.play("run")
		
#func check_los() -> void:
	#if not los_ray:
		#return
	#
	#los_ray.target_position = to_local(player.global_position)
	#los_ray.force_raycast_update()
	#has_los = !los_ray.is_colliding()
	
	# Debug print
	#if not has_los and current_state == State.CHASE:
		#print(name, ": Lost LoS to player")

#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		## Only use LoS system when close enough to player
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				## Direct line to player
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
			#else:
				## Lost sight of player, find a path
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					## Note: POINT_SEARCH_RADIUS is used here
					#target_point = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					## If we're close to target point, clear it and check LoS again
					#if global_position.distance_to(target_point) < 20:
						#target_point = null
						#check_los()
		#else:
			## Too far from player, move directly towards them
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction
	
#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
				#next_target_point = null
			#else:
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					#var points = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
					#target_point = points.current
					#next_target_point = points.next
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					## If we're close to current target point, switch to next point
					#if global_position.distance_to(target_point) < 20:
						#if next_target_point and next_target_point != target_point:
							#target_point = next_target_point
							#next_target_point = null
						#else:
							#target_point = null
							#next_target_point = null
							#check_los()
		#else:
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
			#next_target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction
#
#func update_state() -> void:
	#if target_point != null or next_target_point != null:
		#return
		#
	#if current_state == State.CHASE and randf() <= 0.2:
		#current_state = State.WANDER
		#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		##print(name, ": Switching to WANDER")
	#elif current_state == State.WANDER and randf() <= 0.6:
		#current_state = State.CHASE






# MARTIAL HERO LoS FUNCTIONS
## LoS function
	#if is_dead:
		#return
		#
	#if is_being_pushed and player:
		#var push_velocity = push_direction * PUSH_SPEED
		#velocity = push_velocity
		#move_and_slide()
		#return
	#
	#if knockback_timer > 0:
		#knockback_timer -= delta
		#move_and_slide()
		#return
	#
	#path_update_timer += delta
	#attack_timer += delta
	#
	#if player:
		#check_los()
		#
		#state_timer += delta
		#if state_timer >= 2.0:
			#state_timer = 0
			#update_state()
		#
		#var move_dir = get_movement_direction(delta)
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		## Handle attacks
		#if not is_attacking and distance_to_player <= attack_range and attack_timer >= attack_cooldown:
			#start_attack()
			#attack_timer = 0.0
		#
		## Handle movement when not attacking
		#if not is_attacking:
			#velocity = move_dir * SPEED
			#move_and_slide()
			#
			#if move_dir.x != 0:
				#animated_sprite.flip_h = move_dir.x < 0
			#animated_sprite.play("run")
		#
		## Handle overlapping damage
		#if overlapping_player:
			#damage = randf_range(minimum_damage, maximum_damage)
			#damage_timer += delta
			#if damage_timer >= damage_cooldown:
				#if player.has_method("take_damage_from_mob1"):
					#player.take_damage_from_mob1(damage)
				#damage_timer = 0.0
			
#func check_los() -> void:
	#if not los_ray:
		#return
	#
	#los_ray.target_position = to_local(player.global_position)
	#los_ray.force_raycast_update()
	#has_los = !los_ray.is_colliding()
	
	# Debug print
	#if not has_los and current_state == State.CHASE:
		#print(name, ": Lost LoS to player")

#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		## Only use LoS system when close enough to player
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				## Direct line to player
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
			#else:
				## Lost sight of player, find a path
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					## Note: POINT_SEARCH_RADIUS is used here
					#target_point = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					## If we're close to target point, clear it and check LoS again
					#if global_position.distance_to(target_point) < 20:
						#target_point = null
						#check_los()
		#else:
			## Too far from player, move directly towards them
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction
	
#func get_movement_direction(delta: float) -> Vector2:
	#var direction = Vector2.ZERO
	#
	#if current_state == State.CHASE:
		#var distance_to_player = global_position.distance_to(player.global_position)
		#
		#if distance_to_player <= LOS_ACTIVATION_RANGE:
			#if has_los:
				#direction = global_position.direction_to(player.global_position)
				#target_point = null
				#next_target_point = null
			#else:
				#if target_point == null or path_update_timer >= PATH_UPDATE_INTERVAL:
					#path_update_timer = 0.0
					#var points = visibility_grid.find_visible_point_near(global_position, POINT_SEARCH_RADIUS)
					#target_point = points.current
					#next_target_point = points.next
				#
				#if target_point and target_point != global_position:
					#direction = global_position.direction_to(target_point)
					#
					## If we're close to current target point, switch to next point
					#if global_position.distance_to(target_point) < 20:
						#if next_target_point and next_target_point != target_point:
							#target_point = next_target_point
							#next_target_point = null
						#else:
							#target_point = null
							#next_target_point = null
							#check_los()
		#else:
			#direction = global_position.direction_to(player.global_position)
			#target_point = null
			#next_target_point = null
	#else:  # WANDER state
		#direction = wander_direction
	#
	#return direction

#func update_state() -> void:
	#if target_point != null or next_target_point != null:
		#return
	#
	#if current_state == State.CHASE and randf() <= 0.2:
		#current_state = State.WANDER
		#wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		##print(name, ": Switching to WANDER")
	#elif current_state == State.WANDER and randf() <= 0.6:
		#current_state = State.CHASE