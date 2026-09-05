extends Node2D


const WIDTH: int = 2048
const HEIGHT: int = 2048
const NUM_COLONIES: int = 2

@onready var simulation_manager: Node2D = $SimulationManager


func _ready() -> void:
	simulation_manager.init(WIDTH, HEIGHT)

	for i in range(NUM_COLONIES):
		_create_ant_colony(i)

func _create_ant_colony(index: int) -> void:
	var ant_colony = preload("res://scenes/AntColony.tscn").instantiate()
	var entrance_pos = Vector2(randf() * WIDTH, randf() * HEIGHT)
	ant_colony.init(entrance_pos)
	$AntColonyContainer.add_child(ant_colony)
