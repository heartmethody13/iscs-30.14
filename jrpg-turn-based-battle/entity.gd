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
@onready var shield: Sprite2D = $shield

var hasDefended: bool = false
var skip_next_turn: bool = false

func _ready():
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	pointer.visible = false
	shield.visible = false

func take_damage(amount: int):
	if hasDefended:
		amount = int(ceil(amount / 2.0))
	
	if hp != 0:
		hp -= amount
		if hp < 0:
			hp = 0
			play_anim("death")
			await sprite.animation_finished
		hp_bar.value = hp
	
	hasDefended = false
	hide_shield()

func show_pointer():
	pointer.visible = true

func hide_pointer():
	pointer.visible = false

func show_shield():
	shield.visible = true

func hide_shield():
	shield.visible = false
	
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
