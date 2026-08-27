extends Camera2D

@export var move_speed: float = 500.0
@export var zoom_speed: float = 0.1


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("brush_size_up") and not event.is_action_pressed("brush_size_down"):
		if event.is_action_pressed("zoom_in") and zoom != Vector2.ZERO:
			zoom += Vector2.ONE * zoom_speed
		elif event.is_action_pressed("zoom_out") and zoom != Vector2.ZERO:
			zoom -= Vector2.ONE * zoom_speed

func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	position += direction * move_speed * delta
