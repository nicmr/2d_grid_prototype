extends PopupMenu

enum { EMPTY = -1, ACTOR, OBSTACLE, OBJECT, GROUND}
var selected_type
var selected_cell

signal move_selected
signal dig_selected
signal inspect_selected
signal attack_selected
signal nil

# first element of each subarray is text on button in UI, second button is corresponding event
# array of maps might be better?
var ground_items = [{"label":"Move", "signal":"move_selected"}, {"label":"Dig", "signal":"dig_selected"}]
var empty_items = [{"label":"Move", "signal":"move_selected"}]
var object_items = [{"label":"Inspect", "signal":"inspect_selected"}]
var actor_items = [{"label":"Attack", "signal":"attack_selected"}]
var obstacle_items = [{"label":"No action possible", "signal":"nil"}]

onready var player_actor = get_parent().get_parent().get_node("GameLayer").get_node("Grid").get_node("Actor")

func _ready():
	player_actor.connect("rightclick_world", self, "on_request_menu")
	player_actor.connect("leftclick_world", self, "on_close_menu")
	
	connect("id_pressed", self, "on_id_pressed")

######################################################################################################
### Signal handlers for signals from Player actor ###
######################################################################################################
func on_request_menu(pos, cell, cell_type):
	clear()
	print("received menu request at", pos, "/", cell, "with type: ", cell_type)
	set_visible(true)
	set_position(pos)
	selected_cell = cell
	selected_type = cell_type
	print("selected_type is", selected_type)
	var items
	match selected_type:
		EMPTY:
			items = empty_items
		ACTOR:
			items = actor_items
		OBSTACLE:
			items = obstacle_items
		OBJECT:
			items = object_items
		GROUND:
			items = ground_items
		
	for i in len(items):
		add_item(items[i]["label"], i)

func on_close_menu():
	set_visible(false)

# Handler for internal signals
func on_id_pressed(id):
	var items
	match selected_type:
		EMPTY:
			items = empty_items
		ACTOR:
			items = actor_items
		OBSTACLE:
			items = obstacle_items
		OBJECT:
			items = ground_items
		GROUND:
			items = ground_items
			
	print("emitting signal:", items[id]["signal"])
	emit_signal(items[id]["signal"], selected_cell)
	clear()