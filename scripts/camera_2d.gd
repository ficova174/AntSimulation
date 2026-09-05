extends Camera2D


@export var move_speed: float = 500.0
@export var zoom_speed: float = 0.1
@export var MIN_ZOOM: Vector2 = Vector2.ONE * 0.2

@export var radius: float = 30.0
@export var radius_delta: float = 1.0
@export var circle_color: Color = Color.BLUE
@export var filled: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("brush_size_up"):
		radius += radius_delta
		Brush.radius = radius
	elif event.is_action_pressed("brush_size_down"):
		radius -= radius_delta
		Brush.radius = radius
	elif event.is_action_pressed("zoom_in"):
		zoom += Vector2.ONE * zoom_speed
	elif event.is_action_pressed("zoom_out") and zoom > MIN_ZOOM:
		zoom -= Vector2.ONE * zoom_speed

func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	position += direction * move_speed * delta
	queue_redraw()

func _draw() -> void:
	draw_circle(get_local_mouse_position(), radius, circle_color, filled)
