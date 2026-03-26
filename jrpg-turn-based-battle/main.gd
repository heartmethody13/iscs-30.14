extends Node2D

@export var battle_ui: BattleUI
@export var entities: Array[Entity]
@export var attack_container: VBoxContainer

var player_team: Array[Entity] = []
var enemy_team: Array[Entity] = []

var current_turn_index: int = 0
var current_entity: Entity = null

var selected_target_index: int = 0

func _ready():
	setup_teams()

	battle_ui.attack_pressed.connect(_on_attack_pressed)
	battle_ui.attack_selected.connect(_on_attack_selected)

	start_battle()


func _on_attack_pressed():
	battle_ui.show_attack_menu(current_entity)


func _on_attack_selected(attack: Dictionary):
	battle_ui.hide_all()

	var targets = get_alive_enemies()
	if targets.is_empty():
		return

	var target = targets[selected_target_index]
	var damage = attack["damage"]

	battle_ui.show_action_text(
		current_entity.unit_name + " uses " + attack["name"]
	)

	current_entity.play_anim(attack["animation"])
	await current_entity.sprite.animation_finished
	target.take_damage(damage)
	current_entity.play_anim("idle")

	await get_tree().create_timer(1.0).timeout

	battle_ui.hide_action_text()

	end_turn()


# -------------------------
# Setup
# -------------------------
func setup_teams():
	for e in entities:
		if e.team == "player":
			player_team.append(e)
		else:
			enemy_team.append(e)


func start_battle():
	current_turn_index = 0
	next_turn()


# -------------------------
# Turn System
# -------------------------
func next_turn():
	var alive_entities = get_alive_entities()

	if alive_entities.is_empty():
		return

	current_entity = alive_entities[current_turn_index % alive_entities.size()]

	if not current_entity.is_alive():
		current_turn_index += 1
		next_turn()
		return

	print("Turn: ", current_entity.unit_name)

	if current_entity.team == "player":
		player_turn()
	else:
		enemy_turn()


func get_alive_entities() -> Array:
	var alive: Array = []
	for e in entities:
		if e.is_alive():
			alive.append(e)
	return alive


# -------------------------
# Player Turn
# -------------------------
func player_turn():
	selected_target_index = 0
	update_target_pointer()

	battle_ui.show_command_menu(current_entity)

	print("Player turn: choose target")
	set_process_input(true)


func _input(event):
	if current_entity == null:
		return

	if current_entity.team != "player":
		return

	if event.is_action_pressed("ui_right"):
		selected_target_index += 1
		update_target_pointer()

	elif event.is_action_pressed("ui_left"):
		selected_target_index -= 1
		update_target_pointer()

	elif event.is_action_pressed("ui_accept"):
		perform_player_attack()


func update_target_pointer():
	var targets = get_alive_enemies()

	if targets.is_empty():
		return

	selected_target_index = clamp(selected_target_index, 0, targets.size() - 1)

	for e in enemy_team:
		e.hide_pointer()

	targets[selected_target_index].show_pointer()


func perform_player_attack():
	var targets = get_alive_enemies()
	if targets.is_empty():
		return

	var target = targets[selected_target_index]

	var attack = current_entity.attacks[0] # simple: first attack
	var damage = attack["damage"]

	print(current_entity.unit_name, " attacks ", target.unit_name)

	current_entity.play_anim("attack")
	target.take_damage(damage)

	end_turn()


# -------------------------
# Enemy Turn (simple AI)
# -------------------------
func enemy_turn():
	await get_tree().create_timer(0.5).timeout

	var targets = get_alive_players()
	if targets.is_empty():
		return

	var target = targets.pick_random()

	var attack = current_entity.attacks[0]
	var damage = attack["damage"]

	battle_ui.show_action_text(
		current_entity.unit_name + " uses " + attack["name"]
	)

	current_entity.play_anim("attack")
	await current_entity.sprite.animation_finished
	target.take_damage(damage)
	current_entity.play_anim("idle")

	await get_tree().create_timer(0.5).timeout

	end_turn()


# -------------------------
# Helpers
# -------------------------
func get_alive_players() -> Array:
	return player_team.filter(func(e): return e.is_alive())


func get_alive_enemies() -> Array:
	print(enemy_team)
	return enemy_team.filter(func(e): return e.is_alive())


# -------------------------
# End Turn / Win Check
# -------------------------
func end_turn():
	battle_ui.hide_action_text()
	clear_attack_options()
	set_process_input(false)

	if check_battle_end():
		return

	current_turn_index += 1
	next_turn()


func check_battle_end() -> bool:
	var players_alive = get_alive_players()
	var enemies_alive = get_alive_enemies()

	if players_alive.is_empty():
		print("Defeat...")
		return true

	if enemies_alive.is_empty():
		print("Victory!")
		return true

	return false

func clear_attack_options():
	for child in attack_container.get_children():
		child.queue_free()
