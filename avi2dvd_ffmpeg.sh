#!/bin/sh

if [ "$1" = "" ]; then
	echo "avi2dvd [file da convertire] [Titolo]"
	exit 0
else
	echo "Starting $1 Conversion..."
	echo "TITLE    : $2"
fi

WORKDIR="./temp/"

ffmpeg -i $1 -target pal-dvd $WORKDIR/$2.ffmpeg.mpg

if [ "$?" != "0" ]; then
	echo "Stopped with error:" $?
	exit $?
fi

./avi2dvd.sh $WORKDIR/$2.ffmpeg.mpg $2 0

echo "This is the END"
