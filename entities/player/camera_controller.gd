extends Node3D
class_name CameraController

@onready var _player := get_parent() as CharacterBody3D
@onready var _camera := $Camera as Camera3D
@onready var _controller := $"../Controller" as PlayerController

@export var _mouse_sensitivity := .001 
@export var _smooth_speed := 10.0
var _yaw := 0.0
@export var _pitch := -60.0
var player_basis := Basis()

@export_group("Zoom Settings")
@export var _min_size := 3.0
@export var _max_size := 20.0
@export var _zoom_step := 1.5
@export var _zoom_speed := 10.0 

var _target_size:= 7.0
var _offset: Vector3

func _ready() -> void:
	_target_size = _camera.size
	set_as_top_level(true)
	_offset = _camera.global_position - _player.global_position

func _snap_angle(current_yaw_radians: float, snap_angle_degrees: float) -> float:
	var current_degrees = rad_to_deg(current_yaw_radians)
	var snapped_degrees = round(current_degrees / snap_angle_degrees) * snap_angle_degrees
	return deg_to_rad(snapped_degrees)

func _get_mouse_real_world() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()

	var ray_origin = _camera.project_ray_origin(mouse_pos)
	var ray_dir = _camera.project_ray_normal(mouse_pos)
	var floor_plane = Plane(Vector3.UP, _player.global_position.y)
	var intersection = floor_plane.intersects_ray(ray_origin, ray_dir)

	if intersection:
		return intersection

	return Vector3.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		_target_size = clamp(_target_size - _zoom_step, _min_size, _max_size)
	elif event.is_action_pressed("zoom_out"):
		_target_size = clamp(_target_size + _zoom_step, _min_size, _max_size)
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("camera_rotate"):
			_yaw += event.relative.x * _mouse_sensitivity
	
	if Input.is_action_just_released("camera_rotate"):
		_yaw = _snap_angle(_yaw, 45.0)

func _process(delta: float) -> void:
	if Input.is_action_pressed("aim"):
		_controller.start_aim(_get_mouse_real_world())
	elif Input.is_action_just_released("aim"):
		_controller.stop_aim()

	# Camera tracking
	global_position = _player.global_position + _offset
	
	# Rotation math
	var current_rot: Quaternion = global_basis.get_rotation_quaternion()
	var target_rot: Quaternion = Quaternion.from_euler(Vector3(0, _yaw, 0))
	var blended_rot: Quaternion = current_rot.slerp(target_rot, _smooth_speed * delta)
	
	_camera.rotation_degrees = Vector3(_pitch, 0, 0)
	global_basis = Basis(blended_rot)
	
	# Zoom scaling
	if not is_equal_approx(_camera.size, _target_size):
		_camera.size = move_toward(_camera.size, _target_size, _zoom_speed * delta)
		
	_update_movement_vectors()    
		
func _update_movement_vectors() -> void:
	var current_degrees = wrapf(rad_to_deg(_yaw), 0, 360)
	var snapped_degrees = floorf(current_degrees / 90) * 90
	var forward_angle := Quaternion.from_euler(Vector3(0, deg_to_rad(snapped_degrees), 0))
	player_basis = Basis(forward_angle)
