# Odin SDL_gp bindings

Odin bindings to [SDL_gp](https://github.com/n67094/SDL_gp).

> A minimal, high-performance 2D (g)raphics (p)ainter for `SDL3`.

## Build

The SDL_gp repository is added as a submodule at [`SDL_gp`](./SDL_gp).\
Clone with `--recurse-submodules`, or run `git submodule update --init` after clone.

To build the SDL_gp library to a static library for Odin ffi,\
run [`build.sh`](./build.sh) or [`build.bat`](./build.bat) depending on your system.

It will compile to `lib/libSDL3_gp.a` or `lib/SDL3_gp.lib`.

## Usage

If you want to jump in the right way, check out the [`example`](./example) folder.

Here is a simple example to draw a red rectangle:

```odin
import sdl "vendor:sdl3"
import gp "./odin-sdl-gp"

// Acquire a command buffer for the current frame
cmd_buffer := sdl.AcquireGPUCommandBuffer(device)

// Begin a new frame
gp.Begin(WINDOW_WIDTH, WINDOW_HEIGHT)
{
    // Clear the screen to black.
    gp.SetColor({0, 0, 0, 255})
    gp.Clear()

    // Draw a red filled rectangle.
    gp.SetColor({255, 0, 0, 255})
    gp.DrawRectFilled({10, 10, 100, 100})

    // The caller can render to a swapchain or to a texture.
    // Here we render to the swapchain.
    swapchain_texture: ^sdl.GPUTexture
    _ = sdl.WaitAndAcquireGPUSwapchainTexture(
        cmd_buffer, window, &swapchain_texture, nil, nil)

    gp.Flush(cmd_buffer, swapchain_texture)
}
gp.End()
_ = sdl.SubmitGPUCommandBuffer(cmd_buffer)

sdl.Delay(DELTA_TIME_MS)
```

## License

[MIT License](./LICENSE.txt)
