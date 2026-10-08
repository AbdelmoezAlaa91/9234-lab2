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

