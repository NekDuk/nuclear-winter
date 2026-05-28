extends Node
class_name PlayerController

enum MoveState {WALK, JOG, SPRINT, CROUCH, AIM}
#@export var _move_state: MoveState = MoveState.WALK

@onready var _player := get_parent() as CharacterBody3D
#@onready var _manager := get_parent() as PlayerManager
@onready var _cam_controller:= $"../CameraPivot" as CameraController

var _movement_scale: float = 1.0
@export var _strafe_scale := 0.5
@export var _base_speed := 10.0
@export var _stop_speed := 10.0

var _aiming: bool = false
var _turning: bool = false

func start_aim(target_pos: Vector3) -> void:
	#dot math to look
	_aiming = true

func stop_aim() -> void:
	_aiming = false


func _physics_process(delta: float) -> void:
	var speed = _base_speed * _movement_scale
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"), 
		Input.get_axis("move_back", "move_forward"))

	"""
	if input_dir:
		var forward_dir := Vector3(-_cam_controller.player_basis.z * input_dir.y).normalized()
		var right_dir := Vector3(_cam_controller.player_basis.x * input_dir.x).normalized()
		
		
		
		_player.velocity = forward_velocity + right_velocity
	else:
		_player.velocity = _player.velocity.move_toward(Vector3.ZERO, _stop_speed * delta)
	
	_player.move_and_slide()
	"""
