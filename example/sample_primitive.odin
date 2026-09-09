package example

import "core:math"
import "core:c"
import sdl "vendor:sdl3"
import gp ".."

sample_primitive_setup :: proc () {}

sample_primitive_render :: proc (delta_time_ms: u64) {

	window_width, window_height: c.int
	sdl.GetWindowSize(_context.window, &window_width, &window_height)
	window := [2]int{int(window_width), int(window_height)}

	h := window/2

	// Seconds since start
	time := sdl.GetTicks() / 1000.0

	// Oscillate between -1 and 1 every second
	osc_1 := math.sin(f32(time) * math.PI)

	// Quadrant 1
	// ===============================================================
	// Draw points
	{
		gp.Viewport(0, 0, i32(h.x), i32(h.y))
		gp.SetColor({10, 10, 10, 255})
		gp.Clear()

		gp.SetColor(255)

		// -31 instead of -32 to draw points at the edges of the viewport
		for y := 32; y < h.y - 31; y += 8 {
			for x := 32; x < h.x - 31; x += 8 {
				gp.DrawPoint({f32(x), f32(y)})
			}
		}
	}

	// Quadrant 2
	// ===============================================================
	// Triangles
	{
		gp.Viewport(i32(h.x), 0, i32(h.x), i32(h.y))
		gp.SetColor({20, 20, 20, 255})
		gp.Clear()

		gp.PushTransform()
		{
			// Move to the center of the left area of the viewport
			gp.Translate(**(gp.Vec2(h) * {0.25, 0.5}))

			// Oscillate the scale between 0.75 and 1.25
			gp.Scale(1.0 + 0.25 * osc_1, 1.0 + 0.25 * osc_1)

			half_shape := f32(h.x) * 0.15 // 15% of the viewport width

			gp.SetColor({255, 0, 255, 255})

			gp.DrawFilledTriangle({
				a = {          0, -half_shape},
				b = { half_shape,  half_shape},
				c = {-half_shape,  half_shape},
			})
		}
		gp.PopTransform()

		gp.PushTransform()
		{
			// Move to the center of the right area of the viewport
			gp.Translate(**(gp.Vec2(h) * {0.75, 0.5}))

			// Oscillate the scale between 0.75 and 1.25
			gp.Scale(1.0 + 0.25 * -osc_1, 1.0 + 0.25 * -osc_1)

			half_shape := f32(h.x) * 0.15 // 15% of the viewport width

			// Draw a colorful triangle strip
			colors := [3]sdl.Color{
				{255, 100, 100, 255},
				{255, 180, 100, 255},
				{180, 100, 255, 255},
			}

			positions := [4]gp.Vec2{
				{          0, -half_shape},
				{ half_shape,  half_shape},
				{-half_shape,  half_shape},
				{          0,           0},
			}

			vertex_buffer: [3]gp.Vertex

			for &v, i in vertex_buffer {
				v.position = positions[i]
				v.color    = colors[i]
			}

			gp.Draw(.TRIANGLE_STRIP, auto_cast &vertex_buffer, 3)
		}
		gp.PopTransform()
	}

	// Quadrant 3
	// ===============================================================
	// Draw tiangles fans
	{
		gp.Viewport(0, i32(h.y), i32(h.x), i32(h.y))
		gp.SetColor({20, 20, 20, 255})
		gp.Clear()

		// Hexagon
		gp.PushTransform()
		{
			// Move the the center of the left area of the viewport
			gp.Translate(f32(h.x) * 0.25, f32(h.y) * 0.5)

			// Rotate 90 degrees clockwise and counter-clockwise every second
			gp.Rotate(osc_1 * math.PI * 0.5)

			half_shape := f32(h.x) * 0.15 // 15% of the viewport width

			gp.SetColor({0, 255, 255, 255})

			step := f32(2.0 * math.PI) / 6.0

			// 6 segments + 1 for the center vertex (each 3 vertices)
			points_buffer := make([dynamic]gp.Vec2, 0, 7, context.temp_allocator)

			for angle: f32; angle <= 2.0 * math.PI + step * 0.5; angle += step {

				append(&points_buffer, gp.Vec2{
					half_shape * math.cos(angle),
					half_shape * math.sin(angle),
				})

				// Add a center vertex every 3 vertices
				if len(points_buffer) % 3 == 1 {
					append(&points_buffer, gp.Vec2(0))
				}
			}

			gp.DrawFilledTrianglesStrip(raw_data(points_buffer), len(points_buffer))
		}
		gp.PopTransform()

		// Color wheel with 64 segments
		gp.PushTransform()
		{
			// Move to the center of the right area of the viewport
			gp.Translate(f32(h.x) * 0.75, f32(h.y) * 0.5)

			half_shape := f32(h.x) * 0.15 // 15% of the viewport width

			step := f32(2.0 * math.PI) / 64.0

			// 64 segments + 32 center vertices (each 3 vertices)
			vertex_buffer := make([dynamic]gp.Vertex, 0, 64 + 32, context.temp_allocator)

			for angle: f32; angle <= 2.0 * math.PI + step * 0.5; angle += step {

				append(&vertex_buffer, gp.Vertex{
					position = {
						half_shape * math.cos(angle),
						half_shape * math.sin(angle),
					},
					color = {
						u8((math.sin(angle + f32(time) * 1) + 1.0) * 0.5 * 255),
						u8((math.sin(angle + f32(time) * 2) + 1.0) * 0.5 * 255),
						u8((math.sin(angle + f32(time) * 4) + 1.0) * 0.5 * 255),
						255,
					},
				})

				// Add a center vertex every 3 vertices
				if len(vertex_buffer) % 3 == 1 {
					append(&vertex_buffer, gp.Vertex{position=0, color=255})
				}
			}

			gp.Draw(.TRIANGLE_STRIP, raw_data(vertex_buffer), len(vertex_buffer))
		}
		gp.PopTransform()
	}

	// Quadrant 4
	// ===============================================================
	// Draw lines
	{
		gp.Viewport(i32(h.x), i32(h.y), i32(h.x), i32(h.y))
		gp.SetColor({10, 10, 10, 255})
		gp.Clear()

		gp.PushTransform()
		{
			// Move to the center of the viewport
			gp.Translate(**(gp.Vec2(h) * 0.5))

			// Rotate indefinitely
			gp.Rotate(f32(time) * math.PI * 0.25)

			half_shape := f32(h.x) * 0.15 // 15% of the viewport width

			gp.SetColor({255, 255, 0, 255})

			gp.DrawLine({a = -half_shape,
			             b =  half_shape})

			gp.DrawLine({a = {half_shape, -half_shape},
			             b = {-half_shape, half_shape}})
		}
		gp.PopTransform()
	}
}

sample_primitive_shutdown :: proc () {}

