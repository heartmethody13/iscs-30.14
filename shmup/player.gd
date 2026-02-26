extends CharacterBody2D
#@onready var sprite = $Sprite2D
@export var speed = 650
const PROJECTILE = preload("res://player_projectile.tscn")
@onready var muzzle = $Muzzle
@onready var sprite = $AnimatedSprite2D
@export var health: int = 100
@export var damage: int = 50

var is_dead := false

#func _ready() -> void:
	#connect("area_entered", _on_area_entered)
#func _process(delta):
	#if !is_alive:
		#return

func _physics_process(delta: float) -> void:
	var move = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if move:
		velocity = move * speed
	else:
		velocity = Vector2.ZERO

	#print(position.x, position.y)
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):		
		var new_projectile = PROJECTILE.instantiate()
		new_projectile.global_position = muzzle.global_position
		add_sibling(new_projectile)
		
func take_damage(amount):
	health -= amount
	print("YOU GOT HIT")
	print(health)
	if health <= 0:
		print("YOU DIED")
		sprite.play("explode")
		#sprite.stop()
		await sprite.animation_finished
		queue_free()		
		return
		#die()
	sprite.play("default")


#func die():
	#is_dead = true
	#collision_layer = 0
	#collision_mask = 0
	#velocity = Vector2.ZERO
#
	#sprite.play("explode")
	#await sprite.animation_finished
	#
	#set_physics_process(false)
	#$CollisionPolygon2D.disabled = true
#
	#queue_free()
