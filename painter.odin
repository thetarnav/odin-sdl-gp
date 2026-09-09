// Painter (Public)
// ----------------------------------------------------------------------------
package sdl_gp

import sdl "vendor:sdl3"

UniformSlot :: enum u32 {
	VS = 0,
	FS = 1,
}

Vec2  :: [2]f32
Point :: Vec2

Line     :: struct {a, b: Point}
Triangle :: struct {a, b, c: Point}
ISize    :: struct {w, h: i32}
IRect    :: struct {x, y, w, h: i32}
Rect     :: struct {x, y, w, h: f32}

TexturedRect :: struct {
	dst, src: Rect,
}

Mat2x3 :: struct {
	m00, m01, m02: f32,
	m10, m11, m12: f32,
}

Vertex :: struct {
	position: Vec2,
	texcoord: Vec2,
	color:    sdl.Color,
}

UniformData :: struct #raw_union {
	floats: [8]f32,
	bytes:  [32]byte,
}

Uniform :: struct {
	vs_size: u16,
	fs_size: u16,
	data:    UniformData,
}

TextureUniform :: struct {
	count:    u32,
	images:   [4]Image,
	samplers: [4]^sdl.GPUSampler,
}

State :: struct {
	projection:   Mat2x3,
	transform:    Mat2x3,
	mvp:          Mat2x3,
	texture:      TextureUniform,
	uniform:      Uniform,
	pipeline:     Pipeline,
	blend_mode:   BlendMode,
	frame_size:   ISize,
	viewport:     IRect,
	scissor:      IRect,
	color:        sdl.Color,
	thickness:    f32,
	base_uniform: u32,
	base_vertex:  u32,
	base_command: u32,
}

Desc :: struct {
	max_vertices: u32,
	max_commands: u32,
	window:       ^sdl.Window,
	gpu_device:   ^sdl.GPUDevice,
}

@(default_calling_convention="c", link_prefix="SDL_GP")
foreign lib {
	// Setup  context. Returns false if setup failed, use
	// GetLastError() to get more information about the error.
	Setup :: proc (#by_ptr Desc) -> bool ---

	// Shutdown  context.
	Shutdown :: proc () ---

	// Begin recoarding draw calls for the current frame. This should be called
	// after setting up SDL_gp and acquiring a swapchain texture and command
	// buffer for the current frame.
	// If return false then an error occurred and the frame should be skipped,
	// use GetLastError() to get more information about the error.
	Begin :: proc (i32, i32) -> bool ---

	// Flush the recorded draw calls to the GPU. Returns false if an error
	// occurred, use GetLastError() to get more information about the error.
	Flush :: proc (^sdl.GPUCommandBuffer, ^sdl.GPUTexture) -> bool ---

	// End recording draw calls for the current frame.
	End :: proc () ---

	// Set the coordinate space boundaries in the current viewport.
	SetProjection :: proc (left: f32, right: f32, bottom: f32, top: f32) ---

	// Reset the projection to the default coordinate space, which is the
	// coordinate of the current viewport.
	ResetProjection :: proc () ---

	// Save the current transform matrix on the transform stack. To be pop later
	// with PopTransform.
	PushTransform :: proc () ---

	// Restore the transform matrix from the top of the transform stack.
	PopTransform :: proc () ---

	// Set the current transform matrix to identity (no transformation).
	ResetTransform :: proc () ---

	// Translates the 2D coordinates space.
	Translate :: proc (x: f32, y: f32) ---

	// Rotates the 2D coordinate space around the origin.
	Rotate :: proc (angle: f32) ---

	// Rotates the 2D coordinate space around a point.
	RotateAt :: proc (angle: f32, ax: f32, ay: f32) ---

	// Scales the 2D coordinate space around the origin.
	Scale :: proc (sx: f32, sy: f32) ---

	// Scales the 2D coordinate space around a point.
	ScaleAt :: proc (sx: f32, sy: f32, ax: f32, ay: f32) ---

	// Set the current graphics pipeline.
	SetPipeline :: proc (pipeline: Pipeline) ---

	// Reset the graphics pipeline to the default pipeline builtin pipeline.
	ResetPipeline :: proc () ---

	// Set uniform data for the current pipeline.
	SetUniform :: proc (vs_data: rawptr, vs_size: i32, fs_data: rawptr, fs_size: i32) ---

	// Reset uniform data to the default state (current state color).
	ResetUniform :: proc () ---

	// Set the current blend mode.
	SetBlendMode :: proc (blend_mode: BlendMode) ---

	// Reset the current blend mode to the default blend mode (no blending).
	ResetBlendMode :: proc () ---

	// Sets current color.
	SetColor :: proc (color: sdl.Color) ---

	// Gets current color.
	GetColor :: proc () -> sdl.Color ---

	// Reset current color to the default color (white).
	ResetColor :: proc () ---

	// Sets current bound image in a texture channel.
	SetImage :: proc (channel: i32, image: Image) ---

	// Remove current bound image from a texture channel (no texture).
	UnsetImage :: proc (channel: i32) ---

	// Reset current bound image in a texture channel to the default (white
	// texture).
	ResetImage :: proc (channel: i32) ---

	// Set current bound sampler in a texture channel.
	SetSampler :: proc (channel: i32, sampler: ^sdl.GPUSampler) ---

	// Remove current bound sampler from a texture channel (no sampler).
	UnsetSampler :: proc (channel: i32) ---

	// Reset current bound sampler in a texture channel to default (nearest
	// sampler).
	ResetSampler :: proc (channel: i32) ---

	// Set the screen are to draw to.
	Viewport :: proc (x: i32, y: i32, w: i32, h: i32) ---

	// Reset the viewport to default (0, 0, width, height).
	ResetViewport :: proc () ---

	// Set the clipping rectangle in the viewport.
	Scissor :: proc (x: i32, y: i32, w: i32, h: i32) ---

	// Reset the clipping rectangle to default (viewport bounds).
	ResetScissor :: proc () ---

	// Reset all state to default.
	ResetState :: proc () ---

	// Clear the current viewport with the current color.
	Clear :: proc () ---

	// Draw any primitive.
	Draw :: proc (primitive_type: PrimitiveType, vertices: [^]Vertex, #any_int vertices_count: u32) ---

	// Draw points in batch.
	DrawPoints :: proc (points: [^]Point, #any_int count: u32) ---

	// Draw a single point.
	DrawPoint :: proc (point: Point) ---

	// Draw lines in batch.
	DrawLines :: proc (lines: [^]Line, #any_int count: u32) ---

	// Draw a single line.
	DrawLine :: proc (line: Line) ---

	// Draw a stip of lines.
	DrawLinesStrip :: proc (points: [^]Vec2, #any_int count: u32) ---

	// Draw triangles in batch.
	DrawFilledTriangles :: proc (triangles: [^]Triangle, #any_int count: u32) ---

	// Draw a single triangle.
	DrawFilledTriangle :: proc (triangle: Triangle) ---

	// Draw a strip of triangles.
	DrawFilledTrianglesStrip :: proc (points: [^]Vec2, #any_int count: u32) ---

	// Draw rectangles in batch.
	DrawFilledRects :: proc (rects: [^]Rect, count: u32) ---

	// Draw a single rectangle.
	DrawFilledRect :: proc (rect: Rect) ---

	// Draw textured rectangles in batch.
	DrawTexturedRects :: proc (channel: i32, rects: [^]TexturedRect, #any_int count: u32) ---

	// Draw a single textured rectangle.
	DrawTexturedRect :: proc (channel: i32, rect: TexturedRect) ---
}
