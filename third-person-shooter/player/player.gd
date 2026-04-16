extends CharacterBody3D

#const BULLET = preload("res://player/bullet.tscn") 

const SPEED: float = 6.0
const SPRINT_SPEED: float = 12
const JUMP_VELOCITY: float = 5.5

#@onready var camera: Camera3D = $Camera/EdgeSpringArm/RearSpringArm/Camera3D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction.x * SPRINT_SPEED
		else:
			velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

#func shoot() -> void:
	#var new_bullet: Bullet = BULLET.instantiate()
	#get_tree().current_scene.add_child(new_bullet)
	#new_bullet.initialize(camera.global_position, camera.global_basis.z, 800)
