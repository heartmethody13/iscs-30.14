class_name BattleUI
extends Control

@onready var command_menu = $commandmenu
@onready var attack_button = $commandmenu/commands/attack
@onready var skill_button = $commandmenu/commands/skill
@onready var defend_button = $commandmenu/commands/defend

@onready var attack_menu = $attackmenu
@onready var attack_box = $attackmenu/attackbox

@onready var action_box = $actionbox
@onready var action_label = $actionbox/actionlabel

@export var attack_option_scene: PackedScene

signal attack_pressed
signal skill_pressed
signal defend_pressed
signal attack_selected(index)

func _ready():
	hide_all()
	action_box.hide()

	attack_button.pressed.connect(func():
		emit_signal("attack_pressed")
	)

	skill_button.pressed.connect(func():
		emit_signal("skill_pressed")
	)

	defend_button.pressed.connect(func():
		emit_signal("defend_pressed")
	)

	hide_all()
	action_box.hide()

func hide_all():
	command_menu.hide()
	attack_menu.hide()

func show_command_menu(actor):
	command_menu.show()
	attack_menu.hide()
	position_menus()
	update_command_buttons(actor)

func show_attack_menu(actor):
	attack_menu.show()
	# command_menu.hide()
	position_menus()
	update_attack_buttons(actor)

func show_command_again(actor):
	command_menu.show()
	attack_menu.hide()
	position_menus()
	update_command_buttons(actor)

func position_menus():
	var action_pos = action_box.global_position
	var action_size = action_box.size
	
	command_menu.global_position = Vector2(
		action_pos.x + (action_size.x / 2) - (command_menu.size.x / 2),
		action_pos.y + action_size.y + 10
	)

	attack_menu.global_position = command_menu.global_position + Vector2(command_menu.size.x + 10, 0)

func update_command_buttons(actor):
	attack_button.show()
	defend_button.show()

	if actor.unit_name.to_lower() == "wizard":
		skill_button.show()
		skill_button.text = "Heal"
	else:
		skill_button.hide()

func update_attack_buttons(actor):
	clear_attack_buttons()

	var attacks = actor.attacks

	for i in attacks:
		var attack = i

		var button = attack_option_scene.instantiate()
		button.text = attack["name"]

		attack_box.add_child(button)

		button.pressed.connect(func():
			emit_signal("attack_selected", i)
		)


func clear_attack_buttons():
	for child in attack_box.get_children():
		child.queue_free()


func show_action_text(text: String):
	action_label.text = text
	action_box.show()

func hide_action_text():
	action_box.hide()
