extends Node2D
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
