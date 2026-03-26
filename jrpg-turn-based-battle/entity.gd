class_name Entity
extends Node2D

@export var unit_name: String = "Unit"
@export var team: String = "player"
@export var max_hp: int = 100
@export var hp: int = 100
@export var attacks: Array[Dictionary] = [
	{"name": "", "damage": 0, "animation": ""}
]

@onready var sprite: AnimatedSprite2D = $sprite
@onready var hp_bar: ProgressBar = $hpbar
@onready var pointer: Sprite2D = $focus

var hasDefended: bool

func _ready():
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	pointer.visible = false

func take_damage(amount: int):
	if not hasDefended and hp != 0:
		hp -= amount
		if hp < 0:
			hp = 0
			play_anim("death")
			await sprite.animation_finished
		hp_bar.value = hp
	hasDefended = false

func show_pointer():
	pointer.visible = true

func hide_pointer():
	pointer.visible = false

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
