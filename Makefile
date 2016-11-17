DEPS = \
    python-heatclient \
    python2-heatclient \
    python-swiftclient \
    python2-swiftclient \
    python-neutronclient \
    python2-neutronclient

PACKAGES = \
    python-oslo-context \
    python-oslo-log \
    python-designateclient \
    python-yaql \
    python-reno \
    python-muranoclient \
    python-manilaclient \
    python-mistralclient \
    python-troveclient \
    python-ironicclient \
    python-magnumclient \
    python-munch \
    python-shade

all: deps install

deps:
	pacaur --noedit --noconfirm --needed -Sa $(DEPS)

install:
	for package in $(PACKAGES); do \
		(cd $$package; \
        makepkg --noconfirm -iscf) \
	done

clean:
	for package in $(PACKAGES); do \
		(cd $$package && rm -fr *.pkg.tar.xz *.tar.gz *.tar.bz2 *.tgz *.part .MTREE .PKGINFO */) \
	done
