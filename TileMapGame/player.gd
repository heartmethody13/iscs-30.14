extends CharacterBody2D


@onready var sprite = $AnimatedSprite2D
@onready var ray = $RayCast2D

const SPEED = 32.0
const TILE_SIZE = 32
const INPUTS = {"ui_left": Vector2.LEFT, "ui_right": Vector2.RIGHT, "ui_up": Vector2.UP, "ui_down": Vector2.DOWN}
const ANIMATION_SPEED = 4

var moving = false
var direction_last_facing = "down"
var last_move_dir: Vector2 = Vector2.ZERO

func _ready():
	position = position.snapped(Vector2.ONE * TILE_SIZE)
	position += Vector2.ONE * TILE_SIZE/2
	
func _input(event) -> void:
	if moving:
		return
	
	var forced = get_forced_direction()
	if forced != "":
		move(forced)
		return

	for direction in INPUTS.keys():
		#var action = INPUTS[direction]
		if event.is_action(direction):
			move(direction)

func move(direction) -> void:
	ray.target_position = INPUTS[direction] * TILE_SIZE
	ray.force_raycast_update()
	
	if ray.is_colliding() == false:
		#position += INPUTS[direction] * TILE_SIZE
		var speed_modifier = get_tile_speed()
		var move_duration = 1.0 / (ANIMATION_SPEED * speed_modifier)
		
		last_move_dir = INPUTS[direction]
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position + INPUTS[direction] * TILE_SIZE, move_duration).set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(self, "position", position + INPUTS[direction] * TILE_SIZE, 1.0 / ANIMATION_SPEED).set_ease(Tween.EASE_IN_OUT)
		
		moving = true
		$AnimationPlayer.play(direction)
		$AnimationPlayer.speed_scale = speed_modifier
		
		update_animations(INPUTS[direction].x, INPUTS[direction].y)
		
		await tween.finished
		moving = false
		update_animations(0, 0)
		
		var forced = get_forced_direction()
		if forced != "":
			move(forced)
			
		if is_on_ice() and last_move_dir != Vector2.ZERO:
			for key in INPUTS.keys():
				if INPUTS[key] == last_move_dir:
					move(key)
					return
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
	
	if is_on_ice():
		sprite.play("walk_" + direction_last_facing)
		sprite.stop()
		sprite.frame = 0
		return
		
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


func get_tile_speed() -> float:
	var layers = get_tree().get_nodes_in_group("tilemap")
	
	layers.reverse()
	
	for i in range(layers.size() - 1, -1, -1):
		var layer = layers[i]
		
		if layer is TileMapLayer:
			var local_pos = layer.to_local(global_position)
			var cell = layer.local_to_map(local_pos)
			var data = layer.get_cell_tile_data(cell)
			
			if data:
				var tile_speed = data.get_custom_data("tile_speed")
				
				print("Checking Layer: ", layer.name, " | Value: ", tile_speed)
				
				if tile_speed != null and tile_speed > 0:
					return tile_speed
				print(tile_speed)
	
	return 1.0


func get_forced_direction() -> String:
	var layers = get_tree().get_nodes_in_group("tilemap")
	layers.reverse()

	for layer in layers:
		if layer is TileMapLayer:
			var local_pos = layer.to_local(global_position)
			var cell = layer.local_to_map(local_pos)
			var data = layer.get_cell_tile_data(cell)

			if data:
				var forced = data.get_custom_data("forced_direction")
				if forced is String and forced != "" and forced != "none":
					return forced

	return ""


func is_on_ice() -> bool:
	var layers = get_tree().get_nodes_in_group("tilemap")
	layers.reverse()

	for layer in layers:
		if layer is TileMapLayer:
			var local_pos = layer.to_local(global_position)
			var cell = layer.local_to_map(local_pos)
			var data = layer.get_cell_tile_data(cell)

			if data:
				return data.get_custom_data("ice") == true

	return false
