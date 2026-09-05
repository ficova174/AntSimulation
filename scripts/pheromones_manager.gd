extends Node2D


var rd: RenderingDevice
var pheromones_shader_file: Resource = preload("res://shaders/pheromones.glsl")
var pheromones_shader: RID
var pheromones_pipeline: RID
var shader_set: int

# Textures for ping pong
var pheromones_tex_a: RID
var pheromones_tex_b: RID

var uniform_set_a_to_b: RID
var uniform_set_b_to_a: RID

var display_pheromones_tex: Texture2DRD


func init(shared_rd: RenderingDevice, s_set: int, width: int, height: int) -> void:
	rd = shared_rd
	shader_set = s_set
	pheromones_shader = rd.shader_create_from_spirv(pheromones_shader_file.get_spirv())
	pheromones_pipeline = rd.compute_pipeline_create(pheromones_shader)

	var tf: RDTextureFormat = _create_texture_format(width, height)
	pheromones_tex_a = rd.texture_create(tf, RDTextureView.new())
	pheromones_tex_b = rd.texture_create(tf, RDTextureView.new())

	_init_pheromones_map()

	uniform_set_a_to_b = _create_set_pheromones(pheromones_tex_a, pheromones_tex_b)
	uniform_set_b_to_a = _create_set_pheromones(pheromones_tex_b, pheromones_tex_a)

func _create_texture_format(width: int, height: int) -> RDTextureFormat:
	var tf: RDTextureFormat = RDTextureFormat.new()
	# Format must match the data format specified in the shader
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	# Sampling bit -> necessary to display
	# Can copy to bit -> for texture_clear
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT \
					| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
					| RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	tf.width = width
	tf.height = height

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

func compute_pheromones(delta: float, step_toggle: bool) -> void:
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
	push_constant.encode_float(16, Brush.radius)
	push_constant.encode_s32(20, int(blend_add))
	push_constant.encode_float(24, delta)

	var compute_list: int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pheromones_pipeline)
	rd.compute_list_bind_uniform_set(compute_list, current_set, shader_set)
	rd.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	# Look at the local size of a workgroup in the shader file
	var group_size_x_y: int = 16
	var dispatch_x: int = display_pheromones_tex.get_width() / group_size_x_y
	var dispatch_y: int = display_pheromones_tex.get_height() / group_size_x_y
	rd.compute_list_dispatch(compute_list, dispatch_x, dispatch_y, 1)
	rd.compute_list_end()

func update_sprite(step_toggle: bool) -> void:
	var latest_tex: RID = pheromones_tex_b if step_toggle else pheromones_tex_a
	display_pheromones_tex.texture_rd_rid = latest_tex

func _exit_tree() -> void:
	if rd:
		rd.free_rid(pheromones_pipeline)
		rd.free_rid(uniform_set_a_to_b)
		rd.free_rid(uniform_set_b_to_a)
		rd.free_rid(pheromones_tex_a)
		rd.free_rid(pheromones_tex_b)
		rd.free_rid(pheromones_shader)
