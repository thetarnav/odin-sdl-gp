// Shader (Public)
// ----------------------------------------------------------------------------
package sdl_gp

import sdl "vendor:sdl3"

Shader :: struct {id: u32}

ShaderDesc :: struct {
	// Vertex shader description
	code_size:            i32,
	code:                 [^]byte,
	entrypoint:           cstring,
	stage:                sdl.GPUShaderStage,
	format:               sdl.GPUShaderFormat,
	num_samplers:         u32,
	num_storage_textures: u32,
	num_storage_buffers:  u32,
	num_uniform_buffers:  u32,
}

@(default_calling_convention="c", link_prefix="SDL_GP", require_results)
foreign lib {
	// Create a shader from vertex and fragment shader descriptions. Returns an
	// invalid shader if creation failed, Use GetLastError() to get more
	// information about the error.
	CreateShader :: proc (desc: ^ShaderDesc) -> Shader ---

	// Get the SDL shader associated with a SDL_gp shader. Returns NULL if the
	// shader is invalid.
	GetGPUShader :: proc (shader: Shader) -> ^sdl.GPUShader ---

	// Destroy a shader and free its resources.
	DestroyShader :: proc (shader: Shader) ---
}
