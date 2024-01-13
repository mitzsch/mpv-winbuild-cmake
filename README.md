# CMake-based MinGW-w64 Cross Toolchain

This thing’s primary use is to build Windows binaries of mpv.

This repo adds the capability to select the mpv version you want to compile.

Possible values are:

- *mpv (upstream mpv + upstream ffmpeg)* => You can download the builds from [here](https://sourceforge.net/projects/mpv-player-windows/files/).
- *mpv-plex-otruehd* => mpv with patches needed for Plex HTPC and HDR passthrough + the old FFmpeg trueHD passthrough logic.
- *mpv-plex-ntruehd* => mpv with patches needed for Plex HTPC and HDR passthrough + the new and patched FFmpeg trueHD passthrough logic.
- *mpv-otruehd* => upstream mpv + the old FFmpeg trueHD passthrough logic.
- *mpv-ntruehd* => upstream mpv + the new and patched FFmpeg trueHD passthrough logic.

## Prerequisites

 -  You should also install Ninja and use CMake’s Ninja build file generator.
    It’s not only much faster than GNU Make, but also far less error-prone,
    which is important for this project because CMake’s ExternalProject module
    tends to generate makefiles that confuse GNU Make’s jobserver thingy.

 -  As a build environment, any modern Linux distribution *should* work.

 -  Compiling on Cygwin / MSYS2 is supported, but it tends to be slower
    than compiling on Linux.

## Setup Build Environment
### Manjaro / Arch Linux

First update your system:
   
    pacman -Syu

These packages need to be installed first before compiling mpv:

    pacman -S git gyp mercurial subversion ninja cmake ragel yasm nasm asciidoc enca gperf unzip p7zip gcc-multilib clang lld libc++ libc++abi python-pip curl lib32-glib2 mimalloc ccache

Installing rst2pdf mako jsonschema through pip3 may work but could also error out...

    pip3 install rst2pdf mako jsonschema
	
Installing them through pacman is recommend:

    pacman -S python-mako python-jsonschema rst2pdf	

Another package we need is meson, for it to install run (recommended):

    pacman -S meson

In the past I had it once that the version shipped with the distribution was out of date, so if building fails due to meson beeing out of date, run:

	pip3 install https://github.com/mesonbuild/meson/archive/refs/heads/master.zip --break-system-packages

But only in this case... - Installing meson through pacman should be fine in most cases. 

I highly recommend using Arch Linux as it contains all packages needed and also updates them very frequently. Alternatively, you can use any other distro 
containing up to date packages. If you are not that familiar with Arch or Linux in general, use Manjaro instead. 
Ubuntu tends to only feature older versions of the packages we need, they are likely the reason why the building process fails.

Other building environments like MSYS2 or Cygwin are supported and may work, but I never had luck using those, so I don´t recommend them. 

### Ubuntu Linux / WSL (Windows 10)

    apt-get install build-essential checkinstall bison flex gettext git mercurial subversion ninja-build gyp cmake yasm nasm automake pkgconf libtool libtool-bin gcc-multilib g++-multilib clang lld libc++1 libc++abi1 libgmp-dev libmpfr-dev libmpc-dev libgcrypt-dev gperf ragel texinfo autopoint re2c asciidoc python3-pip docbook2x unzip p7zip-full curl mimalloc ccache

    pip3 install rst2pdf meson mako jsonschema

**Note:**

* Use [apt-fast](https://github.com/ilikenwf/apt-fast) if apt-get is too slow.
* It is advised to use bash over dash. Set `sudo ln -sf /bin/bash /bin/sh`. Revert back by `sudo ln -sf /bin/dash /bin/sh`.
* On WSL platform, compiling 32bit requires qemu. Refer to [this](https://github.com/Microsoft/WSL/issues/2468#issuecomment-374904520).
* To update package installed by pip, run `pip3 install <package> --upgrade`.

### Cygwin

Download Cygwin installer and run:

    setup-x86_64.exe -R "C:\cygwin64" -q --packages="bash,binutils,bzip2,cygwin,gcc-core,gcc-g++,cygwin32-gcc-core,cygwin32-gcc-g++,gzip,m4,pkgconf,make,unzip,zip,diffutils,wget,git,patch,cmake,gperf,yasm,enca,asciidoc,bison,flex,gettext-devel,mercurial,python-devel,python-docutils,docbook2X,texinfo,libmpfr-devel,libgmp-devel,libmpc-devel,libtool,autoconf2.5,automake,automake1.9,libxml2-devel,libxslt-devel,meson,libunistring5"

Additionally, some packages, `re2c`, `ninja`, `ragel`, `gyp`, `rst2pdf`, `nasm` need to be [installed manually](https://gist.github.com/shinchiro/705b0afcc7b6c0accffba1bedb067abf).

### MSYS2

Install MSYS2 and run it via `MSYS2 MSYS` shortcut.
Don't use `MSYS2 MinGW 32-bit` or `MSYS2 MinGW 64-bit` shortcuts, that's important!

These packages need to be installed first before compiling mpv:

    pacman -S base-devel cmake gcc yasm nasm git mercurial subversion gyp tar gmp-devel mpc-devel mpfr-devel python zlib-devel unzip zip p7zip meson libunistring5

Don't install anything from the `mingw32` and `mingw64` repositories,
it's better to completely disable them in `/etc/pacman.conf` just to be safe.

Additionally, some packages, `re2c`, `ninja`, `ragel`, `libjpeg`, `rst2pdf`, `jinja2` need to be [installed manually](https://gist.github.com/shinchiro/705b0afcc7b6c0accffba1bedb067abf).


## Building Software (First Time with GCC)

To set up the build environment, first start cloning the repo to your local machine:

    git clone https://github.com/mitzsch/mpv-winbuild-cmake.git -b mpv-different-versions
	cd mpv-winbuild-cmake

Once you’ve changed into that directory, run CMake, e.g.

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 -G Ninja -B build64

Add `-DGCC_ARCH=x86-64-v3` to command-line if you want to compile gcc with new `x86-64-v3` instructions, like so

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 -DGCC_ARCH=x86-64-v3 -G Ninja -B build64

Other values like `native`, `znver3` should work too in theory.

Optional step before starting...  This will download all packages at once.
   
    ninja download

First, you need to build the toolchain. By default, it will be installed in `install` folder. This takes some time (~20 minutes), even on fast machines.

    ninja gcc

After it has finished, you're ready to build upstrean/unmodified mpv with upstream/unmodified ffmpeg and all its dependencies:

    ninja mpv
	
In case you want to compile upstream/unmodified mpv with the modified ffmpeg code that contains the old truehd passthrough logic:

    ninja mpv-otruehd
	
If you want to compile upstream/unmodified mpv with the modified ffmpeg code that contains the new and patched truehd passthrough logic:

    ninja mpv-ntruehd

If you are a Plex HTPC user and wan't to build a modified mpv with the old trueHD passthrough logic:

    ninja mpv-plex-otruehd

... or modified mpv with the new and patched trueHD passthrough logic:

    ninja mpv-plex-ntruehd


This will take a while, be patient.


The final `build64` folder's size will be around ~15GB.

## Building Software (First Time with Clang)

To set up the build environment, first start cloning the repo to your local machine:

    git clone https://github.com/mitzsch/mpv-winbuild-cmake.git -b mpv-different-versions
	cd mpv-winbuild-cmake

Once you’ve changed into that directory, run CMake, e.g.

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 -DCOMPILER_TOOLCHAIN=clang -DGCC_ARCH=x86-64 -G Ninja -B build_x86_64

Add `-DGCC_ARCH=x86-64-v3` to command-line if you want to compile clang with new `x86-64-v3` instructions, like so

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 -DCOMPILER_TOOLCHAIN=clang -DGCC_ARCH=x86-64-v3 -G Ninja -B build_x86_64

Optional step before starting...  This will download all packages at once.
   
    ninja download

First, you need to build the toolchain. This takes some time (~ 1h), even on fast machines.

    cd build_x86_64
    ninja llvm       # build LLVM (take around ~1 hours)
    ninja rustup     # build rust toolchain
    ninja llvm-clang # build clang on specified target

After it has finished, you're ready to build upstrean/unmodified mpv with upstream/unmodified ffmpeg and all its dependencies:

    ninja mpv
	
In case you want to compile upstream/unmodified mpv with the modified ffmpeg code that contains the old truehd passthrough logic:

    ninja mpv-otruehd
	
If you want to compile upstream/unmodified mpv with the modified ffmpeg code that contains the new and patched truehd passthrough logic:

    ninja mpv-ntruehd

If you are a Plex HTPC user and wan't to build a modified mpv with the old trueHD passthrough logic:

    ninja mpv-plex-otruehd

... or modified mpv with the new and patched trueHD passthrough logic:

    ninja mpv-plex-ntruehd


This will take a while, be patient.


The final `build64` folder's size will be around ~12GB.


## Building the other mpv version

After successfully building one version simply rerunning ninja for the other version does not really work. This is because of the same name 
of ffmpeg and how packages are detected. For the detection system, there is no difference, between ffmpeg-otruehd and ffmpeg-ntruehd, both are called ffmpeg.
This leads to a version mismatch after recompiling the other version. To circumvent this, you have to run:

    ninja ffmpeg-ntruehd-removeprefix ffmpeg-ntruehd-removeprefix
  
Also run this: 

    ninja nettle-removeprefix luajit-removeprefix fontconfig-removeprefix libsrt-removeprefix spirv-cross-removeprefix libzvbi-removeprefix vulkan-removeprefix libjxl-removeprefix

This is needed as for some reason those packages tend to fail when recompiling... Running the above ninja command may result in an error output, don´t worry that is expected.
When this is done, re-run ninja for the other version you want to compile. Done!


## Building Software (Second Time)

To build mpv for a second time. First go into the root mpv-winbuild-cmake directory and run:

    git pull origin

This will fetch all code changes that have been made to the packages needed for building. After that run:

    ninja update # perform git pull on all packages that used git
	
Better also run:

    ninja ffmpeg-ntruehd-removeprefix ffmpeg-ntruehd-removeprefix
   
If it fails, also run:

    ninja nettle-removeprefix luajit-removeprefix fontconfig-removeprefix libsrt-removeprefix spirv-cross-removeprefix libzvbi-removeprefix vulkan-removeprefix libjxl-removeprefix

After that, build mpv as usual:

    ninja mpv / ninja mpv-plex-otruehd / ninja mpv-plex-ntruehd / mpv-otruehd / mpv-ntruehd

This will also build all packages that `mpv` depends on.


## Compiling with GCC

Example:

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 \
    -DGCC_ARCH=x86-64-v3 \
    -DSINGLE_SOURCE_LOCATION="/home/user/packages" \
    -DRUSTUP_LOCATION="/home/user/install_rustup" \
    -G Ninja -B build64 -S mpv-winbuild-cmake

This cmake command will create `build64` folder for `x86_64-w64-mingw32`. Set `-DTARGET_ARCH=i686-w64-mingw32` for compiling 32-bit.

`-DGCC_ARCH=x86-64-v3` will set `-march` option when compiling gcc with `x86-64-v3` instructions. Other value like `native`, `znver3` should work too.

Enter `build64` folder and build toolchain like described. By default, it will be installed in `install` folder.

On **WSL2**, you might see it stuck with 100% disk usage and never finished. See [below](#wsl-workaround).

The final `build64` folder's size will be around ~3GB.


## Compiling with Clang

Supported target architecture (`TARGET_ARCH`) with clang is: `x86_64-w64-mingw32` , `i686-w64-mingw32` , `aarch64-w64-mingw32`. The `aarch64` are untested.

Example:

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 \
    -DCMAKE_INSTALL_PREFIX="/home/user/clang_root" \
    -DCOMPILER_TOOLCHAIN=clang \
    -DGCC_ARCH=x86-64-v3 \
    -DSINGLE_SOURCE_LOCATION="/home/user/packages" \
    -DRUSTUP_LOCATION="/home/user/install_rustup" \
    -DMINGW_INSTALL_PREFIX="/home/user/build_x86_64_v3/x86_64_v3-w64-mingw32" \
    -G Ninja -B build_x86_64_v3 -S mpv-winbuild-cmake

The cmake command will create `clang_root` as clang sysroot where llvm tools installed. `build_x86_64` is build directory to compiling packages.

    cd build_x86_64
    ninja llvm       # build LLVM (take around ~1 hours)
    ninja rustup     # build rust toolchain
    ninja llvm-clang # build clang on specified target
    ninja mpv        # build mpv and all its dependencies

If you want add another target (ex. `i686-w64-mingw32`), change `TARGET_ARCH` and build folder.

    cmake -DTARGET_ARCH=i686-w64-mingw32 \
    -DCMAKE_INSTALL_PREFIX="/home/user/clang_root" \
    -DCOMPILER_TOOLCHAIN=clang \
    -DSINGLE_SOURCE_LOCATION="/home/user/packages" \
    -DRUSTUP_LOCATION="/home/user/install_rustup" \
    -DMINGW_INSTALL_PREFIX="/home/user/build_i686/i686-w64-mingw32" \
    -G Ninja -B build_i686 -S mpv-winbuild-cmake
    cd build_i686
    ninja llvm-clang # same as above

If you've changed `GCC_ARCH` option, you need to run:

    ninja rebuild_cache

to update flags which will pass on gcc, g++ and etc.


## Available Commands

| Commands                   | Description |
| -------------------------- | ----------- |
| ninja package              | compile a package |
| ninja clean                | remove all stamp files in all packages. |
| ninja download             | Download all packages' sources at once without compiling. |
| ninja update               | Update all git repos. When a package pulls new changes, all of its stamp files will be deleted and will be forced rebuild. If there is no change, it will not remove the stamp files and no rebuild occur. Use this instead of `ninja clean` if you don't want to rebuild everything in the next run. |
| ninja package-fullclean    | Remove all stamp files of a package. |
| ninja package-liteclean    | Remove build, clean stamp files only. This will skip re-configure in the next running `ninja package` (after the first compile). Updating repo or patching need to do manually. Ideally, all `DEPENDS` targets in `package.cmake` should be temporarily commented or deleted. Might be useful in some cases. |
| ninja package-removebuild  | Remove 'build' directory of a package. |
| ninja package-removeprefix | Remove 'prefix' directory. |
| ninja package-force-update | Update a package. Only git repo will be updated. |

`package` is package's name found in `packages` folder.


## Information about packages

- Git/Hg
    - ANGLE
    - FFmpeg (unmodified upstream/patched)
    - xz
    - x264
    - x265 (multilib)
    - uchardet
    - rubberband
    - opus
    - openal-soft
    - mpv (unmodified upstream/patched)
    - luajit
    - libvpx
    - libwebp
    - libpng
    - libsoxr
    - libzimg (with graphengine)
    - libdvdread
    - libdvdnav
    - libdvdcss
    - libudfread
    - libbluray
    - libunibreak
    - libass
    - libmysofa
    - lcms2
    - lame
    - harfbuzz
    - game-music-emu
    - freetype2
    - flac
    - opus-tools
    - mujs
    - libarchive
    - libjpeg
    - shaderc (with spirv-headers, spirv-tools, glslang)
    - vulkan-header
    - vulkan
    - spirv-cross
    - fribidi
    - ~~nettle~~
    - curl
    - libxml2
    - amf-headers
    - avisynth-headers
    - nvcodec-headers
    - libvpl
    - megasdk (with termcap, readline, cryptopp, sqlite, libuv, libsodium)
    - aom
    - dav1d
    - libplacebo (with glad, fast_float, xxhash)
    - fontconfig
    - libbs2b
    - libssh
    - libsrt
    - libjxl (with brotli, highway)
    - libmodplug
    - uavs3d
    - davs2
    - libsixel
    - libdovi
    - libva
    - libzvbi
    - rav1e
    - libaribcaption
    - zlib (zlib-ng)
    - zstd
    - expat
    - openssl
    - mesa
    - libsdl2
    - speex
    - vorbis
    - ogg
    - bzip2

- Zip
    - xvidcore (1.3.7)
    - lzo (2.10)
    - libopenmpt (0.7.3)
    - libiconv (1.17)
    - ~~gmp (6.3.0)~~
    - vapoursynth (R65/R63)
    - ~~mbedtls (3.5.0)~~
    - ~~libressl (3.1.5)~~


### WSL workaround

Place the file on specified location to limit ram & cpu usage to avoid getting stuck while building mpv.

    # /etc/wsl.conf
    [interop]
    #enabled=false
    appendWindowsPath=false

    [automount]
    enabled = true
    options = "metadata"
    mountFsTab = false

    [user]
    default=<user>
    ---------------------------------------
    # C:\Users\<UserName>\.wslconfig
    [wsl2]
    memory=4GB
    swap=0
    pageReporting=false

### VA-API Driver

To use VA-API Win32:

    ninja mesa

`vaon12_drv_video.dll` will be generated in `install/$TARGET_ARCH/bin`

this is a layered driver running on top of Direct3D 12 API. Deployment instructions have been [documented by Microsoft](https://devblogs.microsoft.com/directx/video-acceleration-api-va-api-now-available-on-windows/#how-do-i-get-it).

## Acknowledgements

This project was originally created and maintained [lachs0r](https://github.com/lachs0r/mingw-w64-cmake). Since then, it heavily modified to suit my own need.
