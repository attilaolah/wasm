build_dir="${PWD}/build"

# Build LZ4.

. /etc/profile.d/binaryen.sh
. /etc/profile.d/emscripten.sh

pushd third_party/lz4
emcc -c src/lz4.c -o lz4.bc
popd

# Build zlib.

pushd third_party/zlib
emconfigure ./configure --static --prefix=${build_dir}
emcmake make
emcmake make install
popd
