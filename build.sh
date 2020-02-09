build_dir="${PWD}/build"

# Build LZ4.

. /etc/profile.d/binaryen.sh
. /etc/profile.d/emscripten.sh

mkdir -p "${build_dir}/lz4"
emcc -c -o build/lz4/lz4.bc \
    third_party/lz4/src/lz4.c

# Build zlib.

pushd third_party/zlib
emconfigure ./configure \
    --prefix=${build_dir}/zlib \
    --static
emcmake make
emcmake make install
popd

# Build libpng.

pushd third_party/libpng
emconfigure ./configure \
    --prefix=${build_dir}/libpng \
    --with-zlib-prefix=${build_dir}/zlib \
    --enable-static=yes \
    --enable-shared=no
INCLUDES="-I{build_dir}/zlib/include" \
    emcmake make
emcmake install
cp third_party/libpng/png-fix-itxt.wasm ${build_dir}/libpng/bin
cp third_party/libpng/pngfix.wasm ${build_dir}/libpng/bin
popd

# Build libpano13.

if [ ! -d "/path/to/dir" ]; then
    pushd third_party
    hg clone http://hg.code.sf.net/p/panotools/libpano13
    popd
fi

pushd third_party/libpano13
emconfigure ./bootstrap \
    --prefix=${build_dir}/libpano13 \
    --without-java \
    --with-zlib=${build_dir}/zlib \
    --enable-static=yes \
    --enable-shared=no
popd
