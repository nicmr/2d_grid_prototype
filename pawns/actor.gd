extends "pawn.gd"

onready var Grid = get_parent()
var path_hl

signal leftclick_world
signal rightclick_world
signal path_update

onready var start_v = Grid.map_to_world(Vector2(2,3))

func _ready():
	update_look_direction(Vector2(1, 0))

func _process(delta):
	
	if Input.is_action_just_pressed("ui_mouse1"):
		emit_signal("leftclick_world")
		var mouse_position = get_global_mouse_position()
		var cell = Grid.world_to_map(mouse_position)
		print(cell)
		print(Grid.get_cell_connections(cell))
		
	elif Input.is_action_just_pressed("ui_mouse2"):
		var mouse_position = get_global_mouse_position()
		var cell = Grid.world_to_map(mouse_position)
		var cell_type = Grid.cell_type(cell)
		
		var my_path = Grid.get_astar_path(Vector2(2,3), cell)
		var end_v = Grid.map_to_world(cell)
		emit_signal("path_update", my_path)
		
		
		
		emit_signal("rightclick_world", mouse_position, cell_type)
		
#		var target_position = Grid.request_move_v(self, mouse_position)
#		if target_position:
#			move_to(target_position)
#		else:
#			bump()
#
	
	var input_direction = get_input_direction()
	if not input_direction:
		return
	update_look_direction(input_direction)

	var target_position = Grid.request_move_direction(self, input_direction)
	if target_position:
		move_to(target_position)
	else:
		bump()

func get_input_direction():
	return Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)

func update_look_direction(direction):
	$Pivot/Sprite.rotation = direction.angle()

func move_to(target_position):
	set_process(false)
	$AnimationPlayer.play("walk")

	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - position).normalized()
	$Tween.interpolate_property($Pivot, "position", - move_direction * 32, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	position = target_position

	$Tween.start()

	# Stop the function execution until the animation finished
	yield($AnimationPlayer, "animation_finished")
	
	set_process(true)


func bump():
	set_process(false)
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	set_process(true)
