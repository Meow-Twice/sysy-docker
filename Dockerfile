FROM ubuntu:20.04
ENV ARCH=arm
ENV ARCH_NAME="arm-linux-gnueabi"
ENV CLANG_ARCH_FLAGS="--target=${ARCH_NAME} --sysroot=/usr/${ARCH_NAME} -m32"
ENV CLANG_LINK_FLAGS="-fuse-ld=lld -static"
# Install necessary software

ARG PACKAGES="clang llvm lld gcc-${ARCH_NAME} binutils-${ARCH_NAME} gcc-multilib-${ARCH_NAME} qemu-system-${ARCH} qemu-user"

RUN sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y tzdata && \
    { apt-get install -y ${PACKAGES}; apt-get install -y --fix-missing ${PACKAGES}; }
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
