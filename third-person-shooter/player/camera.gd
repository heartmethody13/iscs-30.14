extends Node3D

@export var character: CharacterBody3D
@export var edge_spring_arm: SpringArm3D
@export var rear_spring_arm: SpringArm3D
@export var camera: Camera3D
@export var bullet_spawnpoint: Node3D

@export var camera_alignment_speed: float = 0.25
@export var aim_rear_spring_length: float = 0.5
@export var aim_edge_spring_length: float = 0.85
@export var aim_speed: float = 0.45
@export var aim_fov: float = 55

@export var sprint_tween_speed: float = 0.5
@export var sprint_fov: float = 95

@export var aim_ray_length: float = 1000.0
@export var min_empty_space_distance: float = 30.0

const BULLET = preload("res://player/bullet.tscn") 

var camera_rotation: Vector2 = Vector2.ZERO
var mouse_sensitivity: float = 0.001
var max_y_rotation: float = 1.2

var camera_tween: Tween

enum CameraAlignment {LEFT = -1, RIGHT = 1, CENTER = 0}
var current_shoulder: int = CameraAlignment.RIGHT

@onready var default_edge_spring_arm_length: float = edge_spring_arm.spring_length
@onready var default_rear_spring_arm_length: float = rear_spring_arm.spring_length
@onready var default_camera_fov: float = camera.fov

#@onready var camera_3d: Camera3D = $EdgeSpringArm/RearSpringArm/Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		var mouse_event: Vector2 = event.screen_relative * mouse_sensitivity
		look(mouse_event)
	
	if event.is_action_pressed("switch_shoulder"):
		switch_shoulder()
	
	if event.is_action_pressed("aim"):
		enter_aim()
	
	if event.is_action_released("aim"):
		exit_aim()
	
	if event.is_action_pressed("sprint"):
		enter_sprint()
	
	if event.is_action_released("sprint"):
		exit_sprint()
	
	if event.is_action_pressed("shoot"):
		shoot()

func look(mouse_movement: Vector2) -> void:
	camera_rotation += mouse_movement
	
	transform.basis = Basis()
	character.transform.basis = Basis()
	
	character.rotate_object_local(Vector3(0, 1, 0), -camera_rotation.x)
	rotate_object_local(Vector3(1, 0, 0), -camera_rotation.y)
	
	camera_rotation.y = clamp(camera_rotation.y, -max_y_rotation, max_y_rotation)


func switch_shoulder() -> void:
	match current_shoulder:
		CameraAlignment.RIGHT:
			set_current_shoulder(CameraAlignment.LEFT)
		CameraAlignment.LEFT:
			set_current_shoulder(CameraAlignment.RIGHT)
		CameraAlignment.CENTER:
			return
	
	var new_pos: float = default_edge_spring_arm_length * current_shoulder
	set_rear_spring_arm_position(new_pos, camera_alignment_speed)


func set_current_shoulder(shoulder: CameraAlignment) -> void:
	current_shoulder = shoulder


func set_rear_spring_arm_position(position: float, speed: float) -> void:
	if camera_tween:
		camera_tween.kill()
	
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.set_ease(Tween.EASE_OUT)
	
	camera_tween.tween_property(edge_spring_arm, "spring_length", position, speed)


func enter_aim() -> void:
	if camera_tween:
		camera_tween.kill()
	
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.set_ease(Tween.EASE_OUT)
	
	camera_tween.tween_property(camera, "fov", aim_fov, aim_speed)
	camera_tween.tween_property(edge_spring_arm, "spring_length", aim_edge_spring_length * current_shoulder, aim_speed)
	camera_tween.tween_property(rear_spring_arm, "spring_length", aim_rear_spring_length, aim_speed)


func exit_aim() -> void:
	if camera_tween:
		camera_tween.kill()
	
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.set_ease(Tween.EASE_OUT)
	
	camera_tween.tween_property(camera, "fov", default_camera_fov, aim_speed)
	camera_tween.tween_property(edge_spring_arm, "spring_length", default_edge_spring_arm_length * current_shoulder, aim_speed)
	camera_tween.tween_property(rear_spring_arm, "spring_length", default_rear_spring_arm_length, aim_speed)


func enter_sprint() -> void:
	if camera_tween:
		camera_tween.kill()
	
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.set_ease(Tween.EASE_OUT)
	
	camera_tween.tween_property(camera, "fov", sprint_fov, sprint_tween_speed)
	camera_tween.tween_property(edge_spring_arm, "spring_length", default_edge_spring_arm_length * current_shoulder, aim_speed)
	camera_tween.tween_property(rear_spring_arm, "spring_length", default_rear_spring_arm_length, aim_speed)


func exit_sprint() -> void:
	if camera_tween:
		camera_tween.kill()
	
	camera_tween = get_tree().create_tween()
	camera_tween.set_parallel()
	
	camera_tween.set_trans(Tween.TRANS_EXPO)
	camera_tween.set_ease(Tween.EASE_OUT)
	
	camera_tween.tween_property(camera, "fov", default_camera_fov, sprint_tween_speed)
	camera_tween.tween_property(edge_spring_arm, "spring_length", default_edge_spring_arm_length * current_shoulder, aim_speed)
	camera_tween.tween_property(rear_spring_arm, "spring_length", default_rear_spring_arm_length, aim_speed)


func shoot() -> void:
	var new_bullet: Bullet = BULLET.instantiate()
	get_tree().current_scene.add_child(new_bullet)

	var target: Vector3 = get_aim_target()
	var spawn_pos: Vector3 = bullet_spawnpoint.global_position
	var direction: Vector3 = (target - spawn_pos).normalized()
	
	new_bullet.initialize(spawn_pos, direction, 20)
	
	#var forward: Vector3 = -camera.global_basis.z
	#var spawn_pos: Vector3 = camera.global_position + forward * 1.5
	#new_bullet.initialize(spawn_pos, forward, 20)


func get_aim_target() -> Vector3:
	var ray := get_screen_center_ray()
	var start: Vector3 = ray["origin"]
	var forward: Vector3 = ray["direction"]
	var end: Vector3 = start + forward * 1000.0

	var query := PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [character]
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)

	if not result.is_empty():
		return result["position"]

	return start + forward * max(min_empty_space_distance, aim_ray_length)

func get_screen_center_ray() -> Dictionary:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var screen_center: Vector2 = viewport_size * 0.5

	var ray_origin: Vector3 = camera.project_ray_origin(screen_center)
	var ray_direction: Vector3 = camera.project_ray_normal(screen_center).normalized()

	return {
		"origin": ray_origin,
		"direction": ray_direction
	}
