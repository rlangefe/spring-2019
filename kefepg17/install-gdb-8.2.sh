#!/bin/sh

top=/home/kefepg17/apps
gdb_top=$top/gdb

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
# Download the tarball into a clean source tree

ver=8.2
v=gdb-$ver
prefix=$gdb_top/$ver

doit_nolog yum -y install wget
doit_nolog rm -rf $prefix/src
doit_nolog mkdir -p $prefix/src
cd $prefix/src

doit_nolog wget \
    http://ftp.gnu.org/gnu/gdb/$v.tar.gz \
    -O $prefix/src/$v.tgz
doit_nolog tar xf $prefix/src/$v.tgz
cd $v

#############################################################################
# Build configure, make, and install gdb

# install make and gcc8
doit_nolog yum -y install make  
doit_nolog yum -y install centos-release-scl
doit_nolog yum -y install devtoolset-8-gcc devtoolset-8-gcc-c++
source /opt/rh/devtoolset-8/enable

# symlink makeinfo to a no-op to avoid problems with documentation generation

ln -s /usr/bin/true makeinfo
export PATH=${PWD}:${PATH}

echo "=== Configuring gdb $ver..."
doit config.out ./configure \
    --prefix=$prefix
echo "=== Making gdb $ver..."
doit make.out make -j 4 
echo "=== Installing gdb $ver..."
doit makeinstall.out make install

#############################################################################
# Setup modulefile

dir=$top/modulefiles/gdb
if test ! -d $dir; then
    doit_nolog mkdir -p $dir
    doit_nolog chmod 0755 $dir
fi
file=$dir/$ver
doit_nolog rm -f $file
cat > $file <<EOF
#%Module -*- tcl -*-
#
# gdb modulefile
#

proc ModulesHelp { } {
   puts stderr "\tThis module adds gdb to the environment."
}

module-whatis   "Sets up the gdb environment"

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

echo "=== gdb $ver installed"
exit 0
