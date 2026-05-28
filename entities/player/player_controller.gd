extends Node
class_name PlayerController

enum MoveState {WALK, JOG, SPRINT, CROUCH, AIM}
#@export var _move_state: MoveState = MoveState.WALK

@onready var player := get_parent() as CharacterBody3D
@onready var manager := get_parent() as PlayerManager
@onready var cam_controller: CameraController = $"../CameraPivot"

var _movement_scale: float = 1.0
@export var _base_speed: float = 10.0
@export var _stop_speed: float = 10.0

var aiming: bool = false
var turning: bool = false

func _physics_process(delta: float) -> void:
	var speed = _base_speed * _movement_scale
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"), 
		Input.get_axis("move_back", "move_forward"))

	if input_dir:
		var raw_dir: Vector3 = (
			-cam_controller.player_basis.z * input_dir.y) + (
			cam_controller.player_basis.x * input_dir.x)
		
		var move_dir := Vector3(raw_dir.x, 0, raw_dir.z).normalized()

		player.velocity = move_dir * speed
	else:
		player.velocity = player.velocity.move_toward(Vector3.ZERO, _stop_speed * delta)
	
	player.move_and_slide()
