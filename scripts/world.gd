extends Node2D


const WIDTH: int = 2048
const HEIGHT: int = 2048
const NUM_COLONIES: int = 2

@onready var simulation_manager: Node2D = $SimulationManager
@onready var colony_container: Node2D = $AntColonyContainer


func _ready() -> void:
	var colony_positions: Array[Vector2] = []

	for i in range(NUM_COLONIES):
		var pos: Vector2 = Vector2(randf() * WIDTH, randf() * HEIGHT)
		colony_positions.append(pos)
		_create_ant_colony(pos)

	simulation_manager.init(WIDTH, HEIGHT, colony_positions)

func _create_ant_colony(pos: Vector2) -> void:
	var ant_colony = preload("res://scenes/AntColony.tscn").instantiate()
	ant_colony.init(pos)
	colony_container.add_child(ant_colony)
