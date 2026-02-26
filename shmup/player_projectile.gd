extends Area2D
var speed = 500
@export var damage: int = 25
@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("area_entered", _on_area_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(Vector2.UP * speed * delta)
	
#func _physics_process(delta: float) -> void:
	#if 


func _on_area_entered(area: Area2D) -> void:
	#pass # Replace with function body.
	# if the thing we hit IS the enemy root
	if area.is_in_group("enemy"):
		print("hit")
		area.take_damage(damage)
		sprite.play("explode")
		await sprite.animation_finished
		#sprite.stop()
		queue_free()
		return
	#else:
	sprite.play("default")
	sprite.frame = 0
