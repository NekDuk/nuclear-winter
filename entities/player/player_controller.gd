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
