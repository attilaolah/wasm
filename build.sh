# Build LZ4.

. /etc/profile.d/binaryen.sh
. /etc/profile.d/emscripten.sh

emcc -c \
	third_party/lz4/src/lz4.c \
	-o lz4.bc
