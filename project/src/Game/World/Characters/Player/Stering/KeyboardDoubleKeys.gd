extends SteringBaseScript

var _direction_actions = {
	"up_right": [ "ui_up", "ui_right" ],
	"up" : [ "ui_up" ],
	"down_left": [ "ui_down", "ui_left" ],
	"down" : [ "ui_down" ],
	"up_left": [ "ui_up", "ui_left" ],
	"left" : [ "ui_left" ],
	"down_right": [ "ui_down", "ui_right" ],
	"right": [ "ui_right" ]
}


func steer(delta:float) -> bool:
	
	var requested_direction : int = -1
	var force_move := false
	var facing = player.facing
	
	var Facing = Character.Facing
	
	if _want_move_to_dir("up_right"):
		force_move = Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_right")
		requested_direction = Facing.TOP_RIGHT
	
	elif _want_move_to_dir("down_left"):
		force_move = Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left")
		requested_direction = Facing.BOTTOM_LEFT
	
	elif _want_move_to_dir("up_left"):
		force_move = Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up")
		requested_direction = Character.Facing.TOP_LEFT
	
	elif _want_move_to_dir("down_right"):
		force_move = Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down")
		requested_direction = Facing.BOTTOM_RIGHT

	elif _want_move_to_dir("up"):
		force_move = Input.is_action_just_pressed("ui_up")
		requested_direction = Facing.TOP
	
	elif _want_move_to_dir("down"):
		force_move = Input.is_action_just_pressed("ui_down")
		requested_direction = Facing.BOTTOM
	
	elif _want_move_to_dir("left"):
		force_move = Input.is_action_just_pressed("ui_left")
		requested_direction = Character.Facing.LEFT
	
	elif _want_move_to_dir("right"):
		force_move = Input.is_action_just_pressed("ui_right")
		requested_direction = Facing.RIGHT		
	
	if requested_direction > -1:
		if requested_direction != facing:
			player._rotate_to(requested_direction)
			_time_after_rotate = 0.0
		elif ((force_move and facing == requested_direction) 
			or _time_after_rotate >= wait_time_after_rotate):
			player.move(player.get_forward_dir())
		else:
			_time_after_rotate += delta
		
		return true
	
	return false


func _want_move_to_dir(dir:String) -> bool:
	for action in _direction_actions[dir]:
		if not Input.is_action_pressed(action):
			return false

	return true
