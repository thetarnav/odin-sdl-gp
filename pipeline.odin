// Pipeline (Public)
// ----------------------------------------------------------------------------
package sdl_gp

import sdl "vendor:sdl3"

BlendMode :: enum u32 {
	NONE                = 0,
	BLEND               = 1,
	BLEND_PREMULTIPLIED = 16,
	ADD                 = 2,
	ADD_PREMULTIPLIED   = 32,
	MOD                 = 4,
	MUL                 = 8,
	SIZE                = 7,
}

PrimitiveType :: enum u32 {
	TRIANGLES      = 0,
	TRIANGLE_STRIP = 1,
	LINES          = 2,
	LINE_STRIP     = 3,
	POINTS         = 4,
	SIZE           = 5,
}

Pipeline :: struct {id: u32}

@(default_calling_convention="c", link_prefix="SDL_GP", require_results)
foreign lib {
	// Create a graphics pipeline, Returns an invalid pipeline if creation failed,
	// Use GetLastError() to get more information about the error.
	CreatePipeline :: proc (shader_vert: Shader, shader_frag: Shader, primitive_type: PrimitiveType, blend_mode: BlendMode) -> Pipeline ---

	// Destroy a graphics pipeline and free its resources.
	DestroyPipeline :: proc (pipeline: Pipeline) ---

	// Get the GPU graphics pipeline associated with a SDL_gp pipeline. Returns
	// NULL if the pipeline is invalid.
	GetGPUPipeline :: proc (pipeline: Pipeline) -> ^sdl.GPUGraphicsPipeline ---
}
