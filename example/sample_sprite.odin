package example

import "core:c"
import "core:math/rand"
import sdl "vendor:sdl3"
import gp ".."

image_sprite: gp.Image

sample_sprite_setup :: proc () {
	surface := sdl.LoadSurface("../SDL_gp/images/sprites.png")
	if surface == nil {
		sdl.Log("Failed to load image: %s", sdl.GetError())
	}

	image_sprite = gp.CreateImage(surface)

	sdl.DestroySurface(surface)
}

sample_sprite_render :: proc (delta_time_ms: u64) {

	window_width, window_height: c.int
	sdl.GetWindowSize(_context.window, &window_width, &window_height)
	window := [2]int{int(window_width), int(window_height)}

	TILE :: [2]int{32, 32}

	tile_region := [3]gp.Rect{
		{ 0, 0, 32, 32}, // tile 1
		{32, 0, 32, 32}, // tile 2
		{64, 0, 32, 32}, // tile 3
	}

	gp.SetBlendMode(.BLEND)
	gp.SetColor(255)
	gp.SetImage(0, image_sprite)

	for i in 0..<4096 {
		x := rand.int_max(window.x)
		y := rand.int_max(window.y)

		src_rect := tile_region[i % 3]
		dst_rect := gp.Rect{f32(x), f32(y), **gp.Vec2(TILE*2)}

		gp.DrawTexturedRect(0, {dst_rect, src_rect})
	}
}

sample_sprite_shutdown :: proc () {
	gp.DestroyImage(image_sprite)
}
