extends CharacterBody2D
#@onready var sprite = $Sprite2D
@export var speed = 650
# Called when the node enters the scene tree for the first time.

func _physics_process(delta: float) -> void:
	var move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if move:
		velocity = move * speed
	else:
		velocity = Vector2.ZERO
	#velocity = move * speed
	print(position.x, position.y)
	move_and_slide()
	
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

	
#func _input(event: InputEvent) -> void:
	##look_at(get_global_mouse_position())
	##var move_x = Input.get_axis("down", "up")
	##var move_y = Input.get_axis("left", "right")
	##velocity.x = move_x * speed
	##velocity.y = move_y * speed
	##move_and_slide()
