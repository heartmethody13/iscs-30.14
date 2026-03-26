extends Node2D

const DAMAGE_ROLL_MIN := 0.85
const DAMAGE_ROLL_MAX := 1.15
const CRIT_CHANCE := 0.15
const CRIT_MULTIPLIER := 1.5

@export var battle_ui: BattleUI
@export var entities: Array[Entity]
@export var attack_container: VBoxContainer

var player_team: Array[Entity] = []
var enemy_team: Array[Entity] = []

var current_turn_index: int = 0
var current_entity: Entity = null

var selecting_target: bool = false
var selected_target_index: int = 0
var pending_attack: Dictionary = {}

enum Target{PLAYER, ENEMY}

var target_type: Target
var player_action_queue: Array[Dictionary] = []
var player_selection_index: int = 0
var choosing_player_actions: bool = true


func _ready():
	randomize()
	setup_teams()

	battle_ui.attack_pressed.connect(_on_attack_pressed)
	battle_ui.attack_selected.connect(_on_attack_selected)
	battle_ui.skill_pressed.connect(_on_skill_pressed)
	battle_ui.defend_pressed.connect(_on_defend_pressed)

	start_battle()


func _on_defend_pressed():
	player_action_queue.append({
		"actor": current_entity,
		"type": "defend"
	})

	battle_ui.hide_all()
	advance_player_selection()
	#current_entity.hasDefended = true
	#current_entity.show_shield()
	#battle_ui.show_action_text("%s defends" % current_entity.unit_name)
#
	#await get_tree().create_timer(0.8).timeout
#
	#battle_ui.hide_all()
	#battle_ui.hide_action_text()
	#end_turn()


func _on_attack_pressed():
	battle_ui.show_action_text("Choosing %s's action" % current_entity.unit_name)
	battle_ui.show_attack_menu(current_entity)


func _on_attack_selected(attack: Dictionary):
	pending_attack = attack
	#battle_ui.hide_all()

	var targets = get_alive_enemies()
	if targets.is_empty():
		return

	start_target_selection(Target.ENEMY)


func start_target_selection(type: Target):
	selecting_target = true
	target_type = type
	selected_target_index = 0

	battle_ui.hide_all()

	update_target_pointer()


func _on_skill_pressed():
	if current_entity.unit_name.to_lower() == "wizard":
		pending_attack = {"name": "Heal", "heal": 50, "animation": "heal"}
		start_target_selection(Target.PLAYER)
	#pass


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
	start_player_phase()
	#current_turn_index = 0
	#next_turn()

# -------------------------
# PLAYER PHASE / ENEMY PHASE
# -------------------------
func start_player_phase():
	player_action_queue.clear()
	player_selection_index = 0
	choosing_player_actions = true
	selecting_target = false
	set_process_input(true)
	choose_next_player_action()


func choose_next_player_action():
	var alive_players = get_alive_players()

	if alive_players.is_empty():
		check_battle_end()
		return

	if player_selection_index >= alive_players.size():
		choosing_player_actions = false
		await execute_player_phase()
		if check_battle_end():
			return
		await execute_enemy_phase()
		if check_battle_end():
			return
		clear_all_defends()
		start_player_phase()
		return

	current_entity = alive_players[player_selection_index]

	# skip turn if marked
	if current_entity.skip_next_turn:
		current_entity.skip_next_turn = false
		battle_ui.show_action_text("%s skips this turn" % current_entity.unit_name)
		await get_tree().create_timer(0.8).timeout
		battle_ui.hide_action_text()

		player_selection_index += 1
		choose_next_player_action()
		return

	player_turn()


func advance_player_selection():
	player_selection_index += 1
	choose_next_player_action()
	
	
# -------------------------
# Turn System
# -------------------------
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
	# update_target_pointer()
	battle_ui.show_action_text("Choosing %s's action" % current_entity.unit_name)
	battle_ui.show_command_menu(current_entity)

	print("Player turn: choose target")
	set_process_input(true)


func _input(event):
	if selecting_target:
		if event.is_action_pressed("ui_right"):
			selected_target_index -= 1
			selected_target_index %= get_current_targets().size()
			update_target_pointer()

		elif event.is_action_pressed("ui_left"):
			selected_target_index += 1
			selected_target_index %= get_current_targets().size()
			update_target_pointer()

		elif event.is_action_pressed("ui_accept"):
			confirm_target()

		elif event.is_action_pressed("ui_cancel"):
			selecting_target = false
			for e in entities:
				e.hide_pointer()
			battle_ui.show_action_text("Choosing %s's action" % current_entity.unit_name)
			battle_ui.show_command_again(current_entity)
		return


func update_target_pointer():
	var targets = get_current_targets()

	if targets.is_empty():
		return

	# selected_target_index = clamp(selected_target_index, 0, targets.size() - 1)

	for e in entities:
		e.hide_pointer()

	targets[selected_target_index].show_pointer()
	print(targets[selected_target_index])


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
func execute_enemy_phase():
	var alive_enemies = get_alive_enemies()

	for enemy in alive_enemies:
		if not enemy.is_alive():
			continue

		await get_tree().create_timer(0.5).timeout

		var targets = get_alive_players()
		if targets.is_empty():
			return

		var target = targets.pick_random()
		var attack = enemy.attacks.pick_random()
		var damage_result = roll_damage(attack["damage"])
		var damage = damage_result["damage"]
		var is_crit = damage_result["is_crit"]
		
		if is_crit:
			battle_ui.show_action_text(
				"%s uses %s on %s\nCritical Hit! %d damage" %
				[enemy.unit_name, attack["name"], target.unit_name, damage]
			)
		else:
			battle_ui.show_action_text(
				"%s uses %s on %s\n%d damage" %
				[enemy.unit_name, attack["name"], target.unit_name, damage]
			)

		enemy.play_anim(attack["animation"])
		await enemy.sprite.animation_finished

		await target.take_damage(damage)

		enemy.play_anim("idle")
		await get_tree().create_timer(0.5).timeout

		if check_battle_end():
			return
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
#
	#show_action_box(current_entity, attack["name"], target)
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
func show_action_box(attacker: Entity, attack: String, recipient: Entity) -> void:
	battle_ui.show_action_text(
		'%s uses %s on %s' % [attacker.unit_name, attack, recipient.unit_name]
	)


func get_alive_players() -> Array:
	return player_team.filter(func(e): return e.is_alive())


func get_alive_enemies() -> Array:
	# print(enemy_team)
	return enemy_team.filter(func(e): return e.is_alive())

func roll_damage(base_damage: int) -> Dictionary:
	var roll = randf_range(DAMAGE_ROLL_MIN, DAMAGE_ROLL_MAX)
	var damage = int(round(base_damage * roll))

	var is_crit = randf() < CRIT_CHANCE
	if is_crit:
		damage = int(round(damage * CRIT_MULTIPLIER))

	return {
		"damage": max(damage, 1),
		"is_crit": is_crit
	}

func clear_all_defends():
	for e in entities:
		e.hasDefended = false
		e.hide_shield()

# -------------------------
# End Turn / Win Check
# -------------------------
func end_turn():
	battle_ui.hide_action_text()
	clear_attack_options()
	set_process_input(false)

	#if check_battle_end():
		#return
#
	#current_turn_index += 1
	#next_turn()


func check_battle_end() -> bool:
	var players_alive = get_alive_players()
	var enemies_alive = get_alive_enemies()

	if players_alive.is_empty():
		battle_ui.hide_all()
		battle_ui.show_action_text("Defeat...")
		set_process_input(false)
		return true

	if enemies_alive.is_empty():
		battle_ui.hide_all()
		battle_ui.show_action_text("Victory!")
		set_process_input(false)
		return true

	return false

func clear_attack_options():
	for child in attack_container.get_children():
		child.queue_free()


func get_current_targets() -> Array:
	if target_type == Target.ENEMY:
		return get_alive_enemies()
	else:
		return get_alive_players()


func confirm_target():
	var targets = get_current_targets()

	if targets.is_empty():
		return

	var target = targets[selected_target_index]
	var actor = current_entity

	#selecting_target = false

	# Hide pointers
	for e in entities:
		e.hide_pointer()
		
	# queueing action instead of executing act immediately
	var queued_action = pending_attack.duplicate(true)
	queued_action["actor"] = actor
	queued_action["target"] = target

	player_action_queue.append(queued_action)
	pending_attack = {}

	battle_ui.hide_all()
	advance_player_selection()
		
	#execute_action(target)


# -------------------------
# Player Action Execution (After all actions chosen)
# -------------------------
func execute_player_phase():
	for action in player_action_queue:
		var actor: Entity = action["actor"]

		if not actor.is_alive():
			continue

		if action.get("type", "") == "defend":
			actor.hasDefended = true
			actor.show_shield()
			battle_ui.show_action_text("%s defends" % actor.unit_name)
			await get_tree().create_timer(0.8).timeout
			battle_ui.hide_action_text()

		elif action.has("damage"):
			var target: Entity = action["target"]
			if target == null or not target.is_alive():
				var enemies = get_alive_enemies()
				if enemies.is_empty():
					return
				target = enemies[0]

			var damage_result = roll_damage(action["damage"])
			var final_damage = damage_result["damage"]
			var is_crit = damage_result["is_crit"]

			if is_crit:
				battle_ui.show_action_text(
					"%s uses %s on %s\nCritical Hit! %d damage" %
					[actor.unit_name, action["name"], target.unit_name, final_damage]
				)
			else:
				battle_ui.show_action_text(
					"%s uses %s on %s\n%d damage" %
					[actor.unit_name, action["name"], target.unit_name, final_damage]
				)

			actor.play_anim(action["animation"])
			await actor.sprite.animation_finished

			await target.take_damage(final_damage)

			actor.play_anim("idle")
			await get_tree().create_timer(1.0).timeout
			battle_ui.hide_action_text()
	
		elif action.has("heal"):
			var target: Entity = action["target"]
			if target == null or not target.is_alive():
				var allies = get_alive_players()
				if allies.is_empty():
					return
				target = allies[0]

			battle_ui.show_action_text(
				"%s uses Heal on %s\n%s will skip next turn" %
				[actor.unit_name, target.unit_name, actor.unit_name]
			)

			actor.play_anim(action["animation"])
			await actor.sprite.animation_finished

			target.heal(action["heal"])
			actor.skip_next_turn = true

			actor.play_anim("idle")
			await get_tree().create_timer(1.0).timeout
			battle_ui.hide_action_text()

		if check_battle_end():
			return

#func execute_action(target: Entity):
	#battle_ui.hide_all()
	#
	## ATTACK
	#if pending_attack.has("damage"):
		#var damage = pending_attack["damage"]
		#
		#show_action_box(current_entity, pending_attack["name"], target)
		#
		#print(pending_attack)
		#
		#current_entity.play_anim(pending_attack["animation"])
		#await current_entity.sprite.animation_finished
		#
		#target.take_damage(damage)
		#
	## HEAL
	#elif pending_attack.has("heal"):
		#battle_ui.show_action_text(
			#"%s uses Heal on %s\n%s will skip next turn" %
			#[current_entity.unit_name, target.unit_name, current_entity.unit_name]
		#)
		#
		#current_entity.play_anim(pending_attack["animation"])
		#await current_entity.sprite.animation_finished
#
		#target.heal(pending_attack["heal"])
		#current_entity.skip_next_turn = true
		#
	#current_entity.play_anim("idle")
	#
	#await get_tree().create_timer(1.0).timeout
	#
	#battle_ui.hide_action_text()
	#
	#pending_attack = {}
	#
	#end_turn()
