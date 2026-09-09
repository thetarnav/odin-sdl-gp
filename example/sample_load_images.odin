package example

import "core:c"
import "core:math/rand"
import sdl "vendor:sdl3"
import gp ".."

MAX_IMAGES    :: 30
TRIGGER_FRAME :: 60

_images_setup: [MAX_IMAGES]gp.Image
_images_frame: [MAX_IMAGES]gp.Image

sample_load_images_setup :: proc () {

	surface := sdl.LoadSurface("../SDL_gp/images/hello-world.png")
	if surface == nil {
		sdl.Log("Failed to load image: %s", sdl.GetError())
	}

	for &i in _images_setup {
		i = gp.CreateImage(surface)
	}

	sdl.DestroySurface(surface)
}

frame_count: int

sample_load_images_render :: proc (delta_time_ms: u64) {

	sdl.Log("Frame count: %i", frame_count)

	window_width, window_height: c.int
	sdl.GetWindowSize(_context.window, &window_width, &window_height)
	window := [2]int{int(window_width), int(window_height)}

	gp.SetBlendMode(.BLEND)

	// trigger loading images after a certain number of frames
	if frame_count == TRIGGER_FRAME {

		surface := sdl.LoadSurface("../SDL_gp/images/sprites.png")
		if surface == nil {
			sdl.Log("Failed to load image: %s", sdl.GetError())
		}

		for &i in _images_frame {
			i = gp.CreateImage(surface)
		}

		sdl.DestroySurface(surface)
	}

	// Render the images loaded during the frame that triggered the loading
	// and onwards
	if frame_count >= TRIGGER_FRAME {

		@static
		tile_region := [3]gp.Rect{
			{ 0, 0, 32, 32}, // tile 1
			{32, 0, 32, 32}, // tile 2
			{64, 0, 32, 32}, // tile 3
		}

		gp.SetColor(255)

		// randomly select one of the loaded images to render
		gp.SetImage(0, _images_frame[rand.int_max(MAX_IMAGES)])

		for i in 0..<4096 {
			x := rand.int_max(window.x)
			y := rand.int_max(window.y)

			src_rect := tile_region[i % 3]
			dst_rect := gp.Rect{f32(x), f32(y), 64, 64}

			gp.DrawTexturedRect(0, {dst_rect, src_rect})
		}

		gp.ResetImage(0)
	}

	// Render the images loaded during setup all the time
	image := _images_setup[sdl.rand(MAX_IMAGES)]

	gp.SetImage(0, image)

	gp.SetColor(255)

	width  := gp.GetImageWidth(image)
	height := gp.GetImageHeight(image)
	size   := gp.Vec2{f32(width), f32(height)}

	src_rect := gp.Rect{0, 0, f32(width), f32(height)}
	dst_rect := gp.Rect{**((gp.Vec2(window) - size) * 0.5), **size}

	gp.DrawTexturedRect(0, {dst_rect, src_rect})
	gp.ResetImage(0)

	gp.ResetBlendMode()

	frame_count += 1
}

sample_load_images_shutdown :: proc () {
	for i in _images_setup do gp.DestroyImage(i)
	for i in _images_frame do gp.DestroyImage(i)
}
