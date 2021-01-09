#!/bin/bash

while [[ $# -gt 0 ]]
  do
    key="$1"

    case $key in
    -b|--bssid)
    BSSID="$2"
    shift
    shift
    ;;
    -c|--channel)
    CHANNEL="$2"
    shift
    shift
    ;;
    -e|--essid)
    ESSID="$2"
    shift
    shift
    ;;
    --default)
    DEFAULT=YES
    shift
    ;;
    *) # unknown option
    UNK+=("$1") # save it in array for later
    shift
    ;;
    esac
    done

# disassociate
sudo airport -z

# set the channel
# DO NOT PUT SPACE BETWEEN -c and the channel
# for example sudo airport -c6
sudo airport -c$CHANNEL

# capture a beacon frame from the AP
sudo tcpdump "type mgt subtype beacon and ether src $BSSID" -I -c 1 -i en0 -w beacon.cap

# wait for the WPA handshake
sudo tcpdump "ether proto 0x888e and ether host $BSSID" -I -U -vvv -i en0 -w handshake.cap

# merge the two files
mergecap -a -F pcap -w "$ESSID-$BSSID-$CHANNEL.cap" beacon.cap handshake.cap

# del beacon n handshake
rm handshake.cap beacon.cap
