#!/bin/bash
# Builds LLVM that acts as a 'host' compiler for pocl in the context of cross-compilation.
# Used to build kernel library.
# Has to support RISC-V target.


# When cross-compiling PoCL, two or three compilers are needed depending on the setup:
# 1. Actual cross-compiler that produces the RISC-V native PoCL libraries. (e.g. riscv64-linux-gnu-gcc/g++)
# 2. PoCL 'host' compiler that has to be Clang. This has to be x86 binary and have RISC-V target.
#    This will compile the kernel library (LLVM bitcode), but cmake tests that it supports RISC-V target.
# 3. RISC-V native LLVM that PoCL get linked to.


# Variables
#############################################
LLVM_VERSION="22.1.6"
LLVM_SPIRV_BRANCH="llvm_release_220"
#############################################

LLVM_TAG="llvmorg-${LLVM_VERSION}"
D_NAME="llvm-x86-with-riscv-target-${LLVM_VERSION}"

set -e

mkdir -p sources
mkdir -p tarballs

if [ ! -d "sources/llvm-project" ]; then

    # Modify the tag as needed
    git clone --depth=1 https://github.com/llvm/llvm-project.git sources/llvm-project
    git -C sources/llvm-project fetch --depth=1 origin tag ${LLVM_TAG}
    git -C sources/llvm-project checkout ${LLVM_TAG}

    git clone https://github.com/KhronosGroup/SPIRV-LLVM-Translator.git sources/llvm-project/llvm/projects/SPIRV-LLVM-Translator
    git -C sources/llvm-project/llvm/projects/SPIRV-LLVM-Translator checkout ${LLVM_SPIRV_BRANCH}

else
    echo "repository already exists, skipping clone"
fi


if [ ! -d "build/${D_NAME}" ]; then
    cmake -G "Ninja" -B build/${D_NAME} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$(pwd)/install/${D_NAME} \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_TARGETS_TO_BUILD="RISCV" \
        -DLLVM_ENABLE_PROJECTS="clang" \
        -DLLVM_BUILD_LLVM_DYLIB=ON \
        -DLLVM_LINK_LLVM_DYLIB=ON \
        sources/llvm-project/llvm
        (cd build/${D_NAME}/ && ninja install)
else
        echo "host-compiler already exists, skipping build"
fi


# In case this will be used on another machine.
if [ ! -f "tarballs/${D_NAME}_${LLVM_TAG}.tar.gz" ]; then
    tar -czf "tarballs/${D_NAME}_${LLVM_TAG}.tar.gz" "install/${D_NAME}"
fi
