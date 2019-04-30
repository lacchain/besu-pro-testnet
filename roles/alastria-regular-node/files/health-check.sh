#!/bin/bash

RETVAL=""
    while [ "$RETVAL" == "" ]
    do

        RETVAL="$(ss -nutlp | grep 9000)"
        [ "$RETVAL" != "" ] && echo "[*] constellation node at 9000 is now up." && systemd-notify READY=1
        [ "$RETVAL" == "" ] && echo "[*] constellation node at 9000 is still starting. Awaiting 5 seconds." && sleep 5

    done
