extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#extends Node2D
#
#@export var unit_name: String = "Wizard"
#@export var max_hp: int = 100
#@export var hp: int = 100
#
#@onready var hp_bar: ProgressBar = $ProgressBar
#
#func _ready() -> void:
	#hp_bar.max_value = max_hp
	#hp_bar.value = hp
#
#func take_damage(amount: int) -> void:
	#hp -= amount
	#if hp < 0:
		#hp = 0
	#hp_bar.value = hp
