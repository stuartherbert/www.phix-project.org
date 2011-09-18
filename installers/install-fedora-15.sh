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
    echo "##"
    echo "## $*"
    echo "##"
    echo
}

# step 0: do we have the required permissions to run this script?
if [[ `id -u` != 0 ]]
    die "*** Sorry, you must be root to run this script"
fi

# step 1: dependencies to install via yum
#
# some of these are our dependencies, but most are dependencies
# for the tools that we rely on
intro "Installing required system packages"

yum install gcc php-devel php-pear php-xml php-pdo php-process php-pecl-xdebug php-pecl-imagick php-pecl-ncurses || die "yum install failed; please investigate why"

# step 2: dependencies we need to install ourselves
#
# this makes it a lot easier to get all the required dependencies onto
# the machine
intro "Installing additional PHP modules from PECL"

for x in proctitle ; do
    pecl install $x || die "pecl component build failed; please investigate why"
    echo "extension=$x.so" > /etc/php.d/$x.ini
done

# step 3: install packages via PEAR-installer
#
# everything else was simply to make this step possibe
intro "Installing phix4componentdev from pear.phix-project.org"

pear channel-discover pear.phix-project.org || die "Unable to find pear.phix-project.org"
pear -D auto_discover=1 install -Ba phix/phix4componentdev || die "Unable to install phix4componentdev"

# vim: set tabstop=4 shiftwidth=4 expandtab:
