#!/bin/bash

MP4FLAGS="-c:a aac -b:a 192k -c:v libx264 -preset slower -movflags empty_moov+default_base_moof+frag_keyframe"
WEBMFLAGS="-c:a libvorbis"

FFMPEGFLAGS=(\
    "$MP4FLAGS -crf 20 -profile:v main     -level 3.1 "\
    "$MP4FLAGS -crf 22 -profile:v baseline -level 3.1"\
    "-c:v libvpx-vp9 -crf 31 -b:v 0  $WEBMFLAGS"\
    "-c:v libvpx     -crf 10 -b:v 4M $WEBMFLAGS"\
)

EXTENSIONS=(\
    ".main.mp4"\
    ".baseline.mp4"\
    ".vp9.webm"\
    ".vp8.webm"\
)

MIMES=(\
    'video/mp4; codecs="avc1.4D401E, mp4a.40.2"'\ # Main 3.X
    'video/mp4; codecs="avc1.42E01E, mp4a.40.2"'\ # Baseline 3.X
    'video/webm; codecs="vp9, vorbis"'\
    'video/webm; codecs="vp8, vorbis"'\
)

PRIORITIES=(\
    1300\
    1200\
    1100\
    1000\
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
    ffmpeg -i "$1" ${FFMPEGFLAGS[$i]} $outfolder/$outfolder${EXTENSIONS[$i]}
    echo "${EXTENSIONS[$i]}: ${MIMES[$i]}" >> $outfolder/mimes.txt
done

exit 0
