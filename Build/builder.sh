#!/bin/sh -l

find . -name \*.info -exec touch '{}' \;

TL_MAKE_FLAGS="-j $(nproc)"
export TL_MAKE_FLAGS
TL_WORKDIR=Work-linux
export TL_WORKDIR
TL_INSTALL_DEST=`pwd`/${TL_WORKDIR}/inst
export TL_INSTALL_DEST

./Build -C --disable-all-pkgs --enable-xdvipsk --without-x --disable-xetex --disable-xindy

