#!/bin/bash

if [ -z "$1" ]; then
    PKGBUILDS=$(find . -maxdepth 2 -type f -name PKGBUILD)
else
    PKGBUILDS=$1/PKGBUILD
fi

pkgname=''
pkgver=''
source=''

for PKG in $PKGBUILDS; do
    . $PKG
    echo -e "\e[1;32m==> \e[39mChecking package: $pkgname\e[0m"
    echo -e "\e[1;34m:: \e[39mcurrent => $pkgver\e[0m"

    # Fetch latest tag
    if [[ "$source" =~ /github.com/ ]]; then
        repo=$(echo $source | sed -e 's,.*://github.com/\([^/]*\)/\([^/]*\)/.*,\1/\2,g')
        latest=$(curl -s https://api.github.com/repos/$repo/tags | jq -r '.[].name' | grep -E '^(v?)[[:digit:]]{0,3}\.' | sed 's/^v//g' | sort -V | tail -n1)
    else
        echo -e "\e[1;31m==> ERROR:\e[39m Can't handle source: $source\e[0m"
        continue
    fi

    [ -z $latest ] && break
    echo -e "\e[1;34m:: \e[39mlatest => $latest\e[0m"

    if [[ "$pkgver" != "$latest" ]]; then
        src="https://github.com/${repo}/archive/${latest}.tar.gz"
        echo -e "\e[1;34m:: \e[39mFetching sha512sum...\e[0m"
        sha512sum=$(curl -s -L "$src" | sha512sum | awk '{print $1}')

        echo "Updating $pkgname..."
        (
            cd "$(dirname $PKG)" || exit
            git checkout master
            sed -i -e "s/pkgver=.*/pkgver='$latest'/g" -e "s/pkgrel=.*/pkgrel='1'/g" -e "s/sha512sums=('.*'/sha512sums=('$sha512sum'/g" PKGBUILD
            git add .
            git -c pager.diff=false diff --cached
            if sudo ccm64 s; then
                echo -e "\e[1;32m==>\e[39m Looks good.. SHIP IT!\e[0m"
                git commit -m "Update to v${latest}-1"
                git push
            else
                echo -e "\e[1;31m==> ERROR:\e[39m Failed to build package. Resetting.\e[0m"
                git reset --hard
            fi
        )
    fi
done
