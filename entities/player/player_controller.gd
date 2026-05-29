extends Node
class_name PlayerController

enum MoveState {WALK, JOG, SPRINT, CROUCH, AIM}

@onready var _player := get_parent() as CharacterBody3D
@onready var _cam_controller := $"../CameraPivot" as CameraController

var _movement_scale: float = 1.0
@export var _strafe_penalty := 0.5
@export var _back_penalty := 0.9
@export var _base_speed := 10.0
@export var _stop_speed := 10.0
@export var _turn_speed := 3.14 # radians
@export var _forward_cutoff := .3
var _target_position: Vector3 = Vector3.ZERO

var _aiming: bool = false
var _turning: bool = false

func start_aim(target_pos: Vector3) -> void:
	_aiming = true
	_target_position = target_pos

func stop_aim() -> void:
	_aiming = false

func turn_towards_target(delta: float) -> void:
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
	var input_dir = Input.get_vector("move_left", "move_right", "move_back", "move_forward")
	
	if input_dir != Vector2.ZERO:
		var forward_dir: Vector3 = -_cam_controller.player_basis.z * input_dir.y
		var right_dir: Vector3 = _cam_controller.player_basis.x * input_dir.x
		var move_dir = forward_dir + right_dir
		
		if _aiming:
			turn_towards_target(delta)
			
			var dot = -_player.basis.z.dot(move_dir.normalized())
			var forward_vel = forward_dir * speed
			var right_vel = right_dir * speed
			
			if dot < _forward_cutoff and dot > -_forward_cutoff:
				right_vel *= _strafe_penalty
			elif dot < -_forward_cutoff:
				forward_vel *= _back_penalty
				
			_player.velocity = forward_vel + right_vel
		else:
			_target_position = _player.global_position + move_dir
			turn_towards_target(delta)
			
			if not _turning:
				_player.velocity = -_player.basis.z * speed
			else:
				_player.velocity = Vector3.ZERO
	else:
		if _aiming:
			turn_towards_target(delta)
		# Added * delta here to fix frame-rate independence
		_player.velocity = _player.velocity.move_toward(Vector3.ZERO, _stop_speed * delta)
	
	_player.move_and_slide()
