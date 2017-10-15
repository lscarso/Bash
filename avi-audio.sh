#!/bin/sh

if [ "$1" = "" ]; then
	echo "avi-audio [file da convertire] [Traccia audio]"
	exit 0
else
	echo "Starting $1 Conversion..."
	echo "Audio Track    : $2"
fi

WORKDIR="./temp/"

ffmpeg -i $1 -sameq -map 0:0 -map 0:$2 $WORKDIR/$1-ita.avi

if [ "$?" != "0" ]; then
	echo "Stopped with error:" $?
	exit $?
fi

echo "This is the END"
