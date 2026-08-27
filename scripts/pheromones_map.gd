extends Sprite2D


var radius: float = 30.0
var radius_delta: float = 1.0
var circle_color: Color = Color.BLUE
var filled: bool = false


func _input(event):
	if event.is_action_pressed("brush_size_up"):
		radius += radius_delta
	elif event.is_action_pressed("brush_size_down"):
		radius -= radius_delta

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(get_global_mouse_position(), radius, circle_color, filled)
