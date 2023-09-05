# CMake-based MinGW-w64 Cross Toolchain

This thing’s primary use is to build Windows binaries of mpv.

This repo adds the capability to select the mpv version you want to compile.

Possible values are:

- mpv (upstream)   => You can download the builds from [here](https://sourceforge.net/projects/mpv-player-windows/files/).
- mpv-plex-otruehd => mpv with patches necessary for Plex HTPC and HDR passthrough + the old trueHD passthrough logic.
- mpv-plex-ntruehd => mpv with patches necessary for Plex HTPC and HDR passthrough + the new and patched trueHD passthrough logic.


## Prerequisites

 -  You should also install Ninja and use CMake’s Ninja build file generator.
    It’s not only much faster than GNU Make, but also far less error-prone,
    which is important for this project because CMake’s ExternalProject module
    tends to generate makefiles that confuse GNU Make’s jobserver thingy.

 -  As a build environment, any modern Linux distribution *should* work.

-   Compiling on Cygwin / MSYS2 is supported, but it tends to be slower
    than compiling on Linux.


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
    - nettle
    - curl
    - libxml2
    - amf-headers
    - avisynth-headers
    - nvcodec-headers
    - libvpl
    - megasdk (with termcap, readline, cryptopp, sqlite, libuv, libsodium)
    - aom
    - dav1d
    - libplacebo (with glad, fast_float)
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

- Zip
    - expat (2.5.0)
    - bzip (1.0.8)
    - zlib (1.2.13)
    - xvidcore (1.3.7)
    - vorbis (1.3.7)
    - speex (1.2.1)
    - ogg (1.3.5)
    - lzo (2.10)
    - libopenmpt (0.7.2)
    - libiconv (1.17)
    - gmp (6.3.0)
    - vapoursynth (R63)
    - libsdl2 (2.28.2)
    - mbedtls (3.4.1)
    - ~~libressl (3.1.5)~~


## Setup Build Environment
### Manjaro / Arch Linux

First update your system:
   
    pacman -Syu

These packages need to be installed first before compiling mpv:

    pacman -S git gyp mercurial subversion ninja cmake ragel yasm nasm asciidoc enca gperf unzip p7zip gcc-multilib clang python-pip curl lib32-glib2 cairo

    pip3 install rst2pdf mako jsonschema
	
Another package we need is meson, for it to install run (recommended):

    pacman -S meson

In the past I had it once that the version shipped with the distribution was out of date, so if building fails due to meson beeing out of date, run:

	pip3 install https://github.com/mesonbuild/meson/archive/refs/heads/master.zip --break-system-packages

But only in this case... - Installing meson through pacman should be fine in most cases. 

I highly recommend using Arch Linux as it contains all packages needed and also updates them very frequently. Alternatively, you can use any other distro 
containing up to date packages. If you are not that familiar with Arch or Linux in general, use Manjaro instead. 
Ubuntu tends to only feature older versions of the packages we need, they are likely the reason why the building process fails.

Other building environments like MSYS2 or Cygwin are supported and may work, but I never had luck using those, so I don´t recommend them. 

## Building Software (First Time)

To set up the build environment, first start cloning the repo to your local machine:

    git clone https://github.com/mitzsch/mpv-winbuild-cmake.git -b mpv-different-versions
	cd mpv-winbuild-cmake

Then we need to create a directory to store build files in:

    mkdir build64
    cd build64

Once you’ve changed into that directory, run CMake, e.g.

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 -G Ninja ..

Add `-DGCC_ARCH=x86-64-v3` to command-line if you want to compile gcc with new `x86-64-v3` instructions, like so

    cmake -DTARGET_ARCH=x86_64-w64-mingw32 -DGCC_ARCH=x86-64-v3 -G Ninja ..

Other values like `native`, `znver3` should work too in theory.


First, you need to build the toolchain. By default, it will be installed in `install` folder. This takes some time, even on fast machines.

    ninja gcc

After it has finished, you're ready to build mpv and all its dependencies:

    ninja mpv
	
This will build upstream mpv with unmodified ffmpeg. In case you want to compile 
mpv with the modified ffmpeg code that contains the old truehd logic. run:

    ninja mpv-plex-otruehd
	
Run:

    ninja mpv-plex-ntruehd

if you want to compile mpv with the modified ffmpeg code that contains the new and patched truehd logic.

This will take a while, be patient.


The final `build64` folder's size will be around ~15GB.

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

To build mpv for a second time:

    ninja update
	
Better also run:

    ninja ffmpeg-ntruehd-removeprefix ffmpeg-ntruehd-removeprefix
   
If it fails, also run:

    ninja nettle-removeprefix luajit-removeprefix fontconfig-removeprefix libsrt-removeprefix spirv-cross-removeprefix libzvbi-removeprefix vulkan-removeprefix libjxl-removeprefix

After that, build mpv as usual:

    ninja mpv / ninja mpv-plex-otruehd / ninja mpv-plex-ntruehd

This will also build all packages that `mpv` depends on.

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

## Acknowledgements

This project was originally created and maintained [lachs0r](https://github.com/lachs0r/mingw-w64-cmake). Since then, it heavily modified to suit my own need.
