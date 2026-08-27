extends Sprite2D


const HEIGHT: int = 1024
const WIDTH: int = 1024

var radius: float = 30.0
var radius_delta: float = 1.0
var circle_color: Color = Color.BLUE
var filled: bool = false

var rd: RenderingDevice
var shader_rid: RID
var pipeline_rid: RID

var shader_set: int = 0

# Textures for ping pong
var tex_a: RID
var tex_b: RID

var uniform_set_a_to_b: RID
var uniform_set_b_to_a: RID

var display_tex: Texture2DRD
var step_toggle: bool = false


func _ready() -> void:
	rd = RenderingServer.get_rendering_device()

	var shader_file: Resource = load("res://shaders/pheromones.glsl")
	shader_rid = rd.shader_create_from_spirv(shader_file.get_spirv())
	pipeline_rid = rd.compute_pipeline_create(shader_rid)

	var tf: RDTextureFormat = RDTextureFormat.new()
	# Warning not all R8G8B8A8 types seem to work
	tf.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	tf.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	# Sampling bit -> necessary to display
	tf.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT \
					| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	tf.height = HEIGHT
	tf.width = WIDTH

	tex_a = rd.texture_create(tf, RDTextureView.new())
	tex_b = rd.texture_create(tf, RDTextureView.new())

	display_tex = Texture2DRD.new()
	display_tex.texture_rd_rid = tex_a
	self.texture = display_tex

	uniform_set_a_to_b = _create_set(tex_a, tex_b)
	uniform_set_b_to_a = _create_set(tex_b, tex_a)

	pipeline_rid = rd.compute_pipeline_create(shader_rid)

func _create_set(read_tex: RID, write_tex: RID) -> RID:
	var u_read: RDUniform = RDUniform.new()
	u_read.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u_read.binding = 0
	u_read.add_id(read_tex)

	var u_write: RDUniform = RDUniform.new()
	u_write.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u_write.binding = 1
	u_write.add_id(write_tex)

	return rd.uniform_set_create([u_read, u_write], shader_rid, shader_set)

func _input(event) -> void:
	if event.is_action_pressed("brush_size_up"):
		radius += radius_delta
	elif event.is_action_pressed("brush_size_down"):
		radius -= radius_delta

func _process(_delta: float) -> void:
	#if Input.is_action_pressed("increase"):
		#texture.blit()
	#elif Input.is_action_pressed("decrease"):
		#texture.blit()
	#queue_redraw()

	var current_set: RID = uniform_set_a_to_b if not step_toggle else uniform_set_b_to_a
	var current_output: RID = tex_b if not step_toggle else tex_a

	var compute_list: int = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline_rid)
	rd.compute_list_bind_uniform_set(compute_list, current_set, shader_set)
	rd.compute_list_dispatch(compute_list, ceili(WIDTH / 8.0), ceili(HEIGHT / 8.0), 1)
	rd.compute_list_end()

	display_tex.texture_rd_rid = current_output

func _draw() -> void:
	draw_circle(get_local_mouse_position(), radius, circle_color, filled)

func _exit_tree() -> void:
	if rd:
		rd.free_rid(pipeline_rid)
		rd.free_rid(uniform_set_a_to_b)
		rd.free_rid(uniform_set_b_to_a)
		rd.free_rid(tex_a)
		rd.free_rid(tex_b)
		rd.free_rid(shader_rid)
