#!/bin/bash

COMMONFLAGS="-r 30 -vf scale=-1:720"
MP4FLAGS="-c:a aac -b:a 192k -c:v libx264 -preset veryslow -tune film -movflags empty_moov+default_base_moof+frag_keyframe"
WEBMFLAGS="-speed 1 -threads 4 -keyint_min 150 -g 150 -tile-columns 4 -frame-parallel 1 -f webm -c:a libvorbis"

FFMPEGFLAGS=(\
    "$MP4FLAGS -crf 23 -profile:v main     -level 3.1"\
    "$MP4FLAGS -crf 24 -profile:v baseline -level 3.1"\
    "-c:v libvpx-vp9 -crf 34 -b:v 0  $WEBMFLAGS"\
)

EXTENSIONS=(\
    ".main.mp4"\
    ".baseline.mp4"\
    ".vp9.webm"\
)

MIMES=(\
    'video/mp4; codecs="avc1.4D401E, mp4a.40.2"'\ # Main 3.X
    'video/mp4; codecs="avc1.42E01E, mp4a.40.2"'\ # Baseline 3.X
    'video/webm; codecs="vp9, vorbis"'\
)

PRIORITIES=(\
    1200\
    1100\
    1300\
)

if [ -z $1 ]; then
    echo "Usage: $0 in_file" >&2
    exit 1
fi

if [ ! -f $1 ]; then
    echo "Could not find $1" >&2
    exit 1
fi

videoname=$(basename -- "$1")
outfolder="${videoname%.*}"

mkdir -p $outfolder

echo -n '' > $outfolder/mimes.txt

for (( i = 0; i < ${#FFMPEGFLAGS[@]}; i++ )); do
    ffmpeg -i "$1" $COMMONFLAGS ${FFMPEGFLAGS[$i]} $outfolder/$outfolder${EXTENSIONS[$i]}
    echo "${EXTENSIONS[$i]}: ${MIMES[$i]}" >> $outfolder/mimes.txt
done

exit 0
