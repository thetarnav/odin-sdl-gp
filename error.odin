// Error handling (Public)
// ----------------------------------------------------------------------------
package sdl_gp

Error :: enum u32 {
	NONE                             = 0,
	SETUP_IMAGE_FAILED               = 1,
	FLUSH_IMAGE_FAILED               = 2,
	CREATE_IMAGE_FAILED              = 3,
	CREATE_SHADER_FAILED             = 4,
	CREATE_PIPELINE_FAILED           = 5,
	CREATE_COMMON_SHADER_FAILED      = 6,
	CREATE_WHITE_TEXTURE_FAILED      = 7,
	CREATE_TRANSFER_BUFFER_FAILED    = 8,
	CREATE_VERTEX_BUFFER_FAILED      = 9,
	CREATE_COMMON_PIPELINE_FAILED    = 10,
	ALLOC_FAILED                     = 11,
	UNIFORMS_FULL                    = 12,
	VERTICES_FULL                    = 13,
	COMMANDS_FULL                    = 14,
	FLUSH_FAILED                     = 15,
	ACQUIRE_COMMAND_BUFFER_FAILED    = 16,
	ACQUIRE_SWAPCHAIN_TEXTURE_FAILED = 17,
}

@(default_calling_convention="c", link_prefix="SDL_GP", require_results)
foreign lib {
	// Get the last error that occurred in SDL_gp. Returns ERROR_NONE if no
	// error has occurred.
	GetLastError :: proc () -> Error ---

	// Get a human-readable string describing an Error value. Returns
	// "Unknown error" if the error value is not recognized.
	GetErrorMessage :: proc (error: Error) -> cstring ---
}
