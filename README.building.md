## Overview

The repository includes a trimmed TeX Live source tree under `Build/source/` with only
the packages required to build xdvipsk and its dependencies.  All builds are out-of-source
and driven through the `./Build` wrapper script.  See `Build/source/xdvipsk_building.md`
for a full configure reference.

### Sources added/modified

- `Build/source/texk/xdvipsk` — xdvipsk sources
- `Build/source/m4/kpse-pkgs.m4` — package list (trimmed from full TeX Live)

### Updating configuration files

After editing `configure.ac`, `Makefile.am`, or any `m4/*.m4` file:

```
    cd Build/source
    ./reautoconf
```

Then rebuild from the top-level work directory (not the package subdir).

### Build examples

- `macOS` (bundled libs)

```
    cd Build/source
    TL_WORKDIR=Work-macos ./Build -C \
      --disable-all-pkgs --enable-xdvipsk --without-x --disable-xetex --disable-xindy
```

- `macOS` (system libjpeg/libtiff via Homebrew — no pkg-config on this machine)

```
    cd Build/source
    TL_WORKDIR=Work-macos-sys \
    CPPFLAGS="-I/opt/homebrew/opt/jpeg-turbo/include -I/opt/homebrew/opt/libtiff/include" \
    LDFLAGS="-L/opt/homebrew/opt/jpeg-turbo/lib -L/opt/homebrew/opt/libtiff/lib" \
    ./Build -C \
      --disable-all-pkgs --enable-xdvipsk --without-x --disable-xetex --disable-xindy \
      --with-system-libjpeg --with-system-libtiff
```

- `Windows` (cross-compiling with `mingw-w64` from macOS arm64)

```
    cd Build/source
    TL_WORKDIR=Work-win ./Build -C \
      --host=x86_64-w64-mingw32 --build=aarch64-apple-darwin \
      --disable-all-pkgs --enable-xdvipsk --without-x --disable-xetex --disable-xindy
```

- `Linux` (Docker, Ubuntu 24.04, x86-64)

```
    cd Build
    make build        # build Docker image (once)
    make linux-build  # run build; output in Build/source/Work-linux/
```

### Incremental rebuild

To rebuild without reconfiguring (after a source change):

```
    cd Build/source/Work-macos   # or Work-macos-sys, Work-win
    make -j$(sysctl -n hw.logicalcpu)
```

For Linux, re-run `make linux-build` from `Build/`.
