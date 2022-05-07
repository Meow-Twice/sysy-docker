#!/bin/bash

# Generate ELF from .sy/.c or .S

if ! [ $1 ]; then
    echo "please specify code file." > /dev/stderr
    exit 1
fi

CODE_FILE=$1

NAME="${CODE_FILE%.*}"
SUFFIX="${CODE_FILE##*.}"

if [ $SUFFIX == "c" -o $SUFFIX == "S" ]; then
    SOURCE=$CODE_FILE
elif [ $SUFFIX == "sy" ]; then
    SOURCE="${NAME}_sy.c"
    cat $CODE_FILE > $SOURCE
else
    echo "code file must ends with '.sy', '.c' (source) or '.S' (assembly)" > /dev/stderr
    exit 1
fi

clang ${CLANG_ARCH_FLAGS} ${CLANG_LINK_FLAGS} -o $NAME.elf $SOURCE ${SYLIB_PATH}/sylib.a
