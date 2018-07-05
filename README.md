ArchLinux PKGBUILDs
===================

This repo stores [all my PKGBUILDs](https://aur.archlinux.org/packages/?SeB=m&K=andybz) in the AUR.

This contains mostly OpenStack client libraries and their python dependencies.

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

Adding a new package
--------------------
Clone an empty repository from AUR
`git submodule add -f ssh://aur@aur.archlinux.org/package-name`

The add the new PKGBUILD and a copy of .gitignore.

Run `make hooks` to install the git hooks into the new package.

Then `git commit -m 'Initial version vX.X'` and `git push`.
