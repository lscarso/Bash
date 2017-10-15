#!/bin/sh

FILENAME="$1"
MKVFILE=$FILENAME."mkv"

if [ $# -eq 0 ]
then
	echo "Usage: $0 <input File>" 1>&2
	exit 1
fi


echo "Converting (video) Data..."
if [ -e "$MKVFILE" ]; then
	echo "$MKVFILE exists!"
else
	ffmpeg -i "$FILENAME" -vcodec libx264 -sameq -b 800k -g 200 -bf 2 -acodec libmp3lame -ab 128k -f matroska $MKVFILE

	if [ $? -ne 0 ]; then
		echo "Failed to covert $FILENAME to $MKVFILE" 1>&2
		rm $MKVFILE 2>/dev/null 1>&2
		exit 1
	fi
fi

