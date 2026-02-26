extends Area2D
const PROJECTILE = preload("res://enemy_projectile.tscn")
var speed = 200
@onready var muzzle = $Muzzle2
@onready var sprite = $AnimatedSprite2D
@export var health: int = 75
@export var damage: int = 35
@export var fire_rate: float = 0.9
var fire_timer : float = 0.0

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", _on_body_entered)
	randomize()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	translate(Vector2.DOWN * speed * delta)
	fire_timer -= delta
	if fire_timer <= 0:
		shoot()
		fire_timer = fire_rate

func shoot():
	var new_projectile = PROJECTILE.instantiate()	
	new_projectile.global_position = muzzle.global_position
	add_sibling(new_projectile)

func take_damage(amount):
	health -= amount
	print("HIT ENEMY")
	print(health)
	if health <= 0:
		print("ENEMY DEAD")
		sprite.play("explode")
		#sprite.stop()
		await sprite.animation_finished
		queue_free()
		return
	#sprite.stop()
	sprite.play("default")
	#else:
		#sprite.play("default")

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("player")):
		body.take_damage(damage)
		take_damage(body.damage)
		print("COLLISION")
