FROM ubuntu:20.04
ENV ARCH=aarch64
ENV CLANG_ARCH_FLAGS="--target=${ARCH}-linux-gnu --sysroot=/usr/${ARCH}-linux-gnu"
ENV CLANG_LINK_FLAGS="-fuse-ld=lld -static"
# Install necessary software

ARG PACKAGES="clang llvm lld gcc-${ARCH}-linux-gnu binutils-${ARCH}-linux-gnu qemu-system-${ARCH} qemu-user"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y tzdata && \
    { apt-get install -y ${PACKAGES}; apt-get install -y --fix-missing ${PACKAGES}; }
# Load sysy library
ENV SYLIB_PATH=/usr/share/sylib
COPY sylib/* ${SYLIB_PATH}/
RUN clang -emit-llvm -S ${SYLIB_PATH}/sylib.c -o ${SYLIB_PATH}/sylib.ll && \
    clang --target=${ARCH}-linux-gnu --sysroot=/usr/${ARCH}-linux-gnu -c ${SYLIB_PATH}/sylib.c -o ${SYLIB_PATH}/sylib.o && \
    llvm-ar rcs ${SYLIB_PATH}/sylib.a ${SYLIB_PATH}/sylib.o
# Load sysy scripts
COPY scripts/sysy* /usr/bin/
RUN chmod +x /usr/bin/sysy*.sh

WORKDIR /root
