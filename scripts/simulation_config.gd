class_name SimulationConfig
extends Resource


@export var world_size: Vector2 = Vector2.ONE * 1024
@export var pheromones_size: Vector2 = Vector2.ONE * 64


func world_to_phero_ratio() -> float:
	return pheromones_size.x / world_size.x
