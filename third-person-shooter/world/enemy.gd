extends CharacterBody3D

var health: int = 3
var _big_explosion_scene: PackedScene = preload("res://world/big_explosion.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func take_hit() -> void:
	health -= 1
	if health <= 0:
		var exp: Node3D = _big_explosion_scene.instantiate()
		exp.global_position = global_position
		get_tree().current_scene.add_child(exp)
		queue_free()
