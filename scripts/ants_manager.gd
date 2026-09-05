extends Node2D


@export var ants_per_colony: int = 50
var total_ants: int = 0

var rd: RenderingDevice
var ants_shader_file: Resource = preload("res://shaders/ants.glsl")
var ants_shader: RID
var ants_pipeline: RID
var shader_set: int

var ants_buffer: RID

var uniform_set_ants_a: RID
var uniform_set_ants_b: RID

var ant_sprites: Array[Sprite2D] = []
var ant_texture: Resource = preload("res://assets/ant.png")


func init(shared_rd: RenderingDevice, s_set: int, tex_a: RID, tex_b: RID, colony_positions: Array[Vector2]) -> void:
	rd = shared_rd
	shader_set = s_set
	total_ants = ants_per_colony * colony_positions.size()

	ants_shader = rd.shader_create_from_spirv(ants_shader_file.get_spirv())
	ants_pipeline = rd.compute_pipeline_create(ants_shader)

	ants_buffer = _create_ants_buffer(colony_positions)

	uniform_set_ants_a = _create_set_ants(tex_a)
	uniform_set_ants_b = _create_set_ants(tex_b)

func _create_ants_buffer(colony_pos: Array[Vector2]) -> RID:
	var ants_data: PackedByteArray = PackedByteArray()
	var ant_data_size: int = 16
	ants_data.resize(total_ants * ant_data_size)

	var ant_idx: int = 0
	for col_pos in colony_pos:
		for _i in range(ants_per_colony):
			var offset: int = ant_idx * ant_data_size
			var angle: float = randf() * TAU

			_create_ant_sprite(col_pos, angle)

			# float takes 4 bytes and we need padding bc a struct offset
			# must be a multiple of its biggest element for aligment purposes
			ants_data.encode_float(offset + 0, col_pos.x)
			ants_data.encode_float(offset + 4, col_pos.y)
			ants_data.encode_float(offset + 8, angle)
			ants_data.encode_float(offset + 12, 0.0)

			ant_idx += 1

	return rd.storage_buffer_create(ants_data.size(), ants_data)

func _create_ant_sprite(pos: Vector2, angle: float) -> void:
		var ant_sprite: Sprite2D = Sprite2D.new()
		ant_sprite.texture = ant_texture
		ant_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		ant_sprite.position = pos
		ant_sprite.rotation = angle
		$AntsContainer.add_child(ant_sprite)
		ant_sprites.append(ant_sprite)

func _create_set_ants(current_tex: RID) -> RID:
	# Binding 0: ants uniform buffer (reading/writing)
	var u_buffer: RDUniform = RDUniform.new()
	u_buffer.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	u_buffer.binding = 0
	u_buffer.add_id(ants_buffer)

	# Binding 1: Current pheromones tex (reading/writing)
	var u_tex: RDUniform = RDUniform.new()
	u_tex.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u_tex.binding = 1
	u_tex.add_id(current_tex)

	return rd.uniform_set_create([u_buffer, u_tex], ants_shader, shader_set)

func compute_ants(delta: float, step_toggle) -> void:
	var current_set: RID = uniform_set_ants_a if not step_toggle else uniform_set_ants_b

	var push_constant: PackedByteArray = PackedByteArray()
	push_constant.resize(4)
	push_constant.encode_float(0, delta)

	var compute_list: int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, ants_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, current_set, shader_set)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	# Look at the local size of a workgroup in the shader file
	var group_size_x: int = 64
	var dispatch_x: int = ceili(total_ants / float(group_size_x))
	rd.compute_list_dispatch(compute_list, dispatch_x, 1, 1)
	rd.compute_list_end()

func update_sprites() -> void:
	var raw_data: PackedByteArray = rd.buffer_get_data(ants_buffer)
	for i in range(total_ants):
		var offset: int = i * 16
		var pos_x: float = raw_data.decode_float(offset + 0)
		var pos_y: float = raw_data.decode_float(offset + 4)
		var angle: float = raw_data.decode_float(offset + 8)
		ant_sprites[i].position = Vector2(pos_x, pos_y)
		ant_sprites[i].rotation = angle

func _exit_tree() -> void:
	if rd:
		rd.free_rid(ants_pipeline)
		rd.free_rid(uniform_set_ants_a)
		rd.free_rid(uniform_set_ants_b)
		rd.free_rid(ants_buffer)
		rd.free_rid(ants_shader)
