package example

import "core:c"
import sdl "vendor:sdl3"
import gp ".."

image_rect: gp.Image

sample_rect_setup :: proc () {
	surface := sdl.LoadSurface("../SDL_gp/images/hello-world.png")
	if surface == nil {
		sdl.Log("Failed to load image: %s", sdl.GetError())
	}

	image_rect = gp.CreateImage(surface)

	sdl.DestroySurface(surface)
}

sample_rect_render :: proc (delta_time_ms: u64) {

	window_width, window_height: c.int
	sdl.GetWindowSize(_context.window, &window_width, &window_height)
	window := [2]int{int(window_width), int(window_height)}

	h := window/2

	// Draw a red filled rectangle.
	{
		gp.Viewport(0, 0, i32(h.x), window_height)
		gp.SetColor({10, 10, 10, 255})
		gp.Clear()

		gp.PushTransform()
		{
			gp.SetColor({255, 0, 0, 255})

			// Move to the left area of the viewport
			gp.Translate(f32(h.x) * 0.5, f32(h.y))

			half_shape := f32(window.x) * 0.15 // 15% of the viewport width

			gp.DrawFilledRect({-half_shape, -half_shape, half_shape * 2, half_shape * 2})
		}
		gp.PopTransform()
	}

	// Draw a textured rectangle keeping it's original color.
	{
		gp.Viewport(i32(h.x), 0, i32(h.x), window_height)
		gp.SetColor({20, 20, 20, 255})
		gp.Clear()

		gp.PushTransform()
		{
			gp.SetColor(255)

			// Move to the right area of the viewport
			gp.Translate(f32(h.x) * 0.5, f32(h.y))

			gp.SetImage(0, image_rect)

			width  := gp.GetImageWidth(image_rect)
			height := gp.GetImageHeight(image_rect)
			size := gp.Vec2{f32(width), f32(height)}

			scale := size * 2

			gp.DrawTexturedRect(0, {
				src = {0, 0, **size},
				dst = {**(-scale/2), **scale},
			})
		}
		gp.PopTransform();
	}
}

sample_rect_shutdown :: proc () {
	gp.DestroyImage(image_rect)
}
