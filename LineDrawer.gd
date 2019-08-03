extends Node2D

var subpaths = []

onready var player_actor = get_parent().get_node("Grid").get_node("Actor")
onready var Grid = get_parent().get_node("Grid")
onready var half_cell_size = Grid.get_cell_size()[0]*0.5

enum TraversalMode{ X, Y }

func _draw():
	for path in subpaths:
		var adjusted_start = Grid.map_to_world(path[0])
		adjusted_start.x += half_cell_size
		adjusted_start.y += half_cell_size
		var adjusted_end = Grid.map_to_world(path[1])
		adjusted_end.x += half_cell_size
		adjusted_end.y += half_cell_size
		
		draw_line(adjusted_start, adjusted_end, Color( 0.8, 0.52, 0.43, 1 ))		
		
func _ready():
	player_actor.connect("path_update", self, "on_path_update")
	
func on_path_update(path):
	var subpath_start = path[0]
	var traversal_mode = TraversalMode.X
	
	for i in len(path)-1:
		if traversal_mode == TraversalMode.X:
			if path[i+1].y == subpath_start.y :
				continue
			else:
				subpaths.append([Vector2(subpath_start.x, subpath_start.y), Vector2(path[i].x, path[i].y)])
				subpath_start = path[i]
				traversal_mode = TraversalMode.Y
		if traversal_mode == TraversalMode.Y:
			if path[i+1].x == subpath_start.x:
				continue
			else:
				subpaths.append([Vector2(subpath_start.x, subpath_start.y), Vector2(path[i].x, path[i].y)])
				subpath_start = path[i]
				traversal_mode = TraversalMode.X
	# append final path
	subpaths.append([Vector2(subpath_start.x, subpath_start.y), Vector2(path[len(path)-1].x, path[len(path)-1].y)])
	
	update()