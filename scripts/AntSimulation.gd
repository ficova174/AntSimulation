extends Node2D


const NUM_ANTS: int = 100
const HEIGHT: int = 2048
const WIDTH: int = 2048

var radius: float = 30.0
var radius_delta: float = 1.0
var circle_color: Color = Color.BLUE
var filled: bool = false

var rd: RenderingDevice

var pheromones_shader_file: Resource = preload("res://shaders/pheromones.glsl")
var ants_shader_file: Resource = preload("res://shaders/ants.glsl")

var pheromones_shader: RID
var ants_shader: RID

var pheromones_pipeline: RID
var ants_pipeline: RID

var shader_set: int = 0

# Textures for ping pong
var pheromones_tex_a: RID
var pheromones_tex_b: RID

var ants_buffer: RID

# Pheromones
var uniform_set_a_to_b: RID
var uniform_set_b_to_a: RID
# Ants
var uniform_set_ants_a: RID
var uniform_set_ants_b: RID

var display_pheromones_tex: Texture2DRD
var step_toggle: bool = false

var ant_sprites: Array[Sprite2D] = []
var ant_texture: Resource = preload("res://assets/ant.png")


func _ready() -> void:
	rd = RenderingServer.get_rendering_device()
	_init_pheromones()
	_init_ants()

func _init_pheromones() -> void:
	pheromones_shader = rd.shader_create_from_spirv(pheromones_shader_file.get_spirv())
	pheromones_pipeline = rd.compute_pipeline_create(pheromones_shader)

	var tf: RDTextureFormat = _create_texture_format()
	pheromones_tex_a = rd.texture_create(tf, RDTextureView.new())
	pheromones_tex_b = rd.texture_create(tf, RDTextureView.new())

	_init_pheromones_map()

	uniform_set_a_to_b = _create_set_pheromones(pheromones_tex_a, pheromones_tex_b)
	uniform_set_b_to_a = _create_set_pheromones(pheromones_tex_b, pheromones_tex_a)

func _create_texture_format() -> RDTextureFormat:
	var tf: RDTextureFormat = RDTextureFormat.new()
	# Format must match the data format specified in the shader
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	# Sampling bit -> necessary to display
	# Can copy to bit -> for texture_clear
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT \
					| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
					| RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	tf.height = HEIGHT
	tf.width = WIDTH

	return tf

func _init_pheromones_map() -> void:
	display_pheromones_tex = Texture2DRD.new()
	display_pheromones_tex.texture_rd_rid = pheromones_tex_a
	$PheromonesMap.texture = display_pheromones_tex
	rd.texture_clear(pheromones_tex_a, Color(0.0, 0.0, 1.0, 1.0), 0, 1, 0, 1)
	rd.texture_clear(pheromones_tex_b, Color(0.0, 0.0, 1.0, 1.0), 0, 1, 0, 1)

func _create_set_pheromones(read_tex: RID, write_tex: RID) -> RID:
	var u_read: RDUniform = RDUniform.new()
	u_read.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u_read.binding = 0
	u_read.add_id(read_tex)

	var u_write: RDUniform = RDUniform.new()
	u_write.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u_write.binding = 1
	u_write.add_id(write_tex)

	return rd.uniform_set_create([u_read, u_write], pheromones_shader, shader_set)

func _init_ants() -> void:
	ants_shader = rd.shader_create_from_spirv(ants_shader_file.get_spirv())
	ants_pipeline = rd.compute_pipeline_create(ants_shader)

	ants_buffer = _create_ants_buffer()

	uniform_set_ants_a = _create_set_ants(pheromones_tex_a)
	uniform_set_ants_b = _create_set_ants(pheromones_tex_b)

func _create_ants_buffer() -> RID:
	var ants_data: PackedByteArray = PackedByteArray()
	var ant_data_size: int = 16
	ants_data.resize(NUM_ANTS * ant_data_size)

	var center: Vector2 = Vector2(WIDTH * 0.5, HEIGHT * 0.5)

	for i in range(NUM_ANTS):
		var offset: int = i * ant_data_size

		var angle: float = randf() * TAU
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * (randf() * 200.0)

		_create_ant_sprite(pos, angle)

		# float takes 4 bytes and we need padding bc a struct offset
		# must be a multiple of its biggest element for aligment purposes
		ants_data.encode_float(offset + 0, pos.x)
		ants_data.encode_float(offset + 4, pos.y)
		ants_data.encode_float(offset + 8, angle)
		ants_data.encode_float(offset + 12, 0.0)

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

func _input(event) -> void:
	if event.is_action_pressed("brush_size_up"):
		radius += radius_delta
	elif event.is_action_pressed("brush_size_down"):
		radius = radius - radius_delta if radius - radius_delta >= 1.0 else radius

func _physics_process(delta: float) -> void:
	_compute_ants(delta)
	_compute_pheromones(delta)

	step_toggle = not step_toggle

func _compute_ants(delta: float) -> void:
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
	var dispatch_x: int = ceili(NUM_ANTS / float(group_size_x))
	rd.compute_list_dispatch(compute_list, dispatch_x, 1, 1)
	rd.compute_list_end()

func _compute_pheromones(delta: float) -> void:
	var current_set: RID = uniform_set_a_to_b if not step_toggle else uniform_set_b_to_a

	var is_increase: bool = Input.is_action_pressed("increase")
	var is_decrease: bool = Input.is_action_pressed("decrease")
	var clicked: bool = is_increase or is_decrease
	var blend_add: bool = is_increase
	var mouse_pos: Vector2 = get_local_mouse_position()

	var push_constant: PackedByteArray = PackedByteArray()
	push_constant.resize(28)
	# Like in cpp bool is stored as int
	push_constant.encode_s32(0, int(clicked))
	# Start at 8 not 4 because total size of vec2 is 8 bytes
	# and the offset must be a multiple of the size
	push_constant.encode_float(8, mouse_pos.x)
	push_constant.encode_float(12, mouse_pos.y)
	push_constant.encode_float(16, radius)
	push_constant.encode_s32(20, int(blend_add))
	push_constant.encode_float(24, delta)

	var compute_list: int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pheromones_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, current_set, shader_set)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	# Look at the local size of a workgroup in the shader file
	var group_size_x_y: int = 16
	var dispatch_x: int = WIDTH / group_size_x_y
	var dispatch_y: int = HEIGHT / group_size_x_y
	rd.compute_list_dispatch(compute_list, dispatch_x, dispatch_y, 1)
	rd.compute_list_end()

func _process(_delta: float) -> void:
	var raw_data: PackedByteArray = rd.buffer_get_data(ants_buffer)
	for i in range(NUM_ANTS):
		var offset: int = i * 16
		var pos_x: float = raw_data.decode_float(offset + 0)
		var pos_y: float = raw_data.decode_float(offset + 4)
		var angle: float = raw_data.decode_float(offset + 8)

		ant_sprites[i].position = Vector2(pos_x, pos_y)
		ant_sprites[i].rotation = angle

	var latest_pheromones_tex: RID = pheromones_tex_b if step_toggle else pheromones_tex_a
	display_pheromones_tex.texture_rd_rid = latest_pheromones_tex

	queue_redraw()

func _draw() -> void:
	draw_circle(get_local_mouse_position(), radius, circle_color, filled)

func _exit_tree() -> void:
	if rd:
		rd.free_rid(pheromones_pipeline)
		rd.free_rid(ants_pipeline)

		rd.free_rid(uniform_set_a_to_b)
		rd.free_rid(uniform_set_b_to_a)
		rd.free_rid(uniform_set_ants_a)
		rd.free_rid(uniform_set_ants_b)

		rd.free_rid(pheromones_tex_a)
		rd.free_rid(pheromones_tex_b)
		rd.free_rid(ants_buffer)

		rd.free_rid(pheromones_shader)
		rd.free_rid(ants_shader)
