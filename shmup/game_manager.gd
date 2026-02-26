# game_manager.gd
extends Node

@export var background_path: NodePath = ^"ParallaxBackground"
var game_over := false

func trigger_game_over_cleanup() -> void:
	if game_over:
		return
	game_over = true

	var root := get_tree().current_scene
	var bg := root.get_node_or_null(background_path)

	# Keep background alive even while paused
	if bg:
		bg.process_mode = Node.PROCESS_MODE_ALWAYS

	# Remove everything except the background and this manager
	call_deferred("_cleanup_except", bg)

func _cleanup_except(bg: Node) -> void:
	var root := get_tree().current_scene
	for child in root.get_children():
		if child == bg:
			continue
		if child == self:
			continue
		child.queue_free()
