extends Node3D

@export var duration: float = 0.4
@onready var big_explosion = $explosion_sprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	big_explosion.play("explode")
	big_explosion.animation_finished.connect(_on_animation_finished)
	#get_tree().create_timer(duration).timeout.connect(queue_free)

func _on_animation_finished() -> void:
	queue_free()
