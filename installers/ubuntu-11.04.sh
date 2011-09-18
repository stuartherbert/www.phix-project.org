#!/bin/bash
#
# install-fedora-15.sh
#           installation script for phix on fedora 15
#
# Author    Stuart Herbert
#           (stuart@stuartherbert.com)
#
# Copyright (c) 2011 Stuart Herbert
#           Released under the new BSD license
#
# ========================================================================

die() {
    echo
    echo "** $*" >&2
    
    exit 1
}

intro() {
    echo
    echo "##"
    echo "## $*"
    echo "##"
    echo
}

# step 0: do we have the required permissions to run this script?
#
# we must be root, otherwise we cannot install system packages
if [[ `id -u` != 0 ]] ; then
    die "*** Sorry, you must be root to run this script"
fi

# step 1: dependencies to install via yum
#
# some of these are our dependencies, but most are dependencies
# for the tools that we rely on
intro "Installing required system packages"

apt-get install gcc php-devel php-pear php-xml php-pdo php-process php-pecl-xdebug php-pecl-imagick php-pecl-ncurses || die "yum install failed; please investigate why"

# step 2: dependencies we need to install ourselves
#
# this makes it a lot easier to get all the required dependencies onto
# the machine
intro "Installing additional PHP modules from PECL"

for x in proctitle ; do
    pecl list $x > /dev/null
    if [[ $? == 1 ]] ; then
        pecl install $x || die "pecl component build failed; please investigate why"
        echo "extension=$x.so" > /etc/php.d/$x.ini
    else
        echo "PECL module $x already installed ... skipping"
    fi
done

# step 3: install packages via PEAR-installer
#
# everything else was simply to make this step possibe
intro "Using PEAR to install phix/phix4componentdev from pear.phix-project.org"

# first rule of PEAR-installer: clear the cache
pear clear-cache

# register our channel, if it is not already registered
pear list-channels | grep pear.phix-project.org > /dev/null
if [[ $? == 1 ]] ; then
    pear channel-discover pear.phix-project.org || die "Unable to find pear.phix-project.org"
fi

# install or upgrade phix4componentdev
pear list phix/phix4componentdev > /dev/null
if [[ $? == 1 ]] ; then
    pear -D auto_discover=1 install -Ba phix/phix4componentdev || die "Unable to install phix/phix4componentdev"
else
    pear -D auto_discover=1 upgrade -Ba phix/phix4componentdev || die "Unable to upgrade phix/phix4componentdev ... already on latest version?"
fi

# if we get here, job done
intro "Installation complete :)"

# vim: set tabstop=4 shiftwidth=4 expandtab:
