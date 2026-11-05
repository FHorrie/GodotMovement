extends CharacterBody3D

const DEFAULT_SPEED = 4.0
const CRAWL_SPEED = DEFAULT_SPEED / 2

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
		rotate_camera(event.relative, MOUSE_SENSITIVITY)

func _physics_process(delta: float) -> void:
	if is_on_floor():
		Input.is_action_pressed("creep");
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		handle_ground_movement(delta)
	else:
		handle_air_movement(delta)
	
	# Controller camera input
	rotate_camera(
		Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down"), 
		CONTROLLER_SENSITIVITY)
	
	move_and_slide()

func rotate_camera(vector: Vector2, sens: float) -> void:
	rotate_y(-vector.x * sens)
	camera.rotate_x(-vector.y * sens)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-MAX_CAMERA_ANGLE), deg_to_rad(MAX_CAMERA_ANGLE))

func get_speed() -> float:
	return CRAWL_SPEED if Input.is_action_pressed("crawl") else DEFAULT_SPEED

func handle_air_movement(delta: float) -> void:
	# Add the gravity.
	velocity += get_gravity() * delta

func handle_ground_movement(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var currentSpeed := get_speed()
	
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)
