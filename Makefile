TMPDIR := $(shell mktemp -d)
SRCDIR := $(TMPDIR)/src
PKGDIR := $(TMPDIR)/pkg
DEPDIR := $(TMPDIR)/dep
BUILDDIR := $(TMPDIR)/build

include versions.mk

fftw_pkg := pkg/fftw-$(fftw_version).pkg.tar.xz
fftw_src := src/fftw-$(fftw_version).tar.gz
fftw_url := "http://www.fftw.org/$(notdir $(fftw_src))"

libjpeg_turbo_pkg := pkg/libjpeg-turbo-$(libjpeg_turbo_version).pkg.tar.xz
libjpeg_turbo_src := src/libjpeg-turbo-$(libjpeg_turbo_version).tar.gz
libjpeg_turbo_url := "https://download.sourceforge.net/libjpeg-turbo/$(notdir $(libjpeg_turbo_src))"

liblzma_pkg := pkg/liblzma-$(liblzma_version).pkg.tar.xz
liblzma_src := src/liblzma-$(liblzma_version).tar.gz
liblzma_url := "https://tukaani.org/xz/xz-$(liblzma_version).tar.gz"

libpano13_pkg := pkg/libpano13-$(libpano13_version).pkg.tar.xz
libpano13_src := src/libpano13-$(libpano13_version).tar.gz
libpano13_url := "https://download.sourceforge.net/panotools/$(notdir $(libpano13_src))"

libpng_pkg := pkg/libpng-$(libpng_version).pkg.tar.xz
libpng_src := src/libpng-$(libpng_version).tar.xz
libpng_url := "https://download.sourceforge.net/libpng/$(notdir $(libpng_src))"

libtiff_pkg := pkg/libtiff-$(libtiff_version).pkg.tar.xz
libtiff_src := src/libtiff-$(libtiff_version).tar.gz
libtiff_url := "https://download.osgeo.org/libtiff/tiff-$(libtiff_version).tar.gz"

lz4_pkg := pkg/lz4-$(lz4_version).pkg.tar.xz
lz4_src := src/lz4-$(lz4_version).tar.gz
lz4_url := "https://github.com/lz4/lz4/archive/v$(lz4_version).tar.gz"

zlib_pkg := pkg/zlib-$(zlib_version).pkg.tar.xz
zlib_src := src/zlib-$(zlib_version).tar.gz
zlib_url := "http://downloads.sourceforge.net/libpng/$(notdir $(zlib_src))"

zstd_pkg := pkg/zstd-$(zstd_version).pkg.tar.xz
zstd_src := src/zstd-$(zstd_version).tar.zst
zstd_url := "https://github.com/facebook/zstd/releases/download/v$(zstd_version)/$(notdir $(zstd_src))"

vigra_pkg := pkg/vigra-$(vigra_version).pkg.tar.xz
vigra_src := src/vigra-$(vigra_version).tar.gz
vigra_url := "https://github.com/ukoethe/vigra/releases/download/Version-$(shell tr . - <<< $(vigra_version))/vigra-$(vigra_version)-src.tar.gz"

libpano13_deps := $(libjpeg_turbo_pkg) $(libpng_pkg) $(libtiff_pkg) $(zlib_pkg)
libpng_deps := $(zlib_pkg)
libtiff_deps := $(libjpeg_turbo_pkg) $(liblzma_pkg) $(zlib_pkg) $(zstd_pkg)
vigra_deps := $(libjpeg_turbo_pkg) $(libpng_pkg) $(libtiff_pkg) $(zlib_pkg)

pkgs := \
	$(fftw_pkg) \
	$(libjpeg_turbo_pkg) \
	$(liblzma_pkg) \
	$(libpano13_pkg) \
	$(libpng_pkg) \
	$(libtiff_pkg) \
	$(lz4_pkg) \
	$(zlib_pkg) \
	$(zstd_pkg) \
	$(vigra_pkg)

all: $(pkgs)
	@rmdir $(TMPDIR)

$(fftw_pkg): $(fftw_src)
	mkdir -p "$(SRCDIR)" "$(BUILDDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	emcmake cmake \
		-DCMAKE_INSTALL_PREFIX:PATH="$(PKGDIR)" \
		-DDISABLE_FORTRAN:BOOL=ON \
		-DBUILD_TESTS:BOOL=OFF \
		-DBUILD_SHARED_LIBS:BOOL=OFF \
		-S "$(SRCDIR)" \
		-B "$(BUILDDIR)"
	emcmake $(MAKE) \
		--directory=$(BUILDDIR) \
		all install
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(BUILDDIR)" "$(PKGDIR)"

$(libjpeg_turbo_pkg): $(libjpeg_turbo_src)
	mkdir -p "$(SRCDIR)" "$(BUILDDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	emcmake cmake \
		-DCMAKE_INSTALL_PREFIX:PATH="$(PKGDIR)" \
		-DWITH_TURBOJPEG=0 \
		-DWITH_JAVA=0 \
		-DENABLE_STATIC=1 \
		-DENABLE_SHARED=0 \
		-S "$(SRCDIR)" \
		-B "$(BUILDDIR)"
	emcmake $(MAKE) \
		--directory=$(BUILDDIR) \
		all install
	rm -rf "$(PKGDIR)/bin" "$(PKGDIR)/share"
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(BUILDDIR)" "$(PKGDIR)"

$(liblzma_pkg): $(liblzma_src)
	mkdir -p "$(SRCDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	cd "$(SRCDIR)" && ./autogen.sh
	cd "$(SRCDIR)" && emconfigure ./configure \
		--prefix="$(PKGDIR)" \
		--disable-doc \
		--disable-lzma-links \
		--disable-lzmadec \
		--disable-lzmainfo \
		--disable-scripts \
		--disable-shared \
		--disable-xz \
		--disable-xzdec \
		--enable-small
	emcmake $(MAKE) \
		--directory=$(SRCDIR) \
		all install
	rmdir "$(PKGDIR)/bin"
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(PKGDIR)"

$(libpano13_pkg): $(libpano13_src) $(libpano13_deps)
	mkdir -p "$(SRCDIR)" "$(DEPDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	for dep in $(filter pkg/%,$^); do \
		tar --extract --file=$$dep --directory="$(DEPDIR)"; \
	done
	patch --directory="$(SRCDIR)" --strip=0 < libpano13.patch
	cd "$(SRCDIR)" && emconfigure ./bootstrap \
		--prefix="$(PKGDIR)" \
		--with-jpeg="$(DEPDIR)" \
		--with-png="$(DEPDIR)" \
		--with-tiff="$(DEPDIR)" \
		--with-zlib="$(DEPDIR)" \
		--without-java \
		--enable-static=yes \
		--enable-shared=no
	emcmake $(MAKE) \
		--directory=$(SRCDIR) \
		all install
	rm -rf "$(PKGDIR)/bin" "$(PKGDIR)/share"
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(DEPDIR)" "$(PKGDIR)"

$(libpng_pkg): $(libpng_src) $(libpng_deps)
	mkdir -p "$(SRCDIR)" "$(DEPDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	for dep in $(filter pkg/%,$^); do \
		tar --extract --file=$$dep --directory="$(DEPDIR)"; \
	done
	cd "$(SRCDIR)" && emconfigure ./configure \
		--prefix="$(PKGDIR)" \
		--with-zlib-prefix="$(DEPDIR)" \
		--enable-static=yes \
		--enable-shared=no
	emcmake $(MAKE) \
		--directory=$(SRCDIR) \
		INCLUDES="-I$(DEPDIR)/include" \
		all install
	rm -rf "$(PKGDIR)/bin" "$(PKGDIR)/share"
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(DEPDIR)" "$(PKGDIR)"

$(libtiff_pkg): $(libtiff_src) $(libtiff_deps)
	mkdir -p "$(SRCDIR)" "$(DEPDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	for dep in $(filter pkg/%,$^); do \
		tar --extract --file=$$dep --directory="$(DEPDIR)"; \
	done
	cd "$(SRCDIR)" && ./autogen.sh
	cd "$(SRCDIR)" && emconfigure ./configure \
		--prefix="$(PKGDIR)" \
		--with-jpeg-lib-dir="$(DEPDIR)/lib" \
		--with-jpeg-include-dir="$(DEPDIR)/include" \
		--with-lzma-lib-dir="$(DEPDIR)/lib" \
		--with-lzma-include-dir="$(DEPDIR)/include" \
		--with-zlib-lib-dir="$(DEPDIR)/lib" \
		--with-zlib-include-dir="$(DEPDIR)/include" \
		--with-zstd-lib-dir="$(DEPDIR)/lib" \
		--with-zstd-include-dir="$(DEPDIR)/include" \
		--enable-static=yes \
		--enable-shared=no
	emcmake $(MAKE) \
		--directory=$(SRCDIR) \
		all install
	rm -rf "$(PKGDIR)/bin" "$(PKGDIR)/share"
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(DEPDIR)" "$(PKGDIR)"

$(lz4_pkg): $(lz4_src)
	mkdir -p "$(SRCDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	emcmake $(MAKE) \
		--directory="$(SRCDIR)" \
		DESTDIR=$(PKGDIR) \
		BUILD_STATIC=yes \
		BUILD_SHARED=no \
		all install
	rm -rf \
		"$(PKGDIR)/usr/local/bin" \
		"$(PKGDIR)/usr/local/share"
	mkdir -p pkg
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)/usr/local" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(PKGDIR)"

$(zlib_pkg): $(zlib_src)
	mkdir -p "$(SRCDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	cd "$(SRCDIR)" && emconfigure ./configure \
		--prefix="$(PKGDIR)" \
		--static
	emcmake $(MAKE) \
		--directory="$(SRCDIR)" \
		all install
	rm -rf "$(PKGDIR)/share"
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(PKGDIR)"

$(zstd_pkg): $(zstb_src)
	mkdir -p "$(SRCDIR)" "$(BUILDDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	emcmake cmake \
		-DCMAKE_INSTALL_PREFIX:PATH="$(PKGDIR)" \
		-DZSTD_BUILD_PROGRAMS=0 \
		-DZSTD_BUILD_STATIC=1 \
		-DZSTD_BUILD_SHARED=0 \
		-S "$(SRCDIR)/build/cmake" \
		-B "$(BUILDDIR)"
	emcmake $(MAKE) \
		--directory="$(BUILDDIR)" \
		all install
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(BUILDDIR)" "$(PKGDIR)"

$(vigra_pkg): $(vigra_src) $(vigra_deps)
	mkdir -p "$(SRCDIR)" "$(BUILDDIR)" "$(DEPDIR)"
	tar --extract --file=$< --directory="$(SRCDIR)" --strip-components=1
	for dep in $(filter pkg/%,$^); do \
		tar --extract --file=$$dep --directory="$(DEPDIR)"; \
	done
	patch --directory="$(SRCDIR)" --strip=0 < vigra.patch
	emcmake cmake \
		-DCMAKE_INSTALL_PREFIX:PATH="$(PKGDIR)" \
		-DDEPENDENCY_SEARCH_PREFIX:PATH="$(DEPDIR)" \
		-DJPEG_INCLUDE_DIR:PATH="$(DEPDIR)/include" \
		-DJPEG_LIBRARY:PATH="$(DEPDIR)/lib/libjpeg.a" \
		-DPNG_PNG_INCLUDE_DIR:PATH="$(DEPDIR)/include" \
		-DPNG_LIBRARY:PATH="$(DEPDIR)/lib/libpng.a" \
		-DTIFF_INCLUDE_DIR:PATH="$(DEPDIR)/include" \
		-DTIFF_LIBRARY:PATH="$(DEPDIR)/lib/libtiff.a" \
		-DZLIB_INCLUDE_DIR:PATH="$(DEPDIR)/include" \
		-DZLIB_LIBRARY:PATH="$(DEPDIR)/lib/libz.a" \
		-DWITH_VIGRANUMPY:BOOL=OFF \
		-DWITH_HDF5:BOOL=OFF \
		-DCMAKE_CXX_FLAGS="-std=c++11" \
		-DVIGRA_STATIC_LIB:BOOL=ON \
		-S "$(SRCDIR)" \
		-B "$(BUILDDIR)"
	emcmake $(MAKE) \
		--directory="$(BUILDDIR)" \
		all install
	rm -rf "$(PKGDIR)/bin"
	tar --create \
		--file=$@ \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(BUILDDIR)" "$(DEPDIR)" "$(PKGDIR)"

$(fftw_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(fftw_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(libjpeg_turbo_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(libjpeg_turbo_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(liblzma_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(liblzma_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(libpano13_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(libpano13_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(libpng_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(libpng_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(libtiff_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(libtiff_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(lz4_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(lz4_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(zlib_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(zlib_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(zstd_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(zstd_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

$(vigra_src):
	mkdir -p $(@D)
	wget --output-document="$(TMPDIR)/$(@F)" $(vigra_url)
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

.PHONY: all
