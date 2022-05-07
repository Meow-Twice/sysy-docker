#!/bin/bash

if [ $1 ]; then
    REALPATH=$(realpath $1)
    MOUNT_OPTION="-v $REALPATH:/root/sysy"
    echo "Mount $REALPATH to /root/sysy"
else
    MOUNT_OPTION=
fi


docker run -dit --name=sysy --hostname=sysy --restart=always $MOUNT_OPTION sysy:latest /bin/bash
