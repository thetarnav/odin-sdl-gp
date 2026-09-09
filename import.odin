package sdl_gp

USE_SYSTEM :: #config(SDL_GP_SYSTEM, false)

when USE_SYSTEM {
	when ODIN_OS == .Windows {LIB_PATH :: "system:SDL3_gp.lib"}
	else                     {LIB_PATH :: "system:SDL3_gp"}
} else {
	when ODIN_OS == .Windows {LIB_PATH :: "lib/SDL3_gp.lib"}
	else                     {LIB_PATH :: "lib/libSDL3_gp.a"}
}

@(export) foreign import lib {LIB_PATH}
