SKIP = \

PACKAGES = \
    python-osc-lib \
    python-oslo-context \
    python-oslo-log \
    python-designateclient \
    python-yaql \
    python-muranoclient \

all: install

install:
	for package in $(PACKAGES); do \
		(cd $$package; \
        makepkg --noconfirm -iscf) \
	done

clean:
	for package in $(PACKAGES); do \
		(cd $$package && rm -fr *.pkg.tar.xz *.tar.gz *.tar.bz2 *.tgz *.part .MTREE .PKGINFO */) \
	done
