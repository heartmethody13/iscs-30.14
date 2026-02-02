extends Area2D
@onready var target_destination := $destination

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		if target_destination:
			body.global_position = target_destination.global_position

			print("Teleported to: ", target_destination.name)
		else:
			print("Warning: No destination set for this teleporter!")
