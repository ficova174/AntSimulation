class_name SimulationConfig
extends Resource


@export var world_size: Vector2i = Vector2i.ONE * 2048
@export var pheromones_size: Vector2i = Vector2i.ONE * 512


func world_to_phero_ratio() -> float:
	return float(pheromones_size.x) / float(world_size.x)
