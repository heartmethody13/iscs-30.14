extends Node3D

@export var duration: float = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(duration).timeout.connect(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
