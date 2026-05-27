extends Node
class_name PlayerController

enum MoveState {WALK, JOG, SPRINT, CROUCH}
@export var _move_state: MoveState = MoveState.WALK

@onready var player := get_parent() as CharacterBody3D
@onready var manager := get_parent() as PlayerManager

var _movement_scale: float = 1.0
@export var _base_speed: float = 10.0


func _ready() -> void:
	pass # Replace with function body.
	
func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var speed = _base_speed
	if Input.is_action_pressed("move_jog"):
		_move_state = MoveState.JOG
	elif Input.is_action_pressed("move_sprint"): # add conditions
		_move_state = MoveState.SPRINT
	elif Input.is_action_pressed("move_crouch"):
		_move_state = MoveState.CROUCH
	else:
		_move_state = MoveState.WALK
		
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
