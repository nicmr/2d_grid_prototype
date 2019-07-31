extends PopupMenu

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT, GROUND}
var selected_type = EMPTY

onready var player_actor = get_parent().get_parent().get_node("GameLayer").get_node("Grid").get_node("Actor")

func _ready():
	player_actor.connect("rightclick_world", self, "on_request_menu")
	player_actor.connect("leftclick_world", self, "on_close_menu")
	
	connect("id_pressed", self, "on_id_pressed")
	
# Handlers for signals from Player actor
func on_request_menu(position, cell_type):
	clear()
	set_visible(true)
	set_position(position)
	selected_type = cell_type
	match selected_type:
		GROUND:
			add_ground_items()
		EMPTY:
			add_empty_items()
		OBJECT:
			add_object_items()
		ACTOR:
			add_actor_items()
	
func add_ground_items():
	add_item("Move")
			
func add_empty_items():
	add_item("Move")

func add_object_items():
	add_item("Inspect")
	
func add_actor_items():
	add_item("Attack")
		
func on_close_menu():
	set_visible(false)

# Handler for internal signals
func on_id_pressed(id):
	print("id pressed:", id)
	print("selected type:", selected_type)
	
	clear()