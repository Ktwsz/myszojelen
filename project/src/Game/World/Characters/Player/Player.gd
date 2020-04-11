extends Character

var RiceBullet = preload("res://src/Game/World/Characters/RiceBullet/RiceBullet.tscn")

onready var shot_particles : Particles2D = $Pivot/Sprite/ShotParticles
onready var shot_particles_default_x = shot_particles.position.x

var shot_particles_position : Dictionary = {
	Facing.TOP_LEFT: Vector2(-130, -60),
	Facing.TOP_RIGHT: Vector2(130, -60),
	Facing.BOTTOM_LEFT: Vector2(-130, -20),
	Facing.BOTTOM_RIGHT: Vector2(130, -20)
}

onready var shot_sound = $ShotSound

const HALF_PI = PI / 2.0

export var joy_sensinitivy := 0.5 

export var wait_time_after_rotate := 0.2 
onready var _time_after_rotate := wait_time_after_rotate

var direction = {
	"UP": Vector2(0, -1),
	"DOWN": Vector2(0, 1),
	"LEFT": Vector2(-1, 0),
	"RIGHT": Vector2(1, 0)
}


func _process(delta) -> void:
	if Input.is_action_pressed("ui_up"):
		get_tree().set_input_as_handled()
		move(direction["UP"])
		_rotate_to(Facing.TOP_RIGHT)
	
	elif Input.is_action_pressed("ui_down"):
		get_tree().set_input_as_handled()
		move(direction["DOWN"])
		_rotate_to(Facing.BOTTOM_LEFT)
	
	elif Input.is_action_pressed("ui_left"):
		get_tree().set_input_as_handled()
		move(direction["LEFT"])
		_rotate_to(Facing.TOP_LEFT)
	
	elif Input.is_action_pressed("ui_right"):
		get_tree().set_input_as_handled()
		move(direction["RIGHT"])
		_rotate_to(Facing.BOTTOM_RIGHT)
	
	elif Input.get_connected_joypads().size() > 0:
		var joy_vec = Vector2(
			Input.get_joy_axis(0, JOY_AXIS_0),
			Input.get_joy_axis(0, JOY_AXIS_1)
		)
		
		if joy_vec.length_squared() < joy_sensinitivy:
			return
		
		var joy_angle = joy_vec.angle()
		var axis : int
		
		
		if joy_angle < 0 and joy_angle > -HALF_PI:
			axis = Facing.TOP_RIGHT
		elif joy_angle < -HALF_PI and joy_angle > -PI:
			axis = Facing.TOP_LEFT
		elif joy_angle > 0 and joy_angle < HALF_PI:
			axis = Facing.BOTTOM_RIGHT
		elif joy_angle > HALF_PI and joy_angle < PI:
			axis = Facing.BOTTOM_LEFT
		
		if axis != facing:
			_rotate_to(axis)
			_time_after_rotate = 0.0
		elif _time_after_rotate >= wait_time_after_rotate:
			move(get_forward_dir())
		else:
			_time_after_rotate += delta


func _unhandled_input(event) -> void:
	if not event is InputEventMouseButton:
		_process_key_input()
		return
	
	if event.button_index != BUTTON_LEFT:
		print(tile_map.get_cellv(tile_map.world_to_map(get_global_mouse_position())))


func _process_key_input() -> void:
	if Input.is_action_just_pressed("shot"):
		_shot()
	
#	if Input.is_action_just_pressed("ui_left"):
#		_rotate(-1)
#		get_tree().set_input_as_handled()
#
#	elif Input.is_action_just_pressed("ui_right"):
#		_rotate(1)
#		get_tree().set_input_as_handled()
#


func _shot() -> void:
	var rice = RiceBullet.instance()
	rice.facing = facing
	world_objects.add_child(rice)
	rice.position = position + tile_map.map_to_world(get_forward_dir())
	rice.tile_map = tile_map
	shot_particles.emitting = true
	shot_sound.play()


func move(dir:Vector2) -> void:
	var target_pos = tile_map.request_move(self, dir)
	
	if target_pos != null:
		move_to(target_pos)


func move_to(target_pos:Vector2) -> void:
	set_process(false)
	.move_to(target_pos)
	yield(self, "move_end")
	set_process(true)


func update_texture() -> void:
	.update_texture()
	
	shot_particles.position = shot_particles_position[facing]
	shot_particles.show_behind_parent = facing == Facing.TOP_LEFT or facing == Facing.TOP_RIGHT
