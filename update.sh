#!/bin/bash

for PKG in $(find . -name PKGBUILD); do
    . $PKG
    echo $pkgname
    echo $pkgver

    # Fetch latest tag
    url=$(echo $source | sed 's/git+\(.*\)#tag.*/\1/')
    newver=$(git ls-remote --tags $url | grep -v '{}' | awk -F/ '{print $NF}' | grep -E '^(v?)[[:digit:]]\.' | sort -V | tail -n1 | sed 's/^v//g')
    echo $newver

    if [[ $pkgver != $newver ]]; then
        echo "Updating $pkgname..."
        cd $(dirname $PKG)
        sed -i "s/pkgver=.*/pkgver='$newver'/g" PKGBUILD
        makepkg --printsrcinfo > .SRCINFO
        git checkout master
        git add PKGBUILD .SRCINFO
        git commit -m "Update to v${newver}"
        cd ..
    fi
done
