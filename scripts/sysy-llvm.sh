#!/bin/bash

# Generate LLVM IR from source code.

if ! [ $1 ]; then
    echo "please specify code file." > /dev/stderr
    exit 1
fi

CODE_FILE=$1

NAME="${CODE_FILE%.*}"
SUFFIX="${CODE_FILE##*.}"

if [ $SUFFIX == "c" -o $SUFFIX == "sy" ]; then
    SOURCE="${NAME}.sy.c"
    echo '#include "sylib.h"' > $SOURCE
    cat $CODE_FILE >> $SOURCE
else
    echo "code file must ends with '.sy' or '.c'" > /dev/stderr
    exit 1
fi

clang ${SYLIB_INCLUDE_FLAG} -emit-llvm -S -o $NAME.ll $SOURCE
