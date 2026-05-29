#!/bin/bash

set -e

# Variables:
###########################################################
# Choose PoCL repository
POCL_REPO="git@github.com:pocl/unpublished.git"

# the root filesystem of the board
# Local or over remote?
TARGET_ROOT=/home/tapio/SSHFS-mountpoint/neptune

# the location of Target LLVM inside the TARGET_ROOT
TARGET_LLVM_INSTALL_DIR=/opt/LLVM_22_SPIRV/lib/cmake/llvm

TARGET_LLVM_LIB_RPATH=/opt/LLVM_22_SPIRV/lib

###########################################################

BASE_DIR="$(pwd)/.."

SOURCE_DIR=${BASE_DIR}/sources/pocl-unpublished-wts

INSTALL_DIR=${BASE_DIR}/install/pocl-test

# host-side LLVM
HOST_LLVM_CONFIG="$(pwd)/../install/llvm-x86-with-riscv-target-22.1.6/bin/llvm-config"

# Target settings
TARGET_TRIPLE=riscv64-unknown-linux-gnu
TARGET_CPU=spacemit-x60

TARGET_TOOLCHAIN_FILE="$(pwd)/cross_milkv.cmake"


mkdir -p "${SOURCE_DIR}"

# Controls branch in PoCL repo
BRANCH=$1

# Using worktrees instead of checking out branches
case "$BRANCH" in
      # Loopvec-next
      lvn)
            export WORKTREE_DIR="${SOURCE_DIR}/loopvec-next"

            if [ ! -d "${WORKTREE_DIR}" ]; then
                  git clone ${POCL_REPO} "${WORKTREE_DIR}"
            fi

            export BUILD_DIR="${WORKTREE_DIR}/build"
            export INSTALL_DIR="${BUILD_DIR}/install"
            ;;
      *)
            echo "Branch not found"
            exit 0
            ;;
esac

if [ ! -d ${BUILD_DIR} ]; then
      cmake -G Ninja -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_INSTALL_RPATH=${TARGET_LLVM_LIB_RPATH} \
            -DLLVM_DIR=${TARGET_ROOT}${TARGET_LLVM_INSTALL_DIR} -DWITH_LLVM_CONFIG=${HOST_LLVM_CONFIG} \
            -DHOST_DEVICE_BUILD_HASH=${TARGET_TRIPLE} -DCMAKE_TOOLCHAIN_FILE=${TARGET_TOOLCHAIN_FILE} \
            -DLLC_TRIPLE=${TARGET_TRIPLE} -DLLC_HOST_CPU=${TARGET_CPU} -DCMAKE_PREFIX_PATH=${TARGET_ROOT} \
            -DENABLE_ICD=ON -DENABLE_LOADABLE_DRIVERS=0 -DKERNELLIB_HOST_CPU_VARIANTS=${TARGET_CPU} \
            -B ${BUILD_DIR} ${WORKTREE_DIR}
fi

(cd ${BUILD_DIR} && ninja install)

tar -czf "${BASE_DIR}/tarballs/PoCL-RISCV-${BRANCH}.tar.gz" ${INSTALL_DIR}