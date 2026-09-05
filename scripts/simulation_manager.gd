extends Node2D


@onready var pheromones_manager: Node2D = $PheromonesManager
@onready var ants_manager: Node2D = $AntsManager
var shader_set: int = 0
var step_toggle: bool = false


func init(width: int, height: int) -> void:
	var rd: RenderingDevice = RenderingServer.get_rendering_device()
	pheromones_manager.init(rd, shader_set, width, height)
	ants_manager.init(rd, shader_set, pheromones_manager.pheromones_tex_a, pheromones_manager.pheromones_tex_b)

func _physics_process(delta: float) -> void:
	ants_manager.compute_ants(delta, step_toggle)
	pheromones_manager.compute_pheromones(delta, step_toggle)

	step_toggle = not step_toggle

func _process(_delta: float) -> void:
	ants_manager.update_visuals()
	pheromones_manager.update_display(step_toggle)
