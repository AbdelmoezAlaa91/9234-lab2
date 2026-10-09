#!/bin/bash

if [ $# -ne 2 ]; then
echo "you should enter 2 parameters"
exit 1
fi

if [ ! -d "$1" ] || [ ! -d "$2" ]; then
echo " directories are not found"
exit 1
fi

dir="$1"
malicious_dir="$2"


while true ; do

count=$( ls -1 "$malicious_dir" | wc -l)
if [ "$count" -eq 0 ]; then

echo "No malicious files to review."
exit 1

fi

files=()
i=1

for item in "$malicious_dir"/*; do

file_name=$(basename "$item")
echo "$i : $file_name"
files+=("$item")
i=$((i + 1))

done


echo "enter a number: "
read number
echo ""
echo ""

echo "1:Restore this file back into dir"
echo "2:Permanently delete this file from malicious_dir (it was genuinely malicious)"
echo "3: Leave this file as-is and go back to the list"

echo ""
echo ""

echo "enter your choice 1-3"
read choice
echo ""
echo ""

selected_file="${files[number-1]}"
file_name=$(basename "$selected_file")



if [ "$choice" -eq 1 ]; then 
echo "$file_name" >> whitelist.txt
mv "$malicious_dir/$file_name" "$dir/"
echo "Restored $file_name to $dir."

elif [ "$choice" -eq 2 ]; then
rm "$malicious_dir/$file_name"
echo "$file_name deleted permanently."

elif [ "$choice" -eq 3 ]; then 
continue

else 
echo "invalid choice"

fi

done

