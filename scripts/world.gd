extends Node2D


const WIDTH: int = 2048
const HEIGHT: int = 2048


func _ready() -> void:
	var colony_x: int = int(randf() * WIDTH)
	var colony_y: int = int(randf() * HEIGHT)
	_create_ant_colony(colony_x, colony_y)

func _create_ant_colony(x: int, y: int) -> void:
	var ant_colony = load("res://scenes/AntColony.tscn").instantiate()
	position = Vector2(x, y)
	$AntColonyContainer.add_child(ant_colony)

func _process(delta: float) -> void:
	pass
