extends Node2D


@export var config: SimulationConfig
@export var NUM_COLONIES: int = 1

@onready var simulation_manager: Node2D = $SimulationManager
@onready var colony_container: Node2D = $AntColonyContainer
@onready var brush: Node2D = $Brush


func _ready() -> void:
	var colony_positions: Array[Vector2] = []

	for i in range(NUM_COLONIES):
		var pos: Vector2 = Vector2(randf() * config.world_size.x, randf() * config.world_size.y)
		colony_positions.append(pos)
		_create_ant_colony(pos)

	simulation_manager.init(config.pheromones_size, colony_positions)

	brush.brush_radius_changed.connect(_on_brush_radius_changed)
	# to initialize PheromonesManager
	simulation_manager.set_brush_radius(brush.radius)

func _create_ant_colony(pos: Vector2) -> void:
	var ant_colony = preload("res://scenes/AntColony.tscn").instantiate()
	ant_colony.init(pos)
	colony_container.add_child(ant_colony)

func _on_brush_radius_changed(new_radius: float) -> void:
	simulation_manager.set_brush_radius(new_radius)
