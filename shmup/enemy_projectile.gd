extends Area2D
var speed = 650
@export var damage: int = 20
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	connect("body_entered", _on_body_entered)

func _process(delta: float) -> void:
	translate(Vector2.DOWN * speed * delta)

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		#print("YOU GOT HIT")
		#print(area.health)
		body.take_damage(damage)
		sprite.play("explode")
		
		await sprite.animation_finished
		#sprite.stop()
		queue_free()
		return
	#else:
	sprite.play("default")
