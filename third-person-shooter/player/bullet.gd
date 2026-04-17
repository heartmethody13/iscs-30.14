extends Node3D
class_name Bullet

var _small_explosion_scene: PackedScene = preload("res://world/explosion.tscn")

var bullet_velocity: Vector3 = Vector3.ZERO
var speed: float = 100.0
var lifetime: float = 5.0
var age: float = 0
var shot_direction: Vector3 = Vector3.ZERO

var gravity: Vector3

@onready var raycast: RayCast3D = $RayCast3D

var direction: Vector3 = Vector3.FORWARD

var explosion_scene: PackedScene = preload("res://world/explosion.tscn")

func initialize(start_position: Vector3, direction: Vector3, initial_speed: float) -> void:
	global_position = start_position
	shot_direction = direction
	bullet_velocity = shot_direction * initial_speed
	speed = initial_speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#gravity = ProjectSettings.get_setting("physics/3d/default_gravity_vector") * ProjectSettings.get_setting("physics/3d/default_gravity")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#lifetime -= delta
	#if lifetime <= 0.0:
		#queue_free()
		#return
#
	#var prev_pos: Vector3 = global_position
	#global_position += direction * speed * delta
#
	## Short-distance raycast from previous position to new position for collision
	#var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	#var query := PhysicsRayQueryParameters3D.create(prev_pos, global_position)
	#query.collision_mask = 5  # layer 1 (world) + layer 3 (enemy)
	#var result: Dictionary = space_state.intersect_ray(query)
#
	#if result:
		#_spawn_explosion(result.position)
		#if result.collider.has_method("take_hit"):
			#result.collider.take_hit()
		#queue_free()

func _physics_process(delta: float) -> void:
	age += delta
	if age >= lifetime:
		queue_free()
		return
	
	#bullet_velocity += gravity * delta
	
	var movement_distance = bullet_velocity.length() * delta
	
	raycast.target_position = bullet_velocity.normalized() * movement_distance
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		var collider = raycast.get_collider()
		
		print("bullet hit: ", collider)
		print("collider class: ", collider.get_class() if collider else "none")
		
		global_position = collision_point
		
		if collider:
			var exp: Node3D = _small_explosion_scene.instantiate()
			exp.global_position = collision_point + collision_normal * 0.15
			get_tree().current_scene.add_child(exp)

			if collider.has_method("take_hit"):
				collider.take_hit(collision_point)
				print("Enemy Hit")
		else:
			print("no take_hit on collider\n")
		
		queue_free()
		return
	
	global_position += bullet_velocity * delta

func _spawn_explosion(pos: Vector3) -> void:
	var exp: Node3D = explosion_scene.instantiate()
	exp.global_position = pos
	get_tree().current_scene.add_child(exp)
