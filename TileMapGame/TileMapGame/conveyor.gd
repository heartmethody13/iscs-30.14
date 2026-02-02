extends TileMapLayer

@onready var player = $Player

const TILE_SIZE = 32
var player_cell_position = Vector2()
func ready():
	pass
	
func _process(delta: float) -> void:
	pass
	## get player's position
	#player_cell_position = floor(player.global_position / TILE_SIZE)
	#
	#var data :TileData = get_cell_tile_data(0, player_cell_position)
	#if data and data.get_custom_data("on_conveyor") == true:
		#
