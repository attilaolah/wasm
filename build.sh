build_dir="${PWD}/build"

. /etc/profile.d/binaryen.sh
. /etc/profile.d/emscripten.sh

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

# Build libtiff.

pushd third_party/libtiff
./autogen.sh
emconfigure ./configure \
    --prefix=${build_dir}/libtiff \
    --with-zlib-lib-dir=${build_dir}/zlib/lib \
    --with-zlib-include-dir=${build_dir}/zlib/include \
    --with-jpeg-lib-dir=${build_dir}/libjpeg-turbo/lib \
    --with-jpeg-include-dir=${build_dir}/libjpeg-turbo/include \
    --disable-x \
    --enable-static=yes \
    --enable-shared=no
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
    --with-tiff=${build_dir}/libtiff \
    --with-zlib=${build_dir}/zlib \
    --without-java \
    --enable-static=yes \
    --enable-shared=no
emcmake make all install
popd
