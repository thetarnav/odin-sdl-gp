// Image (Public)
// ----------------------------------------------------------------------------
//
// An image is a wrapper around a GPU texture, with some additional metadata
// (width and height). The image creation function will create a GPU texture
// from an sdl.Surface and upload the surface pixels to the GPU texture.
//
// NOTE: The surface will be converted to the swapchain texture format if
// needed.
package sdl_gp

import sdl "vendor:sdl3"

Sampler :: enum u32 {
	POINT_CLAMP  = 0,
	POINT_WRAP   = 1,
	LINEAR_CLAMP = 2,
	LINEAR_WRAP  = 3,
	SIZE         = 4,
}

Image :: struct {id: u32}

@(default_calling_convention="c", link_prefix="SDL_GP", require_results)
foreign lib {
	// Create an image from an sdl.Surface. Returns an invalid image if creation
	// failed, use GetLastError() to get more information about the error.
	CreateImage :: proc (surface: ^sdl.Surface) -> Image ---

	// Destroy an image and free its resources.
	DestroyImage :: proc (image: Image) ---

	// Get the GPU texture associated with an image. Returns NULL if the image is
	// invalid.
	GetImageGPUTexture :: proc (image: Image) -> ^sdl.GPUTexture ---

	// Get the width of an image in pixels. Returns 0 if the image is invalid.
	GetImageWidth :: proc (image: Image) -> i32 ---

	// Get the height of an image in pixels. Returns 0 if the image is invalid.
	GetImageHeight :: proc (image: Image) -> i32 ---
}
