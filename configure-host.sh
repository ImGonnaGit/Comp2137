#!/bin/bash

trap '' TERM HUP INT

VERBOSE=0

if [ "$1" == "-verbose" ]; then
    VERBOSE=1
    shift
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        -name)
            NAME="$2"
            shift
            ;;
        -ip)
            IP="$2"
            shift
            ;;
        -hostentry)
            HOSTNAME="$2"
            HOSTIP="$3"
            shift 2
            ;;
        *)
            echo "Unnown option: $1"
            exit 1
            ;;
    esac
    shift
done

#HostN
if [ ! -z "$NAME" ]; then
    if [ "$(hostname)" != "$NAME" ]; then
        echo "$NAME" > /etc/hostname
        sed -i "s/$(hostname)/$NAME/" /etc/hosts
        hostname "$NAME"
        if [ $VERBOSE -eq 1 ]; then
            echo "Hostname changed to $NAME"
        fi
        logger "Hostname updated to $NAME"
    elif [ $VERBOSE -eq 1 ]; then
        echo "Hostname is already $NAME"
    fi
fi

#IP
if [ ! -z "$IP" ]; then
    if ! grep -q "$IP" /etc/hosts; then
        sed -i "s/$(hostname -I)/$IP/" /etc/hosts
        if [ $VERBOSE -eq 1 ]; then
            echo "IP address now  $IP"
        fi
        logger "IP updated to $IP"
    elif [ $VERBOSE -eq 1 ]; then
        echo "IP is already $IP"
    fi
fi

#HostN
if [ ! -z "$HOSTNAME" ] && [ ! -z "$HOSTIP" ]; then
    if ! grep -q "$HOSTNAME" /etc/hosts; then
        echo "$HOSTIP $HOSTNAME" >> /etc/hosts
        if [ $VERBOSE -eq 1 ]; then
            echo "Added host: $HOSTIP $HOSTNAME"
        fi
        logger "Added host: $HOSTIP $HOSTNAME"
    elif [ $VERBOSE -eq 1 ]; then
        echo "Host already exists: $HOSTNAME"
    fi
fi

if [ $VERBOSE -eq 1 ]; then
    echo "Script compleeted."
fi
