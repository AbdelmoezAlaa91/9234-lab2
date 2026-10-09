#!/bin/bash

if [ $# -ne 2 ]; then
echo "you should enter 2 parameters"
exit 1
fi

dir="$1"
malicious_dir="$2"

extension=("exe" "bat" "vbs" "scr" "ps1")
content=("virus" "trojan" "malware" "worm" "ransomware")

if [ ! -d "$1" ] || [ ! -d "$2" ]; then
echo " directories are not found"
exit 1
fi

scan(){
for file in "$dir"/*; do

is_malicioused=false
filename=$(basename "$file")
ext="${filename##*.}"

if grep -qxF "$filename" "whitelist.txt"; then
continue;
fi


for item in "${extension[@]}"; do
if [ "$item" = "$ext" ]; then

cp "$dir/$filename" "$malicious_dir/"
rm "$dir/$filename"

is_malicioused=true

break
fi

done

if [ "$is_malicioused" = true ]; then
continue 
fi

for item in "${content[@]}"; do

if grep -qi "$item" "$file"; then
cp "$dir/$filename" "$malicious_dir/"
rm "$dir/$filename"

break

fi 

done

done
}

scan
