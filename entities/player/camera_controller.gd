extends Node3D

@onready var _camera: Camera3D = $Camera 
@export var _mouse_sensitivity: float = .001 
@export var _smooth_speed: float = 10.0
var _yaw: float = 0.0
@export var _pitch: float = -60.0

@export_group("Zoom Settings")
@export var _min_size: float = 3.0
@export var _max_size: float = 20.0
@export var _zoom_step: float = 1.5
@export var _zoom_speed: float = 10.0 # interpolation speed
var _target_size: float = 7.0

func _ready() -> void:
	_target_size = _camera.size

func snap_angle(current_yaw_radians: float, snap_angle_degrees: float) -> float:
	var current_degrees = rad_to_deg(current_yaw_radians)
	var snapped_degrees = round(current_degrees / snap_angle_degrees) * snap_angle_degrees
	return deg_to_rad(snapped_degrees)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		_target_size = clamp(_target_size - _zoom_step, _min_size, _max_size)
	elif event.is_action_pressed("zoom_out"):
		_target_size = clamp(_target_size + _zoom_step, _min_size, _max_size)
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotate"):
			_yaw += event.relative.x * _mouse_sensitivity
	
	if Input.is_action_just_released("camera_rotate"):
		# Snap the target yaw to the nearest 45 degrees
		_yaw = snap_angle(_yaw, 45.0)

func _process(delta: float) -> void:
	# rotation
	var current_rot: Quaternion = global_basis.get_rotation_quaternion()
	var target_rot: Quaternion = Quaternion.from_euler(Vector3(_pitch, _yaw, 0))
	var blended_rot: Quaternion = current_rot.slerp(target_rot, _smooth_speed * delta)
	
	global_basis = Basis(blended_rot)
	
	# zoom
	if not is_equal_approx(_camera.size, _target_size):
		_camera.size = move_toward(_camera.size, _target_size, _zoom_speed * delta)
