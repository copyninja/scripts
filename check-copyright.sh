#!/bin/sh

# Copyright: 2013, Vasudev Kamath <kamathvasudev@gmail.com>
# License: MIT

set -eu

if [ $# -lt 1 ]; then
    echo "Usage: $0 package[s]" >&2
    exit 2
fi

# Lets record the current directory
CURDIR=$(pwd)

# Just creates a secure tmp directory using mktemp under /tmp and
# copies the deb file to it.
# Function also echoes the tdir value so that it can be recorded for
# further use.
create_tmp_workspace() {
    local pkgpath="$1"
    tdir=$(mktemp -d)
    cp "$pkgpath" "$tdir"
    echo "$tdir"
}

# Function first checks if given file exists or not and if it exists
# it checks the extension of input is deb or not.
is_valid_file(){
    local package="$1"

    ext=$(basename "$package" | tr -d "\n" | sed 's/.*\.//')
    [ "$ext" = "deb" -a -f "$package" ]
}

# Function extracts the .deb archive then checks the content of
# debian-binary version. Currently 2.0 is only considered as supported
# format.
#
# It extracts data and control compressed archives to respective
# directory.
extract_archive(){
    local archive="$1"
    local o=$IFS
    IFS=$(echo "\n")
    local package=$(basename "$archive")
    unset IFS
    ar xv "$package" 2>&1 >/dev/null || exit 2
    for file in $(ar t "$package"); do
        if [ "$file" != "debian-binary" ] ; then
            dirpart=$(echo "$file" | sed 's/\.tar.*//')
            mkdir "$dirpart"
            tar -C "$dirpart" -xaf "$file"
        fi
    done
    IFS="$o"
}

# Function checks if copyright file exists at usr/share/doc/$package/
# and prints appropriate statement to output
verify_copyright(){
    local pkg="$1"
    local o=$IFS
    IFS=$(echo "\n")

    if [ -f "data/usr/share/doc/$package/copyright" ]; then
        echo "copyright for $pkg [Found]"
    else
        echo "copright for $pkg [Not Found]"
    fi
    unset IFS
    IFS="$o"
}

# Function parses control information of package and prints the
# package version.
print_version() {
    local pkg="$1"
    local version=$(sed -n 's/^Version:\s//p' control/control)
    echo "$pkg version $version"
}


if [ ! -x "/usr/bin/ar" ]; then
    echo "This script requires ar which is part of binutils package" >&2
    exit 2
fi

if [ ! -x "/usr/bin/xz" ]; then
    echo "xz is required for deb created by dpkg >= 1.17 it is part of
    xz-utils package" >&2
    exit 2
fi

# Lets iterate over all command line arguments.
for debpkg in "$@"; do
    # check if we got all Deb packages
    if is_valid_file "$debpkg"; then

        # create work space for the script
        tdir=$(create_tmp_workspace "$debpkg")

        # go to the workspace
        cd "$tdir"

        trap "rm -rf $tdir" 0 1 2

        # process archive (.deb package)
        extract_archive "$debpkg"

        package=$(basename "$debpkg"| tr -d "\n" | awk -F"_" '{ print $1}')
        echo "--------------------------------------------------"
        verify_copyright "$package"
        print_version "$package"
        echo "--------------------------------------------------"
    else
        echo "Given file is not a valid deb package" >&2
        exit 2
    fi
done
