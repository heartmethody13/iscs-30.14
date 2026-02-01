extends CharacterBody2D


@onready var sprite = $AnimatedSprite2D
@onready var ray = $RayCast2D

const SPEED = 32.0
const TILE_SIZE = 32
const INPUTS = {"ui_left": Vector2.LEFT, "ui_right": Vector2.RIGHT, "ui_up": Vector2.UP, "ui_down": Vector2.DOWN}
const ANIMATION_SPEED = 4
var moving = false
var direction_last_facing = "down"

#func _physics_process(delta: float) -> void:
	##velocity = Vector2(10,10)
	#velocity = velocity/2
	#move_and_slide()
func _ready():
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE/2
	
func _input(event) -> void:
	if moving:
		return

	for direction in INPUTS.keys():
		var action = INPUTS[direction]
		if event.is_action(direction):
			move(direction)

func move(direction) -> void:
	ray.target_position = INPUTS[direction] * TILE_SIZE
	ray.force_raycast_update()
	
	if ray.is_colliding() == false:
		#position += INPUTS[direction] * TILE_SIZE
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + INPUTS[direction] * TILE_SIZE, 1.0 / ANIMATION_SPEED).set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(self, "position", position + INPUTS[direction] * TILE_SIZE, 1.0 / ANIMATION_SPEED).set_ease(Tween.EASE_IN_OUT)
		
		moving = true
		$AnimationPlayer.play(direction)
		update_animations(INPUTS[direction].x, INPUTS[direction].y)
		
		await tween.finished
		moving = false
		update_animations(0, 0)

	else:
		update_animations(INPUTS[direction].x, INPUTS[direction].y)
		update_animations(0, 0)


func update_animations(h_dir, v_dir):
	var current_direction = null
	if h_dir != 0:
		current_direction = "side"
		sprite.flip_h = (h_dir < 0)
	elif v_dir > 0: current_direction = "down"
	elif v_dir < 0: current_direction = "up"
	
	if current_direction != null:
		direction_last_facing = current_direction
		
	if h_dir == 0 and v_dir == 0:
		sprite.play("walk_" + direction_last_facing)
		sprite.stop()
	else:
		sprite.play("walk_" + current_direction)
		await sprite.animation_finished
		#sprite.frame = 0
	#else:
		#if sprite.animation:
			#sprite.stop()
			#sprite.frame = 0
