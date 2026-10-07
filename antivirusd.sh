#!/bin/bash

if [ $# -ne 3 ]; then
echo "you should enter 3 parameters"
exit 1
fi

dir="$1"
malicious_dir="$2"
interval_secs="$3"

extension=("exe" "bat" "vbs" "scr" "ps1")
content=("virus" "trojan" "malware" "worm" "ransomware")

if [ ! -d "$1" ] || [ ! -d "$2" ]; then
echo " directories are not found"
exit 1
fi
