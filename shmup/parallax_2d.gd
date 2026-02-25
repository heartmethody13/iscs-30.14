extends ParallaxBackground

@export var scroll_speed = 200

func _process(delta: float) -> void:
	# This moves the "offset" of the background infinitely
	scroll_base_offset.y += scroll_speed * delta
