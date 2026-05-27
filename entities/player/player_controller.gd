extends Node
class_name PlayerController

enum MoveState {WALK, JOG, SPRINT, CROUCH, AIM}
@export var _move_state: MoveState = MoveState.WALK

@onready var player := get_parent() as CharacterBody3D
@onready var manager := get_parent() as PlayerManager
@export var camera: Camera3D

var _movement_scale: float = 1.0
@export var _base_speed: float = 10.0

var aiming: bool = false
var turning: bool = false

@export var _turn_speed: float = 2.0
var _target_look_pos: Vector3 = Vector3(0, 0, 0)
@export var _look_angle: float = 15.0: # pre-convert angle to dot
	set(value):
		_look_angle = value
		_dot_threshold = cos(deg_to_rad(_look_angle / 2.0))

var _dot_threshold: float = 0.707 # Defaults to 45 degrees


func _ready() -> void:
	pass # Replace with function body.
	
	#FIX, AI DOESNT HELP, LOOK PROPER
func turn_towards_target() -> void:
	var target_flat := Vector3(_target_look_pos.x, player.global_position.y, _target_look_pos.z)
	
	# prevent looking if target is near player position
	if player.global_position.is_equal_approx(target_flat): 
		return
	
	var current_quaternion := player.global_transform.basis.get_rotation_quaternion()
	
	var target_transform := player.global_transform.looking_at(target_flat, Vector3.UP)
	var target_quaternion := target_transform.basis.get_rotation_quaternion()
	
	# 4. Calculate our max angular step for this specific frame
	var max_step_radians := deg_to_rad(_turn_speed)
	
	# 5. Step toward the target orientation at a completely constant speed
	var next_quaternion := current_quaternion.rotate_toward(target_quaternion, max_step_radians)
	
	# 6. Apply the new rotation back to the object's global basis matrix
	global_transform.basis = Basis(next_quaternion)
	
func is_target_looked() -> bool:
	var forward_dir := -player.global_transform.basis.z.normalized()
	var dir_to_target := (_target_look_pos - player.global_position).normalized()
	
	var dot_product := forward_dir.dot(dir_to_target)
	
	#NOTE: study up on dot products
	return dot_product >= _dot_threshold

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var speed = _base_speed
	
	if is_target_looked():
		if Input.is_action_pressed("move_jog"):
			_move_state = MoveState.JOG
		elif Input.is_action_pressed("move_sprint"): # add conditions
			_move_state = MoveState.SPRINT
		elif Input.is_action_pressed("move_crouch"):
			_move_state = MoveState.CROUCH
		else:
			_move_state = MoveState.WALK
	else:
		speed = 0.0
		turn_towards_target()

	match _move_state:
		MoveState.WALK:
			speed *= manager.walk_scale
		MoveState.JOG:
			speed *= manager.jog_scale
		MoveState.SPRINT:
			speed *= manager.sprint_scale
		MoveState.CROUCH:
			speed *= manager.crouch_scale

	speed *= _movement_scale

	if direction:
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		player.velocity.z = move_toward(player.velocity.z, 0, speed)
		
	player.move_and_slide()
