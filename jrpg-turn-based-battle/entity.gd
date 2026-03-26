class_name Entity
extends Node2D

var skip_next_turn: bool = false

@export var unit_name: String = "Unit"
@export var team: String = "player"
@export var max_hp: int = 100
@export var hp: int = 100
@export var attacks: Array[Dictionary] = [
	{"name": "", "damage": 0, "animation": ""}
]

@export var sprite: AnimatedSprite2D
@export var hp_bar: ProgressBar
@export var pointer: Sprite2D

@onready var shield_icon: Sprite2D = $shield_icon

func _ready():
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	pointer.visible = false
	shield_icon.visible = false
	
#func take_damage(amount: int):
	#hp -= amount
	#if hp < 0:
		#hp = 0
	#hp_bar.value = hp

func show_pointer():
	pointer.visible = true

func hide_pointer():
	pointer.visible = false

func show_shield():
	shield_icon.visible = true

func hide_shield():
	shield_icon.visible = false
	
func is_alive() -> bool:
	return hp > 0

func heal(amount: int):
	hp += amount
	if hp > max_hp:
		hp = max_hp
	hp_bar.value = hp

func play_anim(animation: String) -> void:
	sprite.play(animation)
	pass

func take_damage(amount: int):
	if has_meta("defending") and get_meta("defending") == true:
		amount = int(amount / 2)

	hp -= amount
	if hp < 0:
		hp = 0
	hp_bar.value = hp
