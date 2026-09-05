extends Node2D


@export var num_ants: int = 1
var entrance_pos: Vector2

func init(pos: Vector2) -> void:
	entrance_pos = pos
	$Sprite2D.position = entrance_pos
