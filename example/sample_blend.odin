package example

import "core:c"
import sdl "vendor:sdl3"
import gp ".."

draw_rects :: proc (brightness, alpha: u8) {
	// Red rectangle
	gp.SetColor({brightness, 0, 0, alpha})
	gp.DrawFilledRect({10, 10, 50, 50})

	gp.Translate(10, 10)

	// Green rectangle
	gp.SetColor({0, brightness, 0, alpha})
	gp.DrawFilledRect({10, 10, 50, 50})

	gp.Translate(10, 10)

	// Blue rectangle
	gp.SetColor({0, 0, brightness, alpha})
	gp.DrawFilledRect({10, 10, 50, 50})
}

draw_checkboard :: proc (width, height: int) {
	size := 20
	for y := 0; y < height; y += size {
		for x := 0; x < width; x += size {
			is_white := ((x / size) + (y / size)) % 2 == 0
			color := is_white ? \
				sdl.Color{150, 150, 150, 255} : \
				sdl.Color{50, 50, 50, 255}
			gp.SetColor(color)
			gp.DrawFilledRect({f32(x), f32(y), f32(size), f32(size)})
		}
	}
}

sample_blend_setup :: proc () {}

sample_blend_render :: proc (delta_time_ms: u64) {
	brightness := u8(255)
	alpha      := u8(128)

	window_width, window_height: c.int
	sdl.GetWindowSize(_context.window, &window_width, &window_height)
	window := [2]int{int(window_width), int(window_height)}

	gp.SetColor({0,0,0,255})
	gp.Clear()

	gp.SetBlendMode(.NONE)

	draw_checkboard(**window)

	gp.SetBlendMode(.NONE)
	gp.PushTransform()
	gp.Translate(0, 0)
	draw_rects(brightness, alpha)
	gp.PopTransform()

	gp.SetBlendMode(.BLEND)
	gp.PushTransform()
	gp.Translate(80, 0)
	draw_rects(brightness, alpha)
	gp.PopTransform()

	gp.SetBlendMode(.BLEND_PREMULTIPLIED)
	gp.PushTransform()
	gp.Translate(160, 0)
	draw_rects(brightness, alpha)
	gp.PopTransform()

	gp.SetBlendMode(.ADD)
	gp.PushTransform()
	gp.Translate(80, 80)
	draw_rects(brightness, alpha)
	gp.PopTransform()

	gp.SetBlendMode(.ADD_PREMULTIPLIED)
	gp.PushTransform()
	gp.Translate(160, 80)
	draw_rects(brightness, alpha)
	gp.PopTransform()

	gp.SetBlendMode(.MOD)
	gp.PushTransform()
	gp.Translate(80, 160)
	draw_rects(brightness, alpha)
	gp.PopTransform()

	gp.SetBlendMode(.MUL)
	gp.PushTransform()
	gp.Translate(160, 160)
	draw_rects(brightness, alpha)
	gp.PopTransform()
}

sample_blend_shutdown :: proc () {}
