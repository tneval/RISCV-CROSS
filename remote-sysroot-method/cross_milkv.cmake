##################################################### github@ubuntu24:~$ cat jupiter.cmake
# Toolchain file to cross-compile for RISC-V boards from x86_64
# Copy & modify.

SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_CROSSCOMPILING TRUE)
SET(CMAKE_SYSTEM_PROCESSOR riscv64)

# specify the cross compiler
SET(CMAKE_C_COMPILER   /usr/bin/riscv64-linux-gnu-gcc-14)
SET(CMAKE_CXX_COMPILER /usr/bin/riscv64-linux-gnu-g++-14)

# be sure to change accordingly
# CPU specific flags for Spacemit-X60
SET(CMAKE_C_FLAGS_INIT "-Os -mabi=lp64d -march=rv64imafdcv_zicbom_zicboz_zicntr_zicond_zicsr_zifencei_zihintpause_zihpm_zfh_zfhmin_zca_zcd_zba_zbb_zbc_zbs_zkt_zve32f_zve32x_zve64d_zve64f_zve64x_zvfh_zvfhmin_zvkt_sscofpmf_sstc_svinval_svnapot_svpbmt")
SET(CMAKE_CXX_FLAGS_INIT "-Os -mabi=lp64d -march=rv64imafdcv_zicbom_zicboz_zicntr_zicond_zicsr_zifencei_zihintpause_zihpm_zfh_zfhmin_zca_zcd_zba_zbb_zbc_zbs_zkt_zve32f_zve32x_zve64d_zve64f_zve64x_zvfh_zvfhmin_zvkt_sscofpmf_sstc_svinval_svnapot_svpbmt")

set(CMAKE_SYSROOT "/home/tapio/SSHFS-mountpoint/neptune")
# where to find libraries in target environment
set(CMAKE_LIBRARY_PATH "${CMAKE_SYSROOT}/usr/lib/riscv64-linux-gnu")

# ensure pkg-config searches in target directories
set(ENV{PKG_CONFIG_DIR} "")
set(ENV{PKG_CONFIG_LIBDIR} "${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig:${CMAKE_SYSROOT}/usr/lib/riscv64-linux-gnu/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "${CMAKE_SYSROOT}")

# search for program binaries in the Host's directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER CACHE STRING "")
# for libraries and headers in the Target's directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# the CMAKE_FIND_ROOT_PATH_MODE_PROGRAM variables don't seem to work - binaries are still found in Target not Host.
# Use this to ignore binaries from the Target sysroot:
set(CMAKE_SYSTEM_IGNORE_PATH "${CMAKE_SYSROOT}/usr/bin;${CMAKE_SYSROOT}/usr/sbin;${CMAKE_SYSROOT}/bin;${CMAKE_SYSROOT}/sbin")

