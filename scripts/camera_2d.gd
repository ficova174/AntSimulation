extends Camera2D


@export var move_speed: float = 500.0
@export var zoom_speed: float = 0.1
@export var MIN_ZOOM: Vector2 = Vector2.ONE * 0.2
var allow_echo: bool = false
var exact_match: bool = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in", allow_echo, exact_match):
		zoom += Vector2.ONE * zoom_speed
	elif event.is_action_pressed("zoom_out", allow_echo, exact_match) and zoom > MIN_ZOOM:
		zoom -= Vector2.ONE * zoom_speed

func _process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	position += direction * move_speed * delta
