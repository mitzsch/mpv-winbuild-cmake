if(${TARGET_CPU} MATCHES "x86_64")
    set(high_bit_depth "-DHIGH_BIT_DEPTH=ON")
    # 10bit/12bit only supported in x64.
    set(ffmpeg_x265 "x265-8+10bit")
else()
    set(high_bit_depth "-DHIGH_BIT_DEPTH=OFF")
    set(ffmpeg_x265 "x265-10bit")
endif()

ExternalProject_Add(x265
    GIT_REPOSITORY https://github.com/shinchiro/x265.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1 LOG_UPDATE 1
)

get_property(source_dir TARGET x265 PROPERTY _EP_SOURCE_DIR)
get_property(binary_dir TARGET x265 PROPERTY _EP_BINARY_DIR)

ExternalProject_Add(x265-10bit
    DEPENDS
        x265
    DOWNLOAD_COMMAND ""
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} cmake -H${source_dir}/source -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
        ${high_bit_depth}
        -DENABLE_SHARED=OFF
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add(x265-10bit-lib
    DEPENDS
        x265
    DOWNLOAD_COMMAND ""
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} cmake -H${source_dir}/source -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_INSTALL_PREFIX=<BINARY_DIR>
        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
        -DHIGH_BIT_DEPTH=ON
        -DEXPORT_C_API=OFF
        -DENABLE_SHARED=OFF
        -DENABLE_CLI=OFF
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libx265.a ${binary_dir}/libx265_main10.a
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add(x265-12bit-lib
    DEPENDS
        x265
    DOWNLOAD_COMMAND ""
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} cmake -H${source_dir}/source -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_INSTALL_PREFIX=<BINARY_DIR>
        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
        -DHIGH_BIT_DEPTH=ON
        -DMAIN12=ON
        -DEXPORT_C_API=OFF
        -DENABLE_SHARED=OFF
        -DENABLE_CLI=OFF
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libx265.a ${binary_dir}/libx265_main12.a
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

set(COMBINE ${CMAKE_CURRENT_BINARY_DIR}/x265-prefix/src/combine-libs.sh)
file(WRITE ${COMBINE}
"#!/bin/bash
dir=$1
echo create libx265.a > $dir/combine-libs.mri
for lib in $2 $3 $4
do
    echo addlib $lib >> $dir/combine-libs.mri
done
echo save >> $dir/combine-libs.mri
echo end >> $dir/combine-libs.mri
${EXEC} ${TARGET_ARCH}-ar -M < $dir/combine-libs.mri
")

ExternalProject_Add(x265-8+10bit
    DEPENDS
        x265
        x265-10bit-lib
    DOWNLOAD_COMMAND ""
    LIST_SEPARATOR ^^
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy ${binary_dir}/libx265_main10.a <BINARY_DIR>
              COMMAND ${EXEC} cmake -H${source_dir}/source -B<BINARY_DIR>
                        -G Ninja
                        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
                        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
                        -DEXTRA_LIB='x265_main10.a'
                        -DEXTRA_LINK_FLAGS=-L.
                        -DLINKED_10BIT=ON
                        -DENABLE_SHARED=OFF
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
          COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libx265.a <BINARY_DIR>/libx265_main.a
          COMMAND chmod 755 ${COMBINE}
          COMMAND ${COMBINE} <BINARY_DIR> libx265_main.a libx265_main10.a
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install/strip
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

ExternalProject_Add(x265-8+10+12bit
    DEPENDS
        x265
        x265-12bit-lib
        x265-10bit-lib
    DOWNLOAD_COMMAND ""
    LIST_SEPARATOR ^^
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -E copy ${binary_dir}/libx265_main10.a <BINARY_DIR>
              COMMAND ${CMAKE_COMMAND} -E copy ${binary_dir}/libx265_main12.a <BINARY_DIR>
              COMMAND ${EXEC} cmake -H${source_dir}/source -B<BINARY_DIR>
                        -G Ninja
                        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
                        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
                        -DEXTRA_LIB='x265_main10.a^^x265_main12.a'
                        -DEXTRA_LINK_FLAGS=-L.
                        -DLINKED_10BIT=ON
                        -DLINKED_12BIT=ON
                        -DENABLE_SHARED=OFF
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
          COMMAND ${CMAKE_COMMAND} -E copy <BINARY_DIR>/libx265.a <BINARY_DIR>/libx265_main.a
          COMMAND chmod 755 ${COMBINE}
          COMMAND ${COMBINE} <BINARY_DIR> libx265_main.a libx265_main10.a libx265_main12.a
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install/strip
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(x265)
cleanup(x265 install)
cleanup(x265-10bit-lib install)
cleanup(x265-12bit-lib install)
cleanup(x265-10bit install)
cleanup(x265-8+10bit install)
cleanup(x265-8+10+12bit install)
