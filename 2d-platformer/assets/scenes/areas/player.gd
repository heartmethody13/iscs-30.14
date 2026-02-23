extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var speed = 200
@export var jump_speed = -400
@export var gravity = 1200
var direction_last_facing = "right"

var spring = -600

func _physics_process(delta):
	# Add gravity every frame
	
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed

	# Input affects x axis only
	var direction = Input.get_axis("walk_left", "walk_right")
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
  update_animations(direction)
	move_and_slide()
	# Only allow jumping when on the ground
		
func _input(event : InputEvent):
	if(event.is_action_pressed("fall") && is_on_floor()):
		position.y += 1;

func update_animations(direction):
	var current_direction = null
	if direction != 0:
		current_direction = "side"
		sprite.flip_h = (direction < 0)
	
	if current_direction != null:
		direction_last_facing = current_direction
	
	if direction == 0 :
		sprite.play("idle")
		sprite.stop()
	else:
		sprite.play("walk")
		await sprite.animation_finished


func _on_spring_body_entered(body: Node2D) -> void:
	velocity.y = spring
