extends CharacterBody2D

@export var speed: float = 350.0
@export var max_health: int = 100
@export var death_freeze_time: float = 0.35

var health: int
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = max_health
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	var dir := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	velocity = dir * speed
	move_and_slide()


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health -= amount
	print("Player hit! HP =", health)

	if health <= 0:
		_die()


func _die() -> void:
	is_dead = true
	print("Player died!")

	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process(false)

	if has_node("CollisionShape2D"):
		$CollisionShape2D.disabled = true
	if has_node("CollisionPolygon2D"):
		$CollisionPolygon2D.disabled = true

	process_mode = Node.PROCESS_MODE_ALWAYS
	sprite.process_mode = Node.PROCESS_MODE_ALWAYS

	if sprite.sprite_frames and sprite.sprite_frames.has_animation("explode"):
		sprite.play("explode")
	else:
		visible = false

	get_tree().paused = true

	await get_tree().create_timer(death_freeze_time, true).timeout
	_cleanup_everything_except_background()


@export var game_over_ui_scene: PackedScene
@export var background_node_name := "ParallaxBackground"

func _cleanup_everything_except_background() -> void:
	var root := get_tree().current_scene
	if root == null:
		return

	var bg := root.get_node_or_null(background_node_name)
	if bg:
		bg.process_mode = Node.PROCESS_MODE_ALWAYS

	for child in root.get_children():
		if child == bg:
			continue
		child.queue_free()

	if game_over_ui_scene:
		var ui = game_over_ui_scene.instantiate()
		root.add_child(ui)
		ui.process_mode = Node.PROCESS_MODE_ALWAYS
