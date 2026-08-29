extends Node2D


const NUM_ANTS: int = 100
const HEIGHT: int = 512
const WIDTH: int = 512

var radius: float = 30.0
var radius_delta: float = 1.0
var circle_color: Color = Color.BLUE
var filled: bool = false

var rd: RenderingDevice

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

var display_tex: Texture2DRD
var step_toggle: bool = false


func _ready() -> void:
	rd = RenderingServer.get_rendering_device()
	_init_pheromones()
	_init_ants()

func _init_pheromones() -> void:
	var pheromones_shader_file: Resource = preload("res://shaders/pheromones.glsl")
	pheromones_shader = rd.shader_create_from_spirv(pheromones_shader_file.get_spirv())
	pheromones_pipeline = rd.compute_pipeline_create(pheromones_shader)

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

	pheromones_tex_a = rd.texture_create(tf, RDTextureView.new())
	pheromones_tex_b = rd.texture_create(tf, RDTextureView.new())

	display_tex = Texture2DRD.new()
	display_tex.texture_rd_rid = pheromones_tex_a
	$PheromonesMap.texture = display_tex
	rd.texture_clear(pheromones_tex_a, Color(0.0, 0.0, 1.0, 1.0), 0, 1, 0, 1)
	rd.texture_clear(pheromones_tex_b, Color(0.0, 0.0, 1.0, 1.0), 0, 1, 0, 1)

	uniform_set_a_to_b = _create_set_pheromones(pheromones_tex_a, pheromones_tex_b)
	uniform_set_b_to_a = _create_set_pheromones(pheromones_tex_b, pheromones_tex_a)

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
	var ants_shader_file: Resource = preload("res://shaders/ants.glsl")
	ants_shader = rd.shader_create_from_spirv(ants_shader_file.get_spirv())
	ants_pipeline = rd.compute_pipeline_create(ants_shader)

	var ants_data: PackedByteArray = PackedByteArray()
	var ant_data_size: int = 16
	ants_data.resize(NUM_ANTS * ant_data_size)

	var center: Vector2 = Vector2(WIDTH * 0.5, HEIGHT * 0.5)

	for i in range(NUM_ANTS):
		var offset: int = i * ant_data_size

		var angle: float = randf() * TAU
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * (randf() * 20.0)

		# float takes 4 bytes and we need padding bc a struct offset
		# must be a multiple of its biggest element for aligment purposes
		ants_data.encode_float(offset + 0, pos.x)
		ants_data.encode_float(offset + 4, pos.y)
		ants_data.encode_float(offset + 8, angle)
		ants_data.encode_float(offset + 12, 0.0)

	ants_buffer = rd.storage_buffer_create(ants_data.size(), ants_data)

	uniform_set_ants_a = _create_set_ants(pheromones_tex_a)
	uniform_set_ants_b = _create_set_ants(pheromones_tex_b)

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
	rd.compute_list_dispatch(compute_list, NUM_ANTS, 1, 1)
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
	rd.compute_list_dispatch(compute_list, WIDTH / 16, HEIGHT / 16, 1)
	rd.compute_list_end()

func _process(_delta: float) -> void:
	var latest_output: RID = pheromones_tex_b if step_toggle else pheromones_tex_a
	display_tex.texture_rd_rid = latest_output

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
