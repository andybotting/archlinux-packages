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
        sed -i "s/pkgver=.*/pkgver='$newver'/g" $PKG
    fi
done
