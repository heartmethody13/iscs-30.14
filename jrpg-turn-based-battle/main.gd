extends Node2D

enum BattleState {
	COMMAND,
	ATTACK_MENU,
	TARGET_ENEMY,
	TARGET_ALLY,
	BUSY	
}

var battle_state: int = BattleState.COMMAND
var pending_action: Dictionary = {}
var selected_target_index: int = 0

@export var battle_ui: BattleUI
@export var entities: Array[Entity]
@export var attack_container: VBoxContainer

var player_team: Array[Entity] = []
var enemy_team: Array[Entity] = []

var current_turn_index: int = 0
var current_entity: Entity = null
#var selected_target_index: int = 0

func _ready():
	setup_teams()

	battle_ui.attack_pressed.connect(_on_attack_pressed)
	battle_ui.attack_selected.connect(_on_attack_selected)
	battle_ui.skill_pressed.connect(_on_skill_pressed)
	battle_ui.defend_pressed.connect(_on_defend_pressed)
	start_battle()


func _on_attack_pressed():
	if current_entity == null:
		return
	battle_state = BattleState.ATTACK_MENU	
	battle_ui.show_attack_menu(current_entity)


func _on_attack_selected(attack: Dictionary):
	pending_action = attack
	selected_target_index = 0
	battle_state = BattleState.TARGET_ENEMY
	battle_ui.hide_all()
	update_target_pointer()
	battle_ui.show_action_text("Choose an enemy targeet")
	#battle_ui.hide_all()
#
	#var targets = get_alive_enemies()
	#if targets.is_empty():
		#return
#
	#var target = targets[selected_target_index]
	#var damage = attack["damage"]
#
	#battle_ui.show_action_text(
		#current_entity.unit_name + " uses " + attack["name"]
	#)
#
	#current_entity.play_anim(attack["animation"])
	#await current_entity.sprite.animation_finished
	#target.take_damage(damage)
	#current_entity.play_anim("idle")
#
	#await get_tree().create_timer(1.0).timeout
#
	#battle_ui.hide_action_text()
#
	#end_turn()


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

	# skip turn if needed
	if current_entity.skip_next_turn:
		current_entity.skip_next_turn = false
		battle_ui.show_action_text(current_entity.unit_name + " skips this turn")
		await get_tree().create_timer(0.8).timeout
		battle_ui.hide_action_text()

		current_turn_index += 1
		next_turn()
		return

	current_entity.set_meta("defending", false)
	current_entity.hide_shield()
	
	if current_entity.team == "player":
		player_turn()
	else:
		enemy_turn()
#func next_turn():
	#var alive_entities = get_alive_entities()
#
	#if alive_entities.is_empty():
		#return
#
	#current_entity = alive_entities[current_turn_index % alive_entities.size()]
#
	#if not current_entity.is_alive():
		#current_turn_index += 1
		#next_turn()
		#return
#
	#print("Turn: ", current_entity.unit_name)
#
	#if current_entity.team == "player":
		#player_turn()
	#else:
		#enemy_turn()


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
	pending_action = {}
	
	battle_state = BattleState.COMMAND
	clear_all_pointers()
	battle_ui.show_command_menu(current_entity)
	#print("Player turn: choose target")
	set_process_input(true)


func _input(event):
	if current_entity == null:
		return
	if current_entity.team != "player":
		return

	if battle_state == BattleState.TARGET_ENEMY:
		var targets = get_alive_enemies()

		if event.is_action_pressed("ui_right"):
			selected_target_index += 1
			update_target_pointer()
		elif event.is_action_pressed("ui_left"):
			selected_target_index -= 1
			update_target_pointer()
		elif event.is_action_pressed("ui_accept"):
			perform_pending_attack()
		elif event.is_action_pressed("ui_cancel"):
			battle_state = BattleState.COMMAND
			clear_all_pointers()
			battle_ui.hide_action_text()
			battle_ui.show_command_menu(current_entity)

	elif battle_state == BattleState.TARGET_ALLY:
		var targets = get_alive_players()

		if event.is_action_pressed("ui_right"):
			selected_target_index += 1
			update_target_pointer()
		elif event.is_action_pressed("ui_left"):
			selected_target_index -= 1
			update_target_pointer()
		elif event.is_action_pressed("ui_accept"):
			perform_pending_heal()
		elif event.is_action_pressed("ui_cancel"):
			battle_state = BattleState.COMMAND
			clear_all_pointers()
			battle_ui.hide_action_text()
			battle_ui.show_command_menu(current_entity)
	
#func _input(event):
	#if current_entity == null:
		#return
#
	#if current_entity.team != "player":
		#return
#
	#if event.is_action_pressed("ui_right"):
		#selected_target_index += 1
		#update_target_pointer()
#
	#elif event.is_action_pressed("ui_left"):
		#selected_target_index -= 1
		#update_target_pointer()
#
	#elif event.is_action_pressed("ui_accept"):
		#perform_player_attack()

func update_target_pointer():
	var targets: Array = []

	clear_all_pointers()

	if battle_state == BattleState.TARGET_ENEMY:
		targets = get_alive_enemies()
	elif battle_state == BattleState.TARGET_ALLY:
		targets = get_alive_players()

	if targets.is_empty():
		return

	selected_target_index = clamp(selected_target_index, 0, targets.size() - 1)
	targets[selected_target_index].show_pointer()

	
#func update_target_pointer():
	#var targets = get_alive_enemies()
#
	#if targets.is_empty():
		#return
#
	#selected_target_index = clamp(selected_target_index, 0, targets.size() - 1)
#
	#for e in enemy_team:
		#e.hide_pointer()
#
	#targets[selected_target_index].show_pointer()


func perform_pending_attack():
	var targets = get_alive_enemies()
	if targets.is_empty():
		return
	if pending_action.is_empty():
		return

	battle_state = BattleState.BUSY
	var target = targets[selected_target_index]
	var damage = pending_action["damage"]

	clear_all_pointers()
	battle_ui.show_action_text(
		current_entity.unit_name + " uses " + pending_action["name"] + " on " + target.unit_name
	)

	current_entity.play_anim(pending_action["animation"])
	await current_entity.sprite.animation_finished

	target.take_damage(damage)

	current_entity.play_anim("idle")
	await get_tree().create_timer(1.0).timeout

	battle_ui.hide_action_text()
	end_turn()
#func perform_player_attack():
	#var targets = get_alive_enemies()
	#if targets.is_empty():
		#return
#
	#var target = targets[selected_target_index]
#
	#var attack = current_entity.attacks[0] # simple: first attack
	#var damage = attack["damage"]
#
	#print(current_entity.unit_name, " attacks ", target.unit_name)
#
	#current_entity.play_anim("attack")
	#target.take_damage(damage)
#
	#end_turn()


# -------------------------
# Enemy Turn (simple AI)
# -------------------------
func enemy_turn():
	battle_state = BattleState.BUSY
	await get_tree().create_timer(0.5).timeout

	var targets = get_alive_players()
	if targets.is_empty():
		return

	var target = targets.pick_random()
	var attack = current_entity.attacks[0]
	var damage = attack["damage"]

	battle_ui.show_action_text(
		current_entity.unit_name + " uses " + attack["name"] + " on " + target.unit_name
	)

	current_entity.play_anim(attack["animation"])
	await current_entity.sprite.animation_finished

	target.take_damage(damage)

	current_entity.play_anim("idle")
	await get_tree().create_timer(0.8).timeout

	battle_ui.hide_action_text()
	end_turn()
#func enemy_turn():
	#await get_tree().create_timer(0.5).timeout
#
	#var targets = get_alive_players()
	#if targets.is_empty():
		#return
#
	#var target = targets.pick_random()
#
	#var attack = current_entity.attacks[0]
	#var damage = attack["damage"]
#
	#battle_ui.show_action_text(
		#current_entity.unit_name + " uses " + attack["name"]
	#)
#
	#current_entity.play_anim("attack")
	#await current_entity.sprite.animation_finished
	#target.take_damage(damage)
	#current_entity.play_anim("idle")
#
	#await get_tree().create_timer(0.5).timeout
#
	#end_turn()


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

func clear_all_pointers():
	for e in entities:
		e.hide_pointer()

func _on_skill_pressed():
	if current_entity == null:
		return

	if current_entity.unit_name.to_lower() == "wizard":
		pending_action = {
			"name": "Heal",
			"amount": 25,
			"type": "heal"
		}
		selected_target_index = 0
		battle_state = BattleState.TARGET_ALLY
		battle_ui.hide_all()
		update_target_pointer()
		battle_ui.show_action_text("Choose an ally to heal")
		
func _on_defend_pressed():
	if current_entity == null:
		return

	battle_state = BattleState.BUSY
	battle_ui.hide_all()
	battle_ui.show_action_text(current_entity.unit_name + " defends")
	current_entity.set_meta("defending", true)
	current_entity.show_shield()

	await get_tree().create_timer(0.8).timeout
	battle_ui.hide_action_text()
	end_turn()
#func _on_defend_pressed():
	#if current_entity == null:
		#return
#
	#battle_state = BattleState.BUSY
	#battle_ui.hide_all()
	#battle_ui.show_action_text(current_entity.unit_name + " defends")
	#current_entity.set_meta("defending", true)
	#await get_tree().create_timer(0.8).timeout
	#battle_ui.hide_action_text()
	#end_turn()

func perform_pending_heal():
	var targets = get_alive_players()
	if targets.is_empty():
		return
	if pending_action.is_empty():
		return

	battle_state = BattleState.BUSY
	var target = targets[selected_target_index]
	var amount = pending_action["amount"]

	clear_all_pointers()

	battle_ui.show_action_text(
		current_entity.unit_name + " uses Heal on " + target.unit_name
	)

	# play wizard heal animation
	current_entity.play_anim("heal")
	await current_entity.sprite.animation_finished

	target.heal(amount)

	# show extra text that wizard will skip next turn
	battle_ui.show_action_text(
		current_entity.unit_name + " uses Heal on " + target.unit_name + "\n" +
		current_entity.unit_name + " will skip next turn"
	)

	current_entity.skip_next_turn = true

	await get_tree().create_timer(1.0).timeout

	current_entity.play_anim("idle")
	battle_ui.hide_action_text()
	end_turn()
