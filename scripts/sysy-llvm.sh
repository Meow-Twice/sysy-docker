#!/bin/bash

# Generate LLVM IR from source code.

if ! [ $1 ]; then
    echo "please specify code file." > /dev/stderr
    exit 1
fi

CODE_FILE=$1

NAME="${CODE_FILE%.*}"
SUFFIX="${CODE_FILE##*.}"

if [ $SUFFIX == "c" ]; then
    SOURCE=$CODE_FILE
elif [ $SUFFIX == "sy" ]; then
    SOURCE="${NAME}_sy.c"
    cat $CODE_FILE > $SOURCE
else
    echo "code file must ends with '.sy' or '.c'" > /dev/stderr
    exit 1
fi

clang -emit-llvm -S -o $NAME.ll $SOURCE
