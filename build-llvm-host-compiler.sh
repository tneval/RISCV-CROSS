#!/bin/bash
# Builds LLVM that acts as a 'host' compiler when cross-compiling pocl.
# Used to build kernel library.
# Has to support RISC-V target.

LLVM_TAG="llvmorg-22.1.6"
LLVM_SPIRV_BRANCH="llvm_release_220"

D_NAME=llvm-x86-with-riscv-target


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
    exit 1

else
    echo "repository already exists, skipping clone"
fi


if [ ! -d "build/${D_NAME}" ]; then
    cmake -G "Ninja" -B build/${D_NAME} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=$(pwd)/install/${D_NAME} \
        -DLLVM_ENABLE_ASSERTIONS=ON \
        -DLLVM_TARGETS_TO_BUILD="X86;RISCV" \
        -DLLVM_ENABLE_PROJECTS="clang" \
        sources/llvm-project/llvm
        (cd build/${D_NAME}/ && ninja install)
else
        echo "host-compiler already exists, skipping build"
fi


if [ ! -f "tarballs/${D_NAME}_${LLVM_TAG}.tar.gz" ]; then
    tar -czf "tarballs/${D_NAME}_${LLVM_TAG}.tar.gz" "install/${D_NAME}"
fi
