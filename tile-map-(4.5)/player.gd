extends CharacterBody2D


const SPEED = 300.0
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var horizontal_direction := Input.get_axis("ui_left", "ui_right")
	var vertical_direction := Input.get_axis("ui_up", "ui_down")
	
	if horizontal_direction:
		velocity.x = horizontal_direction * SPEED
		velocity.y = 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	if vertical_direction:
		velocity.y = vertical_direction * SPEED
		velocity.x = 0
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		

	move_and_slide()
	update_animations(horizontal_direction, vertical_direction)
	

func update_animations(h_dir, v_dir):
	if h_dir != 0:
		
		sprite.play("walk_side")
		sprite.flip_h = (h_dir < 0) # Flips the sprite when moving left
	elif v_dir > 0:
		sprite.play("walk_down")
	elif v_dir < 0:
		sprite.play("walk_up")
	else:
		if sprite.animation:
			sprite.stop()
			sprite.frame = 0
