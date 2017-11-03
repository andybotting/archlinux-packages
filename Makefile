KEYS = \
    9A2D24A504D1E9F8 \

CHROOTDEPS = \
    python2-dulwich \
    python-semantic-version \
    python2-semantic-version \
    python-neutronclient \
    python-os-testr

DEPS = \
    python-dulwich \
    python-semantic-version \
    python2-semantic-version \
    python-neutronclient \
    python2-neutronclient \
    python-os-testr \
    python2-os-testr \

PACKAGES = \
    python-oslo-concurrency \
    python-tempest \
    python-oslo-context \
    python-oslo-log \
    python-heatclient \
    python-designateclient \
    python-ceilometerclient \
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

update:
	git submodule foreach git pull origin master

reset:
	git submodule foreach git reset --hard origin/master

keys:
	for key in $(KEYS); do \
		if ! gpg --list-keys $$key >/dev/null 2>/dev/null; then \
			gpg --recv-key $$key; \
		fi \
	done

chrootkeys:
	for key in $(KEYS); do \
		if ! sudo gpg --list-keys $$key >/dev/null 2>/dev/null; then \
			sudo gpg --recv-key $$key; \
		fi \
	done

chrootdeps:
	mkdir -p .deps; \
	cd .deps; \
	for dep in $(CHROOTDEPS); do \
		(curl -s -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/$$dep.tar.gz && \
		tar xf $$dep.tar.gz && \
		cd $$dep && \
		sudo ccm64 s && \
        cd .. && rm -fr $$dep*) \
	done

chrootbuild:
	for package in $(PACKAGES); do \
		(cd $$package; \
		sudo ccm64 s || exit 1) \
	done

chrootclean:
	sudo ccm64 d


deps:
	pacaur -Sy
	pacaur --noedit --noconfirm --needed -S $(DEPS)

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
		(cd $$package && rm -fr *.pkg.tar.xz *.log *.tar.gz *.tar.bz2 *.tgz *.part .MTREE .PKGINFO .testrespository */) \
	done
