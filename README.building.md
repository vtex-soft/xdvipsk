## Overview

Building the executable programs included in TeX Live involves usual steps of   
downloading the TeX Live sources, configuring, compiling, and installing.  
But there are some peculiarities, described here

    http://tug.org/texlive/build.html

To build VTeX adds, append TeX Live sources with ones provided by VTeX here,  
rerun configuration with `reautoconf` and use standard TeX Live building procedures.  
Overlapping file `Build/source/m4/kpse-pkgs.m4` should be merged eventually.

### Sources added/modified

- `Build/source/texk/xdvipsk`
- `Build/source/m4/kpse-pkgs.m4`

### Updating configuration files

```
    cd Build/source
    ./reautoconf
```

### Build examples

- `Linux/macos`

```
    mkdir Work
    cd Build/source/Work

    ../configure --disable-all-pkgs --without-x --disable-xetex --disable-xindy --enable-xdvipsk -C CFLAGS=-g CXXFLAGS=-g
    make
```

- `Windows` (cross compiling with `mingw`)

```
    mkdir Work
    cd Build/source/Work

    ../configure --host=x86_64-w64-mingw32 --build=x86_64-apple-darwin --disable-all-pkgs --without-x --disable-xetex --disable-xindy \
    --enable-xdvipsk -C CFLAGS=-g CXXFLAGS=-g 
```
