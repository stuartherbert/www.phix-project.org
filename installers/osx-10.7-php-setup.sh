#!/bin/bash
#
# osx-10.7-php-setup.sh
#           script to setup working PHP + PEAR on OSX 10.7
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
if [[ `id -u` != 0 ]]; then
    die "*** Sorry, you must be root to run this script"
fi

# step 1: folders
#mkdir /usr/local/include
#mkdir /usr/local/bin
#mkdir /usr/local/lib
#mkdir -p /usr/local/man/man1

# step 1: setup php
#
# Apple includes PHP itself, but a little bit of extra work needs to be
# done to make it usable
intro "Setting up your copy of PHP ..."

cd /etc
cp php.ini.default php.ini || die "Unable to create /etc/php.ini"
chmod ug+w php.ini
chgrp admin php.ini
sed -e 's/^error_reporting =.*$/error_reporting = E_ALL | E_STRICT/g;' -i '' php.ini
sed -e 's/^display_errors =.*$/display_errors = On/g;' -i '' php.ini
sed -e 's/^html_errors =.*$/html_errors = On/g;' -i '' php.ini

# step 2: setup xdebug
#
# PHPUnit needs xdebug, and frankly, if you're doing development,
# you should be using xdebug!
intro "Enabling XDebug extension for PHP ..."

sed -e 's|^;\(zend_extension=.*xdebug.*\)$|\1|g;' -i '' php.ini
echo "xdebug.var_display_max_children = 999" >> php.ini
echo "xdebug.var_display_max_data = 99999" >> php.ini
echo "xdebug.var_display_max_depth = 100" >> php.ini

# step 3: setup PEAR
#
# PEAR needs installing from a local file, and then upgrading
intro "Setting up the PEAR Installer ..."

cd /usr/lib/php || die "cannot find folder /usr/lib/php"
php install-pear-nozlib.phar || die "Cannot unpack the PEAR Installer"
sed -e 's|^;include_path = ".:/php/includes"$|include_path = ".:/usr/lib/php/pear"|g;' -i '' /etc/php.ini

# I do not trust the PEAR Installer to return the right exit codes
# so we do not check whether these commands succeeded or not :)
pear channel-update pear.php.net
pecl channel-update pecl.php.net
pear upgrade-all

# step 4: compilers
#
# we need a copy of GCC from somewhere!
intro "Checking for a C compiler ..."

which gcc > /dev/null 2>&1
if [[ $? != 0 ]]; then
    echo "To complete this setup, you need to install XCode from the App Store"
else
    intro "Setup complete :)"
fi

# vim: set tabstop=4 shiftwidth=4 expandtab:
