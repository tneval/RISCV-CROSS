#!/bin/bash

# USAGE:
# ./XC.sh init              - to fetch the RISCV toolchain and setup cmake-cross file
# ./XC.sh build-llvm-xc     - to build the cross-compiler
# ./XC.sh build-llvm-riscv  - to build RISC-V native LLVM

set -e

# Modify compilers if needed (e.g. clang-20)
export CC=clang
export CXX=clang++

CROSSCHAIN=$(pwd)/sources/riscv64-unknown-linux-gnu

# All sources are put here
mkdir -p sources

# When compiled, compressed tarballs are put here
mkdir -p tarballs

cmd=$1

case "$cmd" in
    init)
        wget -O sources/riscv64-unknown-linux-gnu.tar.bz2 https://admin.hca.bsc.es/epi/ftp/GNU/bin/riscv64-unknown-linux-gnu.tar.bz2
        tar -jxf sources/riscv64-unknown-linux-gnu.tar.bz2 -C sources
        echo "initti"

        mkdir -p build

        cat - <<EOF > build/riscv64-gcc.cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_CROSSCOMPILING TRUE)
set(CMAKE_SYSTEM_PROCESSOR riscv64)
set(CMAKE_SYSROOT "$CROSSCHAIN/riscv64-unknown-linux-gnu/sysroot")
set(CMAKE_C_COMPILER_TARGET riscv64-unknown-linux-gnu)
set(CMAKE_CXX_COMPILER_TARGET riscv64-unknown-linux-gnu)
set(CMAKE_LINKER_TYPE LLD)
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
EOF
        exit 1
        ;;


    #### Cross-compiler
    build-llvm-xc)
        if [ ! -d "sources/llvm-project" ]; then

            # Modify the tag as needed
            git clone --depth=1 https://github.com/llvm/llvm-project.git sources/llvm-project
            git -C sources/llvm-project fetch --depth=1 origin tag llvmorg-22.1.6
            git -C sources/llvm-project checkout llvmorg-22.1.6

            git clone https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git sources/llvm-project/llvm/projects
            git -C sources/llvm-project/llvm/projects/SPIRV-LLVM-Translator checkout llvm_release_220
            exit 1

        else
            echo "repository already exists, skipping clone"
        fi

        if [ ! -d "build/llvm-cc" ]; then
            cmake -G "Ninja" -B build/llvm-cc \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=$(pwd)/install/llvm-cc \
                -DLLVM_ENABLE_ASSERTIONS=ON \
                -DLLVM_TARGETS_TO_BUILD="RISCV" \
                -DLLVM_ENABLE_PROJECTS="clang" \
                sources/llvm-project/llvm
                (cd build/llvm-cc/ && ninja)
        else
             echo "cross-compiler already exists, skipping build"
        fi

        exit 1
        ;;


    #### RISCV-native upstream LLVM
    build-llvm-riscv)

        if [ -d "build/llvm-cc" ]; then

            cmake -G "Ninja" -B build/llvm-riscv \
                -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_CROSSCOMPILING=ON \
                -DCMAKE_INSTALL_PREFIX=$(pwd)/install/llvm-riscv \
                -DLLVM_NATIVE_TOOL_DIR=$(pwd)/build/llvm-cc/bin \
                -DCMAKE_C_FLAGS="--sysroot=$CROSSCHAIN/riscv64-unknown-linux-gnu/sysroot/ --gcc-toolchain=$CROSSCHAIN -target riscv64-unknown-linux-gnu -Os -mabi=lp64d -march=rv64imafdcv_zicbom_zicboz_zicntr_zicond_zicsr_zifencei_zihintpause_zihpm_zfh_zfhmin_zca_zcd_zba_zbb_zbc_zbs_zkt_zve32f_zve32x_zve64d_zve64f_zve64x_zvfh_zvfhmin_zvkt_sscofpmf_sstc_svinval_svnapot_svpbmt" \
                -DCMAKE_CXX_FLAGS="--sysroot=$CROSSCHAIN/riscv64-unknown-linux-gnu/sysroot/ --gcc-toolchain=$CROSSCHAIN -target riscv64-unknown-linux-gnu -Os -mabi=lp64d -march=rv64imafdcv_zicbom_zicboz_zicntr_zicond_zicsr_zifencei_zihintpause_zihpm_zfh_zfhmin_zca_zcd_zba_zbb_zbc_zbs_zkt_zve32f_zve32x_zve64d_zve64f_zve64x_zvfh_zvfhmin_zvkt_sscofpmf_sstc_svinval_svnapot_svpbmt" \
                -DLLVM_HOST_TRIPLE=riscv64-unknown-linux-gnu \
                -DLLVM_DEFAULT_TARGET_TRIPLE=riscv64-linux-gnu \
                -DLLVM_BUILD_LLVM_DYLIB=ON \
                -DLLVM_LINK_LLVM_DYLIB=ON \
                -DLLVM_TARGET_ARCH=riscv64 \
                -DCMAKE_SYSTEM_NAME=Linux \
                -DCMAKE_SYSTEM_PROCESSOR=riscv64 \
                -DLLVM_ENABLE_ASSERTIONS=ON \
                -DLLVM_TARGETS_TO_BUILD="RISCV;SPIRV" \
                -DLLVM_ENABLE_PROJECTS="clang" \
                sources/llvm-project/llvm
                (cd build/llvm-riscv/ && ninja install)
        else
            echo "cross-compiler does not exist"
        fi
        exit 1
        ;;

    *)
        echo "incorrect usage"
        exit 1
        ;;
esac


cmake -G "Ninja" -B build/llvm-epi-riscv \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CROSSCOMPILING=ON \
  -DCMAKE_INSTALL_PREFIX=$(pwd)/install/llvm-epi-riscv \
  -DLLVM_NATIVE_TOOL_DIR=$(pwd)/build/llvm-epi-x86/bin \
  -DCMAKE_C_FLAGS="--sysroot=$CROSSCHAIN/riscv64-unknown-linux-gnu/sysroot/ --gcc-toolchain=$CROSSCHAIN -target riscv64-unknown-linux-gnu -Os -mabi=lp64d -march=rv64imafdcv_zicbom_zicboz_zicntr_zicond_zicsr_zifencei_zihintpause_zihpm_zfh_zfhmin_zca_zcd_zba_zbb_zbc_zbs_zkt_zve32f_zve32x_zve64d_zve64f_zve64x_zvfh_zvfhmin_zvkt_sscofpmf_sstc_svinval_svnapot_svpbmt" \
  -DCMAKE_CXX_FLAGS="--sysroot=$CROSSCHAIN/riscv64-unknown-linux-gnu/sysroot/ --gcc-toolchain=$CROSSCHAIN -target riscv64-unknown-linux-gnu -Os -mabi=lp64d -march=rv64imafdcv_zicbom_zicboz_zicntr_zicond_zicsr_zifencei_zihintpause_zihpm_zfh_zfhmin_zca_zcd_zba_zbb_zbc_zbs_zkt_zve32f_zve32x_zve64d_zve64f_zve64x_zvfh_zvfhmin_zvkt_sscofpmf_sstc_svinval_svnapot_svpbmt" \
  -DLLVM_HOST_TRIPLE=riscv64-unknown-linux-gnu \
  -DLLVM_DEFAULT_TARGET_TRIPLE=riscv64-linux-gnu \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_APPEND_VC_REVISION=OFF \
  -DLLVM_TARGET_ARCH=riscv64 \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=riscv64 \
  -DLLVM_ENABLE_ASSERTIONS=ON \
  -DLLVM_TARGETS_TO_BUILD="RISCV;SPIRV" \
  -DLLVM_ENABLE_PROJECTS="clang" \
  sources/llvm-project/llvm
(cd build/llvm-epi-riscv/ && ninja install)
