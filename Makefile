KEYS = \
    9A2D24A504D1E9F8 \

DEPS = \
    python-dulwich \
    python2-dulwich \
    python-semantic-version \
    python2-semantic-version \
    python-os-testr \
    python2-os-testr

PACKAGES = \
    python-tempest \
    python-reno \
    python-osprofiler \
    python-neutronclient \
    python-heatclient \
    python-designateclient \
    python-ceilometerclient \
    python-yaql \
    python-muranopkgcheck \
    python-muranoclient \
    python-manilaclient \
    python-mistralclient \
    python-troveclient \
    python-ironicclient \
    python-magnumclient \
    python-saharaclient \
    python-barbicanclient \
    python-shade \
    python-futurist \
    python-gnocchiclient

all: keys deps build install

hooks:
	for package in $(PACKAGES); do \
		cd $$package; \
        cp -v ../.hooks/* $$(git rev-parse --git-dir)/hooks/ ;\
		cd ..; \
	done
update:
	git submodule foreach 'git pull origin master; git checkout master'

reset:
	git submodule foreach 'git reset --hard origin/master; git checkout master'

push:
	git submodule foreach 'git push'

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
	for dep in $(DEPS); do \
		(curl -s -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/$$dep.tar.gz && \
		tar xf $$dep.tar.gz && \
		cd $$dep && \
		sudo ccm64 S && \
        cd .. && rm -fr $$dep*) \
	done

chrootbuild:
	for package in $(PACKAGES); do \
		cd $$package; \
		sudo ccm64 S || exit $$?; \
		cd ..; \
	done

chrootclean:
	sudo ccm64 d


deps:
	pacaur -Sy
	pacaur --noedit --noconfirm --needed -S $(DEPS)

build:
	for package in $(PACKAGES); do \
		cd $$package; \
		makepkg --noconfirm -sf || exit $$?; \
		cd ..; \
	done

install:
	for package in $(PACKAGES); do
		cd $$package; \
		makepkg --noconfirm -isc || exit $$?; \
		cd ..; \
	done

clean:
	for package in $(PACKAGES); do \
		(cd $$package && rm -fr *.pkg.tar.xz *.log *.tar.gz *.tar.bz2 *.tgz *.part .MTREE .PKGINFO .testrespository */) \
	done
