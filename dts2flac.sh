#!/bin/bash

if [ -z "$1" ] || [ -z "$2"]
then
	echo "USAGE: dts2flac [Input Dir] [output Dir]"
	exit
fi

INPUT_DIR="$1*.wav"
OUT_DIR="$2"

echo "Input Directory : $INPUT_DIR"
echo "Export Directory: $OUT_DIR"

[ ! -d ${OUT_DIR} ] && mkdir -p ${OUT_DIR}

for x in $INPUT_DIR
do

WAV=$x
echo "File : $WAV"
FLAC=`basename "${WAV%.wav}.flac"`

[ -r "$WAV" ] || { echo can not read file \"$WAV\" >&1 ; exit 1 ; } ;

echo "Converting ${WAV} to FLAC format"

gst-launch-0.10 filesrc location="$WAV" ! dtsdec ! audioconvert ! audio/x-raw-int,channels=6 ! flacenc ! id3mux name=tag ! filesink location=${OUT_DIR}/"$FLAC"

done
