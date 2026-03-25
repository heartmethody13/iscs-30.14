extends Control

@onready var command_menu = $commandmenu
@onready var attack_button = $commandmenu/commands/attack
@onready var skill_button = $commandmenu/commands/skill
@onready var defend_button = $commandmenu/commands/defend

@onready var attack_menu = $attackmenu
@onready var attack_option1 = $attackmenu/attackbox/attack_option1
@onready var attack_option2 = $attackmenu/attackbox/attack_option2

func _ready():
	hide_all()

func hide_all():
	command_menu.hide()
	attack_menu.hide()

func show_command_menu(actor):
	command_menu.show()
	attack_menu.hide()
	position_menus(actor)
	update_command_buttons(actor)

func show_attack_menu(actor):
	attack_menu.show()
	command_menu.hide()
	position_menus(actor)
	update_attack_buttons(actor)

func show_command_again(actor):
	command_menu.show()
	attack_menu.hide()
	position_menus(actor)
	update_command_buttons(actor)

func position_menus(actor):
	var base_pos = actor.global_position
	command_menu.position = Vector2(base_pos.x + 30, base_pos.y - 20)
	attack_menu.position = Vector2(base_pos.x + 110, base_pos.y - 20)

func update_command_buttons(actor):
	attack_button.show()
	defend_button.show()

	if actor.unit_name.to_lower() == "wizard":
		skill_button.show()
		skill_button.text = "Heal"
	else:
		skill_button.hide()

func update_attack_buttons(actor):
	var attacks = actor.attacks

	if attacks.size() > 0:
		attack_option1.text = attacks[0]["name"]
		attack_option1.show()
	else:
		attack_option1.hide()

	if attacks.size() > 1:
		attack_option2.text = attacks[1]["name"]
		attack_option2.show()
	else:
		attack_option2.hide()
