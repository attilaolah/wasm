TMPDIR := $(shell mktemp -d)

pkgs = \
	pkg/lz4.pkg.tar.xz

pkg/lz4.pkg.tar.xz: src/lz4-1.9.2.tar.gz
	mkdir -p "$(TMPDIR)/build" pkg
	tar --extract \
		--file src/lz4-1.9.2.tar.gz \
		--directory="$(TMPDIR)" \
		--strip-components=1
	emcmake $(MAKE) \
		--directory="$(TMPDIR)" \
		DESTDIR=$(TMPDIR)/install \
		BUILD_STATIC=yes \
		BUILD_SHARED=no \
		all install
	tar --create \
		--file pkg/lz4.pkg.tar.xz \
		--directory=$(TMPDIR)/install/usr/local \
		--auto-compress \
		.
	rm -rf "$(TMPDIR)"/*

src/lz4-1.9.2.tar.gz:
	mkdir -p src
	wget \
		--output-document="$(TMPDIR)/lz4-1.9.2.tar.gz" \
		"https://github.com/lz4/lz4/archive/v1.9.2.tar.gz"
	cd "$(TMPDIR)" && sha256sum --strict --check \
		"${PWD}/lz4.sum"
	mv "$(TMPDIR)/lz4-1.9.2.tar.gz" src
	rm -rf "$(TMPDIR)"/*

all: $(pkgs)
	rmdir $(TMPDIR)

.PHONY: all
