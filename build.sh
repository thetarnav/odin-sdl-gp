#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HEADER="$ROOT_DIR/SDL_gp/SDL_gp.h"
INCLUDE_DIR="$ROOT_DIR/include"
LIB_DIR="$ROOT_DIR/lib"
BUILD_DIR="$ROOT_DIR/.build"

CC="${CC:-cc}"
AR="${AR:-ar}"

if [[ ! -f "$HEADER" ]]; then
	echo "error: SDL_gp header not found: $HEADER" >&2
	exit 1
fi

mkdir -p "$INCLUDE_DIR" "$LIB_DIR" "$BUILD_DIR"

# Locate SDL3.
SDL3_CFLAGS=()

if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists sdl3; then
	read -r -a SDL3_CFLAGS <<< "$(pkg-config --cflags sdl3)"
else
	if [[ -n "${SDL3_DIR:-}" ]]; then
		SDL3_CFLAGS+=("-I$SDL3_DIR/include")
	elif [[ -n "${SDL3_ROOT:-}" ]]; then
		SDL3_CFLAGS+=("-I$SDL3_ROOT/include")
	fi
fi

run_cmd() {
	local cmd=("$@")

	printf '%q ' "${cmd[@]}"
	printf '\n'

	"${cmd[@]}"
}

echo "CC:      $CC"
echo "AR:      $AR"
echo "Header:  $HEADER"

run_cmd "$CC" \
	-std=c11 \
	-O2 \
	-fPIC \
	-I"$(dirname "$HEADER")" \
	"${SDL3_CFLAGS[@]}" \
	-DSDL_GP_IMPLEMENTATION \
	-x c \
	-c "$HEADER" \
	-o "$BUILD_DIR/SDL_gp.o"

run_cmd "$AR" rcs \
	"$LIB_DIR/libSDL3_gp.a" \
	"$BUILD_DIR/SDL_gp.o"

run_cmd cp "$HEADER" "$INCLUDE_DIR/SDL_gp.h"

echo
echo "Built:"
echo "  $INCLUDE_DIR/SDL_gp.h"
echo "  $LIB_DIR/libSDL3_gp.a"
