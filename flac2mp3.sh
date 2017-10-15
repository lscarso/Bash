#!/bin/bash
# need gstreamer with flac and lame plugins

if [ -z "$1" ] || [ -z "$2"]
then
	echo "USAGE: flac2mp3 [Input Dir] [output Dir]"
	exit
fi

INPUT_DIR="$1*.flac"
OUT_DIR="$2"

echo "Input Directory : $INPUT_DIR"
echo "Export Directory: $OUT_DIR"

[ ! -d ${OUT_DIR} ] && mkdir -p ${OUT_DIR}

for x in $INPUT_DIR
do

FLAC=$x
echo "File : $FLAC"
MP3=`basename "${FLAC%.flac}.mp3"`

[ -r "$FLAC" ] || { echo can not read file \"$FLAC\" >&1 ; exit 1 ; } ;

echo "Converting ${FLAC} to MP3 format"

gst-launch-0.10 filesrc location="$FLAC" ! flacdec ! audioconvert ! lame vbr=0 bitrate=320 ! id3mux name=tag ! filesink location=${OUT_DIR}/"$MP3"

done
