#!/bin/bash

# Run LLVM IR with sylib linked

if ! [ $1 ]; then
    echo "please specify LLVM IR file." > /dev/stderr
    exit 1
fi

IR_FILE=$1

NAME="${IR_FILE%.*}"
SUFFIX="${IR_FILE##*.}"

if ! [ $SUFFIX == "ll" ]; then
    echo "LLVM IR file name must ends with .ll" > /dev/stderr
    exit 1
fi

llvm-link $IR_FILE $SYLIB_PATH/sylib.ll -o $NAME.sylib.bc
lli $NAME.sylib.bc