#!/bin/bash

message() {
    echo -e "\e[1;32m==>\e[39m ${1}\e[0m"
}

info() {
    echo -e "\e[1;34m::\e[39m ${1}\e[0m"
}

error() {
    echo -e "\e[1;31m==> ERROR:\e[39m ${1}\e[0m"
}

if [ -z "$1" ]; then
    echo "Please provide a package name"
    exit 1
else
    NAME=$1
fi

if [ -d $NAME ]; then
    echo "Package already exists"
    exit 1
fi

message "Creating initial package for: $NAME"
git submodule add -f ssh://aur@aur.archlinux.org/$NAME

cd $NAME

PYMODULE="${NAME#python-}"

info "Creating PKGBUILD..."
cat > PKGBUILD << EOF
# Maintainer: Andy Botting <andy@andybotting.com>

pkgname=python-$PYMODULE
pkgver=
pkgrel=1
pkgdesc=''
arch=('any')
url="http://docs.openstack.org/$PYMODULE"
license=('Apache')
depends=('python-pbr' 'python-six' 'python-keystoneauth1'
         'python-osc-lib')
checkdepends=('python-oslotest' 'python-openstackclient' 'python-stestr'
              )
source=("https://github.com/openstack/$PYMODULE/archive/\$pkgver.tar.gz")
sha512sums=('')

export PBR_VERSION=\$pkgver

build() {
  cd $PYMODULE-\$pkgver
  python setup.py build
}

check() {
  cd $PYMODULE-\$pkgver
  stestr run
}

package() {
  cd $PYMODULE-\$pkgver
  python setup.py install --root="\$pkgdir" --optimize=1
}

# vim:set ts=2 sw=2 et:
EOF

info "Creating gitignore..."
cat > .gitignore << EOF
*
!.gitignore
!.SRCINFO
!PKGBUILD
EOF

info "Adding git hooks..."
cp ../.hooks/* $(git rev-parse --git-dir)/hooks/
