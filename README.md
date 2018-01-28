ArchLinux PKGBUILDs
===================

This repo stores [all my PKGBUILDs](https://aur.archlinux.org/packages/?SeB=m&K=andybz) in the AUR.

This contains mostly OpenStack client libraries.

Usage
-----
`git clone --recursive-submodule`
or in an existing clone:
`git submodule update --init --recursive-submodule`.

Testing
-------
 * Install clean-chroot-manager from AUR
 * `sudo ccm64`, then update the config file generated with path you want for your chroot
 * `make chrootkeys` to set up any required gpg keys for packages that require them
 * `make chrootdeps` to install all required deps into the chroot
 * `make chrootbuild` to build all packages into the chroot
