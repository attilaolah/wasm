TMPDIR := $(shell mktemp -d)
SRCDIR := $(TMPDIR)/src
PKGDIR := $(TMPDIR)/pkg
DEPDIR := $(TMPDIR)/dep
BUILDDIR := $(TMPDIR)/build

pkgs := \
	pkg/libjpeg-turbo-2.0.4.pkg.tar.xz \
	pkg/liblzma-5.2.4.pkg.tar.xz \
	pkg/libpano13-2.9.19.pkg.tar.xz \
	pkg/libpng-1.6.37.pkg.tar.xz \
	pkg/libtiff-4.1.0.pkg.tar.xz \
	pkg/lz4-1.9.2.pkg.tar.xz \
	pkg/zlib-1.2.11.pkg.tar.xz \
	pkg/zstd-1.4.4.pkg.tar.xz

all: $(pkgs)
	@rmdir $(TMPDIR)

pkg/libjpeg-turbo-2.0.4.pkg.tar.xz: src/libjpeg-turbo-2.0.4.tar.gz
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

pkg/liblzma-5.2.4.pkg.tar.xz: src/liblzma-5.2.4.tar.gz
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

pkg/libpano13-2.9.19.pkg.tar.xz: src/libpano13-2.9.19.tar.gz pkg/libjpeg-turbo-2.0.4.pkg.tar.xz pkg/libpng-1.6.37.pkg.tar.xz pkg/libtiff-4.1.0.pkg.tar.xz pkg/zlib-1.2.11.pkg.tar.xz
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

pkg/libpng-1.6.37.pkg.tar.xz: src/libpng-1.6.37.tar.xz pkg/zlib-1.2.11.pkg.tar.xz
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

pkg/libtiff-4.1.0.pkg.tar.xz: src/libtiff-4.1.0.tar.gz pkg/libjpeg-turbo-2.0.4.pkg.tar.xz pkg/liblzma-5.2.4.pkg.tar.xz pkg/zlib-1.2.11.pkg.tar.xz pkg/zstd-1.4.4.pkg.tar.xz
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

pkg/lz4-1.9.2.pkg.tar.xz: src/lz4-1.9.2.tar.gz
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

pkg/zlib-1.2.11.pkg.tar.xz: src/zlib-1.2.11.tar.gz
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

pkg/zstd-1.4.4.pkg.tar.xz: src/zstd-1.4.4.tar.zst
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

src/libjpeg-turbo-2.0.4.tar.gz:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"https://download.sourceforge.net/libjpeg-turbo/libjpeg-turbo-2.0.4.tar.gz"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

src/liblzma-5.2.4.tar.gz:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"https://tukaani.org/xz/xz-5.2.4.tar.gz"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

src/libpano13-2.9.19.tar.gz:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"https://download.sourceforge.net/panotools/libpano13-2.9.19.tar.gz"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

src/libpng-1.6.37.tar.xz:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"https://download.sourceforge.net/libpng/libpng-1.6.37.tar.xz"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

src/libtiff-4.1.0.tar.gz:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"https://download.osgeo.org/libtiff/tiff-4.1.0.tar.gz"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

src/lz4-1.9.2.tar.gz:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"https://github.com/lz4/lz4/archive/v1.9.2.tar.gz"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

src/zlib-1.2.11.tar.gz:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"http://downloads.sourceforge.net/libpng/zlib-1.2.11.tar.gz"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

src/zstd-1.4.4.tar.zst:
	mkdir -p $(@D)
	wget \
		--output-document="$(TMPDIR)/$(@F)" \
		"https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.zst"
	cd "$(TMPDIR)" && sha256sum --check --strict --ignore-missing "${PWD}/sources.sum"
	mv "$(TMPDIR)/$(@F)" $(@D)

.PHONY: all
