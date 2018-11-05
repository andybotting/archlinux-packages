#!/bin/bash


if [ -z $1 ]; then
    PKGBUILDS=$(find -maxdepth 2 -type f -name PKGBUILD)
else
    PKGBUILDS=$1/PKGBUILD
fi

for PKG in $PKGBUILDS; do
    . $PKG
    echo $pkgname
    echo $pkgver

    # Fetch latest tag
    url=$(echo $source | sed 's/git+\(.*\)#tag.*/\1/')
    newver=$(git ls-remote --tags $url | grep -v '{}' | awk -F/ '{print $NF}' | grep -E '^(v?)[[:digit:]]{0,3}\.' | sed 's/^v//g' | sort -V | tail -n1)
    [ $? -ne 0 ] && break
    echo $newver

    if [[ $pkgver != $newver ]]; then
        echo "Updating $pkgname..."
        cd $(dirname $PKG)
        sed -i -e "s/pkgver=.*/pkgver='$newver'/g" -e "s/pkgrel=.*/pkgrel='1'/g" PKGBUILD
        git checkout master
        sudo ccm64 s
        if [ $? == 0 ]; then
            git add .
            git commit -m "Update to v${newver}-1"
        else
            echo "FAILED TO BUILD PACKAGE"
        fi
        cd ..
    fi
done
