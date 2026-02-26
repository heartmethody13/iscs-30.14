extends Node2D
#
## This points to the file you saved in Step 1
#var enemy_template = preload("res://asteroid.tscn")
#
#func _on_timer_timeout():
	## 1. Create a "copy" of the enemy template
	#var new_enemy = enemy_template.instantiate()
	#
	#var random_x = randf_range(-257, 265)
	#var fixed_y = -241
	## 2. Pick ithin screen width (e.g., 0 to 1152)
	#new_enemy.position = Vector2(random_x, fixed_y)
	#
	## 3. Add it to the world
	#add_child(new_enemy)




@export var asteroid_scene: PackedScene
@export var spawn_interval: float = 4
@export var min_x: float = -257.0
@export var max_x: float = 265.0
@export var spawn_y: float = -521.0

@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	randomize()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_spawn_asteroid)
	spawn_timer.start()

func _spawn_asteroid() -> void:
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = Vector2(randf_range(min_x, max_x), spawn_y)
	get_tree().current_scene.add_child(asteroid)
