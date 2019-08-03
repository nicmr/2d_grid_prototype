extends TileMap

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT, GROUND}


# AStar2D implementation is not stable yet, so we're using AStar and ignoring the z-axis
# AStar variables
onready var astar = AStar.new()
onready var used_rect = get_used_rect()
var tiles
var traversable


func _ready():
	var rect = get_used_rect()
	# first, make all tiles of type ground
	for x in rect.size.x:
		for y in rect.size.y:
			var vec = Vector2(x,y)
			if get_cellv(vec) != OBSTACLE:
				set_cellv(vec , GROUND)
	# then replace value of used tiles with real value
	for child in get_children():
		set_cellv(world_to_map(child.position), child.type)
	tiles = get_used_cells()
	traversable = traversable_tiles(tiles)
	# AStar setup
	add_traversable_tiles(traversable)
	connect_traversable_tiles(traversable)
		
		
		
		
##############################################################################################################
### A Star 2D implementation ###
##############################################################################################################

# Returns all traversable tiles from the passed set of tiles	
func traversable_tiles(tiles):
	var result = []
	for tile in tiles:
		if cell_type(tile) == GROUND:
			print("Cell:", tile, " type:", cell_type(tile))
			result.append(tile)
#			print("Adding.")
	return tiles


# Adds tiles to the A* grid but does not connect them
# ie. They will exist on the grid, but you cannot find a path yet
func add_traversable_tiles(traversable_tiles):

	# Loop over all tiles
	for tile in traversable_tiles:
		var id = id_for_point(tile)
		# Add the tile to the AStar navigation
		astar.add_point(id, Vector3(tile.x, tile.y, 0))		
		
# Determines a unique ID for a given point on the map
func id_for_point(point):

	# Offset position of tile with the bounds of the tilemap
	# This prevents ID's of less than 0, if points are behind (0, 0)
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y

	return x + y * used_rect.size.x
	
	
# Connects all tiles on the A* grid with their surrounding tiles
func connect_traversable_tiles(traversable_tiles):

	# Loop over all tiles
	for tile in traversable_tiles:
		var id = id_for_point(tile)

		### Implementation to connect in 8 directions ###
		### (Chess: King-style movement) ###
		
		# Loops used to search around player (range(3) returns 0, 1, and 2)
#		for x in range(3):
#			for y in range(3):
#				# Determines target, converting range variable to -1, 0, and 1
#				var target = tile + Vector2(x - 1, y - 1)
#				# Determines target ID
#				var target_id = id_for_point(target)
#				# Do not connect if point is same or point does not exist on astar
#				if tile == target or not astar.has_point(target_id):
#					continue
#				# Connect points
#				astar.connect_points(id, target_id, true)
		# ------------------------------------------------
		
		### Implementation to connect in 4 directions ###
		### (Chess: Rook-style movement) ###
		
		# order: above, below, left, right
		var neighbours = [Vector2(tile.x, tile.y-1),Vector2(tile.x, tile.y+1),Vector2(tile.x -1, tile.y),Vector2(tile.x -1, tile.y)]
		
		for nb in neighbours:
			var nb_id = id_for_point(nb)
			if not astar.has_point(nb_id):
				continue
			astar.connect_points(id, nb_id, true)

# Returns a path from start to end
func get_astar_path(start, end):

	# Determines IDs
	var start_id = id_for_point(start)
	var end_id = id_for_point(end)

	# Return null if navigation is impossible
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		print("points:", astar.get_points())
		
		print("astar doesn't have point:", start_id)
		print("or astar doesn't have point:", end_id)
		
		return null

	# Otherwise, find the map
	var path_map = astar.get_point_path(start_id, end_id)
	return path_map
	
func get_cell_connections(vec2):
	var id = id_for_point(vec2)
	return astar.get_point_connections(id)
	
	
########################################################################################################
### custom stuff ###
########################################################################################################

func cell_type(cell):
	return get_cellv(cell)

func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size / 2


	
func request_move_cell(pawn, cell_target):
	var cell_start = world_to_map(pawn.position)
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		GROUND:
			return update_pawn_position(pawn, cell_start, cell_target)
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)
		OBJECT:
			var object_pawn = get_cell_pawn(cell_target)
			object_pawn.queue_free()
			return update_pawn_position(pawn, cell_start, cell_target)
		ACTOR:
			var pawn_name = get_cell_pawn(cell_target).name
			print("Cell %s contains %s" % [cell_target, pawn_name])
			
func request_move_vec(pawn, vec):
	var cell = world_to_map(vec)
	return request_move_cell(pawn, cell)
	
	
	
########################################################################################################
### unused gdquest stuff ###
########################################################################################################

func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)


func request_move_direction(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			return update_pawn_position(pawn, cell_start, cell_target)
		OBJECT:
			var object_pawn = get_cell_pawn(cell_target)
			object_pawn.queue_free()
			return update_pawn_position(pawn, cell_start, cell_target)
		ACTOR:
			var pawn_name = get_cell_pawn(cell_target).name
			print("Cell %s contains %s" % [cell_target, pawn_name])