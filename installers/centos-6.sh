#!/bin/bash
#
# install-centos-6.sh
#           installation script for phix on centos 6.x
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

pecl_module() {
    local pecl_flags=""
    if [[ -n $2 ]] ; then
        pecl_flags="-D preferred_state=$2"
    fi

    pecl list $1 > /dev/null 2>&1
    if [[ $? == 1 ]] ; then
        pecl $pecl_flags install $1 || die "pecl component build failed; please investigate why"
        echo "extension=$1.so" > /etc/php.d/$1.ini
    else
        echo "PECL module $1 already installed ... skipping"
    fi
}

# step 0: do we have the required permissions to run this script?
#
# we must be root, otherwise we cannot install system packages
if [[ `id -u` != 0 ]] ; then
    die "*** Sorry, you must be root to run this script"
fi

# step 1: do we have PHP 5.3 or later installed?
#
# no point trying to install onto a machine that either does not have
# PHP at all, or does not have a version that supports our code
intro "Checking your PHP version ..."
which php > /dev/null 2>&1
if [[ $? != 0 ]] ; then
    yum install -y php-cli || die "Unable to install PHP CLI on your system; please investigate why"
fi
php -v | head -n 1 | grep -E 'PHP 5.[34].|PHP [6789].' > /dev/null 2>&1
if [[ $? != 0 ]]; then
    die "Your installed version of PHP CLI is too old; phix requires PHP 5.3 or later"
fi

# step 2: dependencies to install via yum
#
# some of these are our dependencies, but most are dependencies
# for the tools that we rely on
intro "Installing required system packages"

yum install -y gcc make php-devel php-pear php-xml php-pdo php-process php-pecl-xdebug php-pecl-imagick php-pecl-ncurses || die "yum install failed; please investigate why"

# step 3: we need to upgrade PEAR
#
# centos installs an older version of the PEAR installer
intro "Upgrading PEAR installer to latest version"

pear clear-cache
pear upgrade pear/pear

# step 4: dependencies we need to install ourselves
#
# this makes it a lot easier to get all the required dependencies onto
# the machine
intro "Installing additional PHP modules from PECL"

pecl_module proctitle alpha

# step 5: install packages via PEAR-installer
#
# everything else was simply to make this step possibe
intro "Using PEAR to install phix/phix4componentdev from pear.phix-project.org"

# first rule of PEAR-installer: clear the cache

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
