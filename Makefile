TMPDIR := $(shell mktemp -d)
SRCDIR := $(TMPDIR)/src
PKGDIR := $(TMPDIR)/pkg
DEPDIR := $(TMPDIR)/dep
BUILDDIR := $(TMPDIR)/build

pkgs := \
	pkg/libpng-1.6.37.pkg.tar.xz \
	pkg/lz4-1.9.2.pkg.tar.xz \
	pkg/zlib-1.2.11.pkg.tar.xz \
	pkg/zstd-1.4.4.pkg.tar.xz

all: $(pkgs)
	@rmdir $(TMPDIR)

pkg/libpng-1.6.37.pkg.tar.xz: src/libpng-1.6.37.tar.xz pkg/zlib-1.2.11.pkg.tar.xz
	mkdir -p "$(SRCDIR)" "$(DEPDIR)"
	tar --extract \
		--file=src/libpng-1.6.37.tar.xz \
		--directory="$(SRCDIR)" \
		--strip-components=1
	tar --extract \
		--file=pkg/zlib-1.2.11.pkg.tar.xz \
		--directory="$(DEPDIR)"
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
		--file=pkg/libpng-1.6.37.pkg.tar.xz \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(DEPDIR)" "$(PKGDIR)"

pkg/lz4-1.9.2.pkg.tar.xz: src/lz4-1.9.2.tar.gz
	mkdir -p "$(SRCDIR)"
	tar --extract \
		--file=src/lz4-1.9.2.tar.gz \
		--directory="$(SRCDIR)" \
		--strip-components=1
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
		--file=pkg/lz4-1.9.2.pkg.tar.xz \
		--directory="$(PKGDIR)/usr/local" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(PKGDIR)"

pkg/zlib-1.2.11.pkg.tar.xz: src/zlib-1.2.11.tar.gz
	mkdir -p "$(SRCDIR)"
	tar --extract \
		--file=src/zlib-1.2.11.tar.gz \
		--directory="$(SRCDIR)" \
		--strip-components=1
	cd "$(SRCDIR)" && emconfigure ./configure \
		--prefix="$(PKGDIR)" \
		--static
	emcmake $(MAKE) \
		--directory="$(SRCDIR)" \
		all install
	rm -rf "$(PKGDIR)/share"
	tar --create \
		--file=pkg/zlib-1.2.11.pkg.tar.xz \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(PKGDIR)"

pkg/zstd-1.4.4.pkg.tar.xz: src/zstd-1.4.4.tar.zst
	mkdir -p "$(SRCDIR)" "$(BUILDDIR)"
	tar --extract \
		--file=src/zstd-1.4.4.tar.zst \
		--directory="$(SRCDIR)" \
		--strip-components=1
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
		--file=pkg/zstd-1.4.4.pkg.tar.xz \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(BUILDDIR)" "$(PKGDIR)"

src/libpng-1.6.37.tar.xz:
	mkdir -p src
	wget \
		--output-document="$(TMPDIR)/libpng-1.6.37.tar.xz" \
		"https://download.sourceforge.net/libpng/libpng-1.6.37.tar.xz"
	cd "$(TMPDIR)" && sha256sum --strict --check \
		"${PWD}/libpng.sum"
	mv "$(TMPDIR)/libpng-1.6.37.tar.xz" src

src/lz4-1.9.2.tar.gz:
	mkdir -p src
	wget \
		--output-document="$(TMPDIR)/lz4-1.9.2.tar.gz" \
		"https://github.com/lz4/lz4/archive/v1.9.2.tar.gz"
	cd "$(TMPDIR)" && sha256sum --strict --check \
		"${PWD}/lz4.sum"
	mv "$(TMPDIR)/lz4-1.9.2.tar.gz" src

src/zlib-1.2.11.tar.gz:
	mkdir -p src
	wget \
		--output-document="$(TMPDIR)/zlib-1.2.11.tar.gz" \
		"http://downloads.sourceforge.net/libpng/zlib-1.2.11.tar.gz"
	cd "$(TMPDIR)" && sha256sum --strict --check \
		"${PWD}/zlib.sum"
	mv "$(TMPDIR)/zlib-1.2.11.tar.gz" src

src/zstd-1.4.4.tar.zst:
	mkdir -p src
	wget \
		--output-document="$(TMPDIR)/zstd-1.4.4.tar.zst" \
		"https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.zst"
	cd "$(TMPDIR)" && sha256sum --strict --check \
		"${PWD}/zstd.sum"
	mv "$(TMPDIR)/zstd-1.4.4.tar.zst" src

.PHONY: all
