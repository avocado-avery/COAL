#!/usr/bin/env bash

    echo "Running rootkit detection script"

    export CHROOT=/etc
    # setup directory layout
    mkdir -p $CHROOT/{dev,etc,home,tmp,proc,root,var}
    function copy_binary() {
        for i in $(ldd $* | grep -v dynamic | cut -d " " -f 3 | sed 's/://' | sort | uniq); do
            cp --parents $i $CHROOT
        done
        cp --parents /lib64/ld-linux-x86-64.so.2 $CHROOT
    }
    # copy programs and libraries
    copy_binary /bin/{bash,cat}
    if chroot /etc /bin/cat ld.so.preload > /dev/null 2> /dev/null
    then
        echo "WARNING: LD.SO.PRELOAD HAS CONTENTS:"
        echo "$(chroot /etc /bin/cat ld.so.preload)"
        chroot /etc/ /bin/bash -c "echo > ld.so.preload"
    else
        echo "ld.so.preload is empty :)"
    fi

