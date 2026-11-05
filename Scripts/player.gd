extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const MAX_CAMERA_ANGLE = 90

const MOUSE_SENSITIVITY = 0.003
const CONTROLLER_SENSITIVITY = 0.05

@onready var camera = $Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotateCamera(event.relative, MOUSE_SENSITIVITY)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var cameraInput := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	rotateCamera(cameraInput, CONTROLLER_SENSITIVITY)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func rotateCamera(vector: Vector2, sens: float) -> void:
	rotate_y(-vector.x * sens)
	camera.rotate_x(-vector.y * sens)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-MAX_CAMERA_ANGLE), deg_to_rad(MAX_CAMERA_ANGLE))
