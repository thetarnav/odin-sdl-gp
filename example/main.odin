package example

import "base:runtime"
import "core:c"
import sdl "vendor:sdl3"
import gp ".."

/*
 * NOTE: use arrow keys to switch between samples
 */

WINDOW_WIDTH  :: 1026
WINDOW_HEIGHT :: 576

DELTA_TIME_MS :: 16 // ~60 FPS

Sample_Type :: enum {
	RECT,
	PRIMITIVE,
	BLEND,
	SPRITE,
	LOAD_IMAGES,
}
_current_test := Sample_Type.RECT

Context :: struct {
	gpu_device:        ^sdl.GPUDevice,
	window:            ^sdl.Window,
	cmd_buffer:        ^sdl.GPUCommandBuffer,
	swapchain_texture: ^sdl.GPUTexture,
}
_context: Context

main :: proc () {
	sdl.EnterAppMainCallbacks(
		argc     = 0,
		argv     = nil,
		appinit  = app_init,
		appiter  = app_iterate,
		appevent = app_event,
		appquit  = app_quit,
	)
}

app_init :: proc "c" (appstate: ^rawptr, argc: c.int, argv: [^]cstring) -> sdl.AppResult {
	context = runtime.default_context()

	// Init SDL
	if !sdl.Init({.VIDEO}) {
		sdl.Log("Couldn't initialize SDL: %s\n", sdl.GetError())
		return .FAILURE
	}

	// Create a GPU device
	_context.gpu_device = sdl.CreateGPUDevice(
		{.SPIRV, .DXIL, .MSL},
		debug_mode=true,
		name=nil)
	if _context.gpu_device == nil {
		sdl.Log("GPUCreateDevice failed: %s", sdl.GetError())
		return .FAILURE
	}

	// Create a window
	_context.window = sdl.CreateWindow("sdl.gp", WINDOW_WIDTH, WINDOW_HEIGHT, sdl.WINDOW_HIGH_PIXEL_DENSITY)
	if _context.window == nil {
		sdl.Log("CreateWindow failed: %s", sdl.GetError())
		return .FAILURE
	}

	// Claim the window for use with the GPU device
	if !sdl.ClaimWindowForGPUDevice(_context.gpu_device, _context.window) {
		sdl.Log("GPUClaimWindow failed")
		return .FAILURE
	}

	// Set the swapchain parameters for the window
	present_mode: sdl.GPUPresentMode = .VSYNC
	if sdl.WindowSupportsGPUPresentMode(_context.gpu_device, _context.window, .IMMEDIATE) {
		present_mode = .IMMEDIATE
	} else if sdl.WindowSupportsGPUPresentMode(_context.gpu_device, _context.window, .MAILBOX) {
		present_mode = .MAILBOX
	}

	_ = sdl.SetGPUSwapchainParameters(_context.gpu_device, _context.window, .SDR, present_mode);

	// Setup sdl.gp
	gp.Setup({
		window     = _context.window,
		gpu_device = _context.gpu_device,
	})

	// Setup samples

	sample_rect_setup()
	sample_primitive_setup()
	sample_blend_setup()
	sample_sprite_setup()
	sample_load_images_setup()

	sdl.srand(0)

	return .CONTINUE
}

app_iterate :: proc "c" (appstate: rawptr) -> sdl.AppResult {
	context = runtime.default_context()

	// Acquire a command buffer for the current frame
	cmd_buffer := sdl.AcquireGPUCommandBuffer(_context.gpu_device)

	gp.Begin(WINDOW_WIDTH, WINDOW_HEIGHT)

	{
		gp.SetColor({0, 0, 0, 255})
		gp.Clear()

		switch (_current_test) {
		case .RECT:        sample_rect_render(DELTA_TIME_MS)
		case .PRIMITIVE:   sample_primitive_render(DELTA_TIME_MS)
		case .SPRITE:      sample_sprite_render(DELTA_TIME_MS)
		case .BLEND:       sample_blend_render(DELTA_TIME_MS)
		case .LOAD_IMAGES: sample_load_images_render(DELTA_TIME_MS)
		}

		// Acquire the swapchain texture for the current frame
		swapchain_texture: ^sdl.GPUTexture
		_ = sdl.WaitAndAcquireGPUSwapchainTexture(
			cmd_buffer, _context.window, &swapchain_texture, nil, nil)

		gp.Flush(cmd_buffer, swapchain_texture)
	}

	gp.End()
	_ = sdl.SubmitGPUCommandBuffer(cmd_buffer)

	sdl.Delay(DELTA_TIME_MS)

	free_all(context.temp_allocator)

	return .CONTINUE
}

app_event :: proc "c" (appstate: rawptr, event: ^sdl.Event) -> sdl.AppResult {
	context = runtime.default_context()

	#partial switch event.type {
	case .WINDOW_CLOSE_REQUESTED:
		return .SUCCESS
	case .QUIT:
		return .SUCCESS
	case .KEY_DOWN:
		switch event.key.key {
		case sdl.K_LEFT:  _current_test = Sample_Type((int(_current_test) - 1) %% int(max(Sample_Type)))
		case sdl.K_RIGHT: _current_test = Sample_Type((int(_current_test) + 1) %% int(max(Sample_Type)))
		}
	}

	return .CONTINUE
}

app_quit :: proc "c" (appstate: rawptr, result: sdl.AppResult) {
	context = runtime.default_context()

	sample_rect_shutdown()
	sample_primitive_shutdown()
	sample_blend_shutdown()
	sample_sprite_shutdown()
	sample_load_images_shutdown()

	gp.Shutdown()

	if _context.window != nil {
		sdl.DestroyWindow(_context.window)
		_context.window = nil
	}

	if _context.gpu_device != nil {
		sdl.DestroyGPUDevice(_context.gpu_device)
		_context.gpu_device = nil
	}

	sdl.Quit()
}
