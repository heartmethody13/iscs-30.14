extends Node2D

@export var unit_name: String = "Unit"
@export var team: String = "enemy"
@export var max_hp: int = 100
@export var hp: int = 100
@export var attacks = [
	{"name": "Shuriken Tempest", "damage": 17}
]

@onready var hp_bar: ProgressBar = $hpbar
@onready var pointer = $focus

func _ready():
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	pointer.visible = false

func take_damage(amount: int):
	hp -= amount
	if hp < 0:
		hp = 0
	hp_bar.value = hp

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
