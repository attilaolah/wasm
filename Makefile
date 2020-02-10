TMPDIR := $(shell mktemp -d)
SRCDIR := $(TMPDIR)/src
PKGDIR := $(TMPDIR)/pkg
DEPDIR := $(TMPDIR)/dep
BUILDDIR := $(TMPDIR)/build

pkgs := \
	pkg/lz4-1.9.2.pkg.tar.xz \
	pkg/zstd-1.4.4.pkg.tar.xz

all: $(pkgs)
	@rmdir $(TMPDIR)

pkg/lz4-1.9.2.pkg.tar.xz: src/lz4-1.9.2.tar.gz
	mkdir -p "$(SRCDIR)"
	tar --extract \
		--file src/lz4-1.9.2.tar.gz \
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
		--file pkg/lz4-1.9.2.pkg.tar.xz \
		--directory="$(PKGDIR)/usr/local" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(PKGDIR)"

pkg/zstd-1.4.4.pkg.tar.xz: src/zstd-1.4.4.tar.zst
	mkdir -p "$(SRCDIR)" "$(BUILDDIR)"
	tar --extract \
		--file src/zstd-1.4.4.tar.zst \
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
		--file pkg/zstd-1.4.4.pkg.tar.xz \
		--directory="$(PKGDIR)" \
		--auto-compress \
		.
	rm -rf "$(SRCDIR)" "$(BUILDDIR)" "$(PKGDIR)"

src/lz4-1.9.2.tar.gz:
	mkdir -p src
	wget \
		--output-document="$(TMPDIR)/lz4-1.9.2.tar.gz" \
		"https://github.com/lz4/lz4/archive/v1.9.2.tar.gz"
	cd "$(TMPDIR)" && sha256sum --strict --check \
		"${PWD}/lz4.sum"
	mv "$(TMPDIR)/lz4-1.9.2.tar.gz" src

src/zstd-1.4.4.tar.zst:
	mkdir -p src
	wget \
		--output-document="$(TMPDIR)/zstd-1.4.4.tar.zst" \
		"https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-1.4.4.tar.zst"
	cd "$(TMPDIR)" && sha256sum --strict --check \
		"${PWD}/zstd.sum"
	mv "$(TMPDIR)/zstd-1.4.4.tar.zst" src

.PHONY: all
