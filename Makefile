KEYS = \
    9A2D24A504D1E9F8 # python-dulwich

DEPS = \
    python-fasteners \
    python2-fasteners \
    python-semantic-version \
    python2-semantic-version \
    python-heatclient \
    python2-heatclient \
    python-swiftclient \
    python2-swiftclient \
    python-neutronclient \
    python2-neutronclient \
    python-os-testr \
    python2-os-testr \

PACKAGES = \
    python-oslo-concurrency \
    python-tempest \
    python-oslo-context \
    python-oslo-log \
    python-designateclient \
    python-yaql \
    python-reno \
    python-muranopkgcheck \
    python-muranoclient \
    python-manilaclient \
    python-mistralclient \
    python-troveclient \
    python-ironicclient \
    python-magnumclient \
    python-saharaclient \
    python-munch \
    python-shade

all: keys deps build install

keys:
	for key in $(KEYS); do \
		if ! gpg --list-keys $$key >/dev/null 2>/dev/null; then \
			gpg --recv-key $$key; \
		fi \
	done

deps:
	pacaur -Sy
	pacaur --noedit --noconfirm --needed -Sa $(DEPS)

build:
	for package in $(PACKAGES); do \
		(cd $$package; \
		makepkg --noconfirm -sf || exit 1) \
	done

install:
	for package in $(PACKAGES); do \
		(cd $$package; \
		makepkg --noconfirm -isc || exit 1) \
	done

clean:
	for package in $(PACKAGES); do \
		(cd $$package && rm -fr *.pkg.tar.xz *.tar.gz *.tar.bz2 *.tgz *.part .MTREE .PKGINFO .testrespository */) \
	done
