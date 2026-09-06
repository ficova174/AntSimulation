extends Node2D


@export var config: SimulationConfig

signal brush_radius_changed(new_radius: float)

@export var radius: float = 30.0
@export var radius_delta: float = 1.0
@export var circle_color: Color = Color.BLUE
@export var filled: bool = false
var allow_echo: bool = false
var exact_match: bool = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("brush_size_up", allow_echo, exact_match):
		radius += radius_delta
		brush_radius_changed.emit(radius)
	elif event.is_action_pressed("brush_size_down", allow_echo, exact_match) and radius > radius_delta:
		radius -= radius_delta
		brush_radius_changed.emit(radius)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(get_local_mouse_position(), radius, circle_color, filled)
