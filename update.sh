#!/bin/bash


if [ -z $1 ]; then
    PKGBUILDS=$(find . -name PKGBUILD)
else
    PKGBUILDS=$1/PKGBUILD
fi

for PKG in $PKGBUILDS; do
    . $PKG
    echo $pkgname
    echo $pkgver

    # Fetch latest tag
    url=$(echo $source | sed 's/git+\(.*\)#tag.*/\1/')
    newver=$(git ls-remote --tags $url | grep -v '{}' | awk -F/ '{print $NF}' | grep -E '^(v?)[[:digit:]]{0,3}\.' | sort -V | tail -n1 | sed 's/^v//g')
    echo $newver

    if [[ $pkgver != $newver ]]; then
        echo "Updating $pkgname..."
        cd $(dirname $PKG)
        sed -i -e "s/pkgver=.*/pkgver='$newver'/g" -e "s/pkgrel=.*/pkgrel='1'/g" PKGBUILD
        makepkg --printsrcinfo > .SRCINFO
        git checkout master
        #git add PKGBUILD .SRCINFO
        #git commit -m "Update to v${newver}"
        cd ..
    fi
done
