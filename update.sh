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
    PKGBUILDS=$(find . -maxdepth 2 -type f -name PKGBUILD)
else
    PKGBUILDS=$1/PKGBUILD
fi

pkgname=''
pkgver=''
source=''

for PKG in $PKGBUILDS; do
    . $PKG
    message "Checking package: $pkgname"
    info "current => $pkgver"

    # Fetch latest tag
    if [[ "$source" =~ /github.com/ ]]; then
        repo=$(echo $source | sed -e 's,.*://github.com/\([^/]*\)/\([^/]*\)/.*,\1/\2,g')
        latest=$(curl -s https://api.github.com/repos/$repo/tags | jq -r '.[].name' | grep -E '^(v?)[[:digit:]]{0,3}\.' | sed 's/^v//g' | sort -V | tail -n1)
    else
        error "Can't handle source: $source"
        continue
    fi

    [ -z $latest ] && break
    info "latest => $latest"

    if [[ "$pkgver" != "$latest" ]]; then
        src="https://github.com/${repo}/archive/${latest}.tar.gz"
        info "Fetching sha512sum..."
        sha512sum=$(curl -s -L "$src" | sha512sum | awk '{print $1}')

        message "Updating $pkgname..."
        (
            cd "$(dirname $PKG)" || exit
            git checkout master
            sed -i -e "s/pkgver=.*/pkgver='$latest'/g" -e "s/pkgrel=.*/pkgrel='1'/g" -e "s/sha512sums=('.*'/sha512sums=('$sha512sum'/g" PKGBUILD
            git add .
            git -c pager.diff=false diff --cached
            if sudo ccm64 s; then
                message "Looks good.. SHIP IT!"
                git commit -m "Update to v${latest}-1"
                git push
            else
                error "Failed to build package. Resetting."
                git reset --hard
            fi
        )
    fi
done
