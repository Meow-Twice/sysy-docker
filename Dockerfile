FROM ubuntu:20.04
ENV ARCH=mips
ENV ARCH_NAME="${ARCH}-linux-gnu"

# Install necessary software

ARG PACKAGES="vim clang llvm lld gcc-${ARCH_NAME} binutils-${ARCH_NAME} gcc-multilib-${ARCH_NAME} gdb-multiarch qemu-system-${ARCH} qemu-user"

RUN sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y tzdata && \
    apt-get install -y ${PACKAGES}

# setup compile flags
ENV CLANG_ARCH_FLAGS="--target=${ARCH_NAME} --sysroot=/usr/${ARCH_NAME} -m32"
ENV CLANG_LINK_FLAGS="-fuse-ld=lld -static"
ENV GCC_COMPILE_FLAGS="-march=mips32r5 -mgp32 -mno-branch-likely -mno-explicit-relocs -fno-stack-protector -mno-check-zero-division"

# Load sysy library
ENV SYLIB_PATH=/usr/share/sylib
ENV SYLIB_INCLUDE_FLAG="-I${SYLIB_PATH}"
COPY sylib/* ${SYLIB_PATH}/
RUN clang -emit-llvm -S ${SYLIB_PATH}/sylib.c -o ${SYLIB_PATH}/sylib.ll && \
    clang ${CLANG_ARCH_FLAGS} -c ${SYLIB_PATH}/sylib.c -o ${SYLIB_PATH}/sylib.o && \
    llvm-ar rcs ${SYLIB_PATH}/sylib.a ${SYLIB_PATH}/sylib.o
# Load sysy scripts
COPY scripts/sysy* /usr/bin/
RUN chmod +x /usr/bin/sysy*.sh

WORKDIR /root
# Copy Sample
COPY sample/* /root/