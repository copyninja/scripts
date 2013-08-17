#!/bin/sh

set -eu

# Copyright: 2013, Vasudev Kamath <kamathvasudev@gmail.com>
# License: MIT

if [ $# -lt 1 ]; then
    echo "Usage: $0 package[s]"
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
    tdir=$(mktemp -d --tmpdir=/tmp)
    cp $pkgpath $tdir
    echo $tdir
}

# Function first checks if given file exists or not and if it exists
# it checks the extension of input is deb or not.
validate_package_name(){
    local package="$1"
    
    [ -f $package ] || false
    ext=$(basename $package | sed 's/.*\.//')
    [ "$ext" = "deb" ] || false
}

# Function extracts the .deb archive then checks the debian-binary
# version if its not 2.0 Currently 2.0 is only considered as supported
# format.
#
# It extracts data and control compressed archives to respective
# directory.
extract_archive(){
    archive="$1"
    ar_extracted=$(ar xv $(basename $archive) | awk '{ print $3}')
    for file in $ar_extracted; do
	if [ "$file" != "debian-binary" ] ; then
	    dirpart=$(echo $file | sed 's/\.tar.*//')
	    mkdir $dirpart
	    tar -C "$dirpart" -xaf $file
	else
	    [ $(cat "$file") != "2.0" ] && (echo "Format of Debian archive is not supported!" && exit 2)
	fi
    done
}

# Function checks if copyright file exists at usr/share/doc/$package/
# and prints appropriate statement to output
verify_copyright(){
    local pkg="$1"
    local copyright_file=$(find data -name copyright -print)

    if [ "$copyright_file" = "data/usr/share/doc/$package/copyright" ]; then
	echo "copyright for $pkg [Found]"
    else
	echo "copright for $pkg [Not Found]" 
    fi
}

# Function parses control information of package and prints the
# package version.
print_version() {
    local pkg="$1"
    local version=$(grep -e "^Version:" control/control | sed 's/^Version:\s//')
    echo "$pkg version $version"
}

# Lets iterate over all command line arguments.
for debpkg in "$@"; do
    # check if we got all Deb packages
    validate_package_name $debpkg
    
    # create work space for the script
    tdir=$(create_tmp_workspace $debpkg)

    # go to the workspace
    cd "$tdir"
    
    # process archive (.deb package)
    extract_archive $debpkg

    package=$(basename $debpkg|awk -F"_" '{ print $1}')
    echo --------------------------------------------------
    verify_copyright $package
    print_version $package
    echo --------------------------------------------------

    cd $CURDIR
    rm -rf $tdir
done
    
