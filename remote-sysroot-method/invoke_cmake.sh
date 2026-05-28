#!/bin/bash

BUILD_DIR=build-remote-riscv
SOURCE_DIR=/home/tapio/vault/repositories/pocl-unpublished-wts/loopvec-next

# the root filesystem of the board
TARGET_ROOT=/home/tapio/SSHFS-mountpoint/neptune
# the location of Target LLVM inside the TARGET_ROOT
TARGET_LLVM_INSTALL_DIR=/opt/LLVM_22_SPIRV
# host-side LLVM
HOST_LLVM_CONFIG=/home/tapio/vault/Software/LLVM-22-Release/bin/llvm-config

# Target settings
TARGET_TRIPLE=riscv64-unknown-linux-gnu
TARGET_CPU=spacemit-x60

# set location
TARGET_TOOLCHAIN_FILE=/home/tapio/vault/repositories/RISCV-CROSS/remote-sysroot-method/cross_milkv.cmake


cmake -DCMAKE_MAKE_PROGRAM=/usr/bin/make \
      -DLLVM_DIR=${TARGET_ROOT}${TARGET_LLVM_INSTALL_DIR} -DWITH_LLVM_CONFIG=${HOST_LLVM_CONFIG} \
      -DHOST_DEVICE_BUILD_HASH=${TARGET_TRIPLE} -DCMAKE_TOOLCHAIN_FILE=${TARGET_TOOLCHAIN_FILE}  \
      -DLLC_TRIPLE=${TARGET_TRIPLE} -DLLC_HOST_CPU=${TARGET_CPU} -DCMAKE_PREFIX_PATH=${TARGET_ROOT} \
      -DENABLE_ICD=ON -DENABLE_LOADABLE_DRIVERS=0 -DKERNELLIB_HOST_CPU_VARIANTS=${TARGET_CPU} \
      -B ${BUILD_DIR} ${SOURCE_DIR}
