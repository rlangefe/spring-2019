#!/bin/sh

top=/home/jsquyres/apps
python_top=$top/python

#############################################################################

doit() {
    logfile=$1
    shift

    echo "=== Running command: $*"
    $* |& tee $logfile
    st=${PIPESTATUS[0]}

    if test $st -ne 0; then
	echo "Command failed: $*"
	exit $st
    fi
}

doit_nolog() {
    doit /dev/null $*
}

#############################################################################
# Download the Python tarball into a clean source tree

ver=3.7.3
v=Python-$ver
prefix=$python_top/$ver

doit_nolog rm -rf $prefix/src
doit_nolog mkdir -p $prefix/src
cd $prefix/src

doit_nolog rm -rf $v.tgz $v
doit_nolog wget \
    https://www.python.org/ftp/python/$ver/$v.tgz \
    -O $prefix/src/$v.tgz
doit_nolog tar xf $prefix/src/$v.tgz
cd $v

#############################################################################
# Build configure, make, and install Python

echo "=== Configuring Python $ver..."
doit config.out ./configure \
    --with-ensurepip=install \
    --enable-shared \
    --enable-optimizations \
    --prefix=$prefix
echo "=== Making Python $ver..."
doit make.out make build_all -j 8
echo "=== Installing Python $ver..."
doit install.out make install

#############################################################################
# Setup modulefile

dir=$top/modulefiles/python
if test ! -d $dir; then
    doit_nolog mkdir -p $dir
    doit_nolog chmod 0755 $dir
fi
file=$dir/$ver
doit_nolog rm -f $file
cat > $file <<EOF
#%Module -*- tcl -*-
#
# Python modulefile
#

proc ModulesHelp { } {
   puts stderr "\tThis module adds python to the environment."
}

module-whatis   "Sets up the python environment"

append-path MANPATH $prefix/man
prepend-path PATH $prefix/bin
prepend-path LD_LIBRARY_PATH $prefix/lib
EOF

# Set default modulefile
doit_nolog rm -f $dir/.version
cat > $dir/.version <<EOF
#%Module
set ModulesVersion $ver
EOF

#############################################################################

echo "=== Python $ver installed"
exit 0
