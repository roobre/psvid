PARTSIZE=7

if [ -z $1 ]; then
    echo "Usage: $0 in_file" >&2
    exit 1
fi

if [ ! -f $1 ]; then
    echo "Could not find $1" >&2
    exit 1
fi

duration=$(ffprobe -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1 2>/dev/null)

if [ -z $duration ]; then
    echo "Could not get file duration" >&2
    exit 1
fi

# Now in minutes
duration=$((${duration%.*}/60))

i=0
while [[ $duration -gt 0 ]]; do
    ffmpeg -ss "$((PARTSIZE*i)):00" -i "$1" -t $PARTSIZE:00 -c:a copy -c:v copy "${1%.*}.part$((i+1)).${1##*.}"
    i=$((i+1))
    duration=$((duration-PARTSIZE))
done
