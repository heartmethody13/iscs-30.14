extends Node3D

var direction: Vector3 = Vector3.FORWARD
var speed: float = 20.0
var _lifetime: float = 5.0

var _explosion_scene: PackedScene = preload("res://world/explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_lifetime -= delta
	if _lifetime <= 0.0:
		queue_free()
		return

	var prev_pos: Vector3 = global_position
	global_position += direction * speed * delta

	# Short-distance raycast from previous position to new position for collision
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(prev_pos, global_position)
	query.collision_mask = 5  # layer 1 (world) + layer 3 (enemy)
	var result: Dictionary = space_state.intersect_ray(query)

	if result:
		_spawn_explosion(result.position)
		if result.collider.has_method("take_hit"):
			result.collider.take_hit()
		queue_free()


func _spawn_explosion(pos: Vector3) -> void:
	var exp: Node3D = _explosion_scene.instantiate()
	exp.global_position = pos
	get_tree().current_scene.add_child(exp)
