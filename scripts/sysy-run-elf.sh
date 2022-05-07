#!/bin/bash

# Run aarch64 ELF

if ! [ $1 ]; then
    echo "please specify ELF file of ${ARCH} to run." > /dev/stderr
    exit 1
fi

ELF=$1

qemu-${ARCH} $ELF
