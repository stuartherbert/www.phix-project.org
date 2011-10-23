#!/bin/bash
#
# upgrade-phix-0.14.sh
#           Script to upgrade phix to v0.14
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
        echo "extension=$1.so" > /etc/php5/conf.d/$1.ini
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

# step 1: we need to upgrade PEAR
#
# ubuntu installs an older version of the PEAR installer
intro "Upgrading PEAR installer to latest version"

pear clear-cache
pear upgrade pear/pear

# step 2: upgrade packages via PEAR-installer
#
# during testing, I found numerous problems with the PEAR Installer
# being unable to upgrade components. the only reliable way to upgrade
# is to uninstall, and re-install
intro "Using PEAR to upgrade phix/phix4componentdev from pear.phix-project.org"

# first rule of PEAR-installer: clear the cache
pear clear-cache

# during testing, I encountered problems with Pirum's channel no longer
# being registered. 
pear list-channels | grep pear.pirum-project.org > /dev/null
if [[ $? == 1 ]] ; then
    pear channel-discover pear.pirum-project.org || die "Unable to find pear.phix-project.org"
fi

# install or upgrade phix4componentdev
pear uninstall phix/phix4componentdev
pear uninstall phix/componentmanager
pear uninstall phix/componentmanagerphplibrary
pear uninstall phix/componentmanagershared
pear uninstall phix/phix
pear upgrade pirum/Pirum
pear -D auto_discover=1 install -Ba phix/phix4componentdev || die "Unable to upgrade phix/phix4componentdev ... already on latest version?"

# if we get here, job done
intro "upgrade complete :)"

# vim: set tabstop=4 shiftwidth=4 expandtab:
