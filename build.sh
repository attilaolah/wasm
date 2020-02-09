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
emcmake make all install
popd

# Build libpng.

pushd third_party/libpng
emconfigure ./configure \
    --prefix=${build_dir}/libpng \
    --with-zlib-prefix=${build_dir}/zlib \
    --enable-static=yes \
    --enable-shared=no
INCLUDES="-I${build_dir}/zlib/include" \
    emcmake make all install
popd

# Build libjpeg-turbo.

pushd third_party/libjpeg-turbo
mkdir build
cd build
emcmake cmake \
    -DCMAKE_INSTALL_PREFIX:PATH="${build_dir}/libjpeg-turbo" \
    -DWITH_JAVA=0 \
    -DWITH_TURBOJPEG=0 \
    -DENABLE_STATIC=1 \
    -DENABLE_SHARED=0 \
    ..
emcmake make all install
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
    --with-jpeg=${build_dir}/libjpeg-turbo \
    --with-png=${build_dir}/libpng \
    --with-zlib=${build_dir}/zlib \
    --without-tiff \
    --without-java \
    --enable-static=yes \
    --enable-shared=no
popd
