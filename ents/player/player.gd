class_name Player
extends CharacterBody3D


@export var speed = 15.0
@export var fall_accel = 35.0
@export_range(0.0,1.0) var mouse_sens = 0.01
@export var tilt_limit = deg_to_rad(65.)
@export var jump_force = 25.
@export var rotation_speed = 25.
@export var max_sprint_speed = 5.

@onready var _camera := $CameraPivot/SpringArm3D/Camera3D as Camera3D
@onready var _camera_pivot := $CameraPivot as Node3D
@onready var _model := $Model as Node3D

var target_velocity = Vector3.ZERO
var max_jumps = 2
var current_jump = 1

var sprint_speed = 1.

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("primary"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func _unhandled_input(event: InputEvent) -> void:
	# Mouselook implemented using 'screen_relative' for resolution-independent sensitivity.
	if event is InputEventMouseMotion:
		_camera_pivot.rotation.x -= event.screen_relative.y * mouse_sens
		# Prevent the camera from rotating too far up or down
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y += -event.screen_relative.x * mouse_sens
		

func _physics_process(delta: float) -> void:
	var basis := _camera_pivot.global_transform.basis

	# Camera arrows, flattened onto the floor.
	var forward := -basis.z
	forward.y = 0
	forward = forward.normalized()

	var right := basis.x
	right.y = 0
	right = right.normalized()

	# Add directions together instead of replacing them.
	var direction := Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction += forward
	if Input.is_action_pressed("move_back"):
		direction -= forward
	if Input.is_action_pressed("move_right"):
		direction += right
	if Input.is_action_pressed("move_left"):
		direction -= right

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	target_velocity.x = direction.x * (speed + sprint_speed)
	target_velocity.z = direction.z * (speed + sprint_speed)

	if not Input.is_action_pressed("look_around"):
		_model.rotation.y = lerpf(_model.rotation.y, _camera_pivot.rotation.y, rotation_speed * delta)

	if is_on_floor():
		target_velocity.y = 0
		current_jump = 0
		
		if Input.is_action_pressed("sprint"):
			sprint_speed = max_sprint_speed
		else:
			sprint_speed = 1.
		
		if Input.is_action_just_pressed("jump") and current_jump < max_jumps:
			target_velocity.y = jump_force
			current_jump += 1
	else:
		target_velocity.y -= fall_accel * delta
		if Input.is_action_just_pressed("jump") and current_jump < max_jumps:
			target_velocity.y = jump_force
			current_jump += 1

	velocity = target_velocity
	move_and_slide()
	
	
