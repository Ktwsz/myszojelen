extends SteringBaseScript

const HALF_PI = PI / 2.0
const QUART_PI = PI / 4.0

export var joy_sensinitivy := 0.5 

const ANGLE_OFFSET = PI / 8.0

# These are angle ranges for joypad directions
onready var FACING_ANGLES : Dictionary = {
	Character.Facing.TOP_LEFT: { 'min': -PI + ANGLE_OFFSET, 'max': -3 * QUART_PI + ANGLE_OFFSET },
	Character.Facing.TOP: { 'min': -3 * QUART_PI + ANGLE_OFFSET, 'max': -HALF_PI + ANGLE_OFFSET },
	Character.Facing.TOP_RIGHT: { 'min': -HALF_PI + ANGLE_OFFSET, 'max': -QUART_PI + ANGLE_OFFSET },
	Character.Facing.RIGHT: { 'min': -QUART_PI + ANGLE_OFFSET, 'max': 0 + ANGLE_OFFSET },
	Character.Facing.BOTTOM_RIGHT: { 'min': 0 + ANGLE_OFFSET, 'max': QUART_PI + ANGLE_OFFSET },
	Character.Facing.BOTTOM: { 'min': QUART_PI + ANGLE_OFFSET, 'max': HALF_PI + ANGLE_OFFSET },
	Character.Facing.BOTTOM_LEFT: { 'min': HALF_PI + ANGLE_OFFSET, 'max': 3 * QUART_PI + ANGLE_OFFSET }, 
	Character.Facing.LEFT: { 'min': 3 * QUART_PI + ANGLE_OFFSET, 'max': PI + ANGLE_OFFSET }
}

func steer(delta:float) -> bool:
	var requested_direction = _get_axis_from_joy()
	
	if requested_direction == -1:
		return false
	
	if requested_direction != player.facing:
		player._rotate_to(requested_direction)
		_time_after_rotate = 0.0
	
	elif _time_after_rotate >= wait_time_after_rotate:
		player.move(player.get_forward_dir())
	
	else:
		_time_after_rotate += delta
	
	return true


func _get_axis_from_joy() -> int:
	var joy_vec := Vector2.ZERO
	
	if touchscreen_layer.visible:
		joy_vec = touchscreen_layer.get_joy_vec()
	
	if Input.get_connected_joypads().size() > 0:
		var joypad_vec = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_0),
			Input.get_joy_axis(0, JOY_AXIS_1)
		)
		
		if joypad_vec.length_squared() > joy_vec.length_squared():
			joy_vec = joypad_vec
	
	if joy_vec.length() < joy_sensinitivy:
		return -1
	
	var joy_angle = joy_vec.angle()
	
	for facing in Character.Facing.values():
		if _is_in_facing_angle(joy_angle, facing):
			return facing

	return -1


func _is_in_facing_angle(val:float, facing: int) -> bool:
	return val > FACING_ANGLES[facing].min and val < FACING_ANGLES[facing].max
