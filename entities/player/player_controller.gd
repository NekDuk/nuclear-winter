extends Node
class_name PlayerController

enum MoveState {WALK, JOG, SPRINT, CROUCH, AIM}
#@export var _move_state: MoveState = MoveState.WALK

@onready var _player := get_parent() as CharacterBody3D
#@onready var _manager := get_parent() as PlayerManager
@onready var _cam_controller:= $"../CameraPivot" as CameraController

var _movement_scale: float = 1.0
@export var _strafe_penalty := 0.5
@export var _back_penalty := 0.9
@export var _base_speed := 10.0
@export var _stop_speed := 10.0
@export var _turn_speed := 3.14 # radians
var _target_position: Vector3 = Vector3.ZERO

var _aiming: bool = false
var _turning: bool = false

func start_aim(target_pos: Vector3) -> void:
	#dot math to look
	_aiming = true
	_target_position = target_pos

func stop_aim() -> void:
	_aiming = false

func turn_towards_target(delta: float) -> void:
	# turning
	var target_dir = _target_position - _player.global_position
	target_dir.y = 0 # flatten
	
	if not target_dir.is_zero_approx():
		var target_basis = Basis.looking_at(target_dir.normalized(), Vector3.UP)
		var current_quat = _player.global_basis.get_rotation_quaternion()
		var target_quat = target_basis.get_rotation_quaternion()
		var angle_to_target = current_quat.angle_to(target_quat)
		_turning = angle_to_target > 0.01
		
		if _turning:
			var max_step = _turn_speed * delta
			var weight = min(1.0, max_step / angle_to_target)
			var final_quat = current_quat.slerp(target_quat, weight)
			_player.global_basis = Basis(final_quat)
			
			
func _physics_process(delta: float) -> void:
	var speed = _base_speed * _movement_scale
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"), 
		Input.get_axis("move_back", "move_forward"))

	#turning
	turn_towards_target(delta)
	
	# movement
	if input_dir:
		if _aiming:
			pass
		else:
			var forward_dir := Vector3(-_cam_controller.player_basis.z * input_dir.y).normalized()
			var right_dir := Vector3(_cam_controller.player_basis.x * input_dir.x).normalized()
			_target_position = _player.global_position + (forward_dir + right_dir)
			if not _turning:
				_player.velocity = -_player.basis.z * speed
			else:
				_player.velocity = _player.velocity.move_toward(Vector3.ZERO, _stop_speed * delta)
	else:
		_player.velocity = _player.velocity.move_toward(Vector3.ZERO, _stop_speed * delta)
	
	_player.move_and_slide()
