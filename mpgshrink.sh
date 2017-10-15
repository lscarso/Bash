#!/bin/sh

FILENAME=$1
VOBFILE=$FILENAME
M2VFILE=$FILENAME."m2v"
M2VSHRINKFILE=$FILENAME."shrink.m2v"
AC3FILE=$FILENAME."ac3"
OUTPUTFILE=$FILENAME."%d.mpg"
XMLFILE=$FILENAME."xml"

# Put your original DVD in your DVD drive and run vobcopy. This will rip 
# the first movie segment, called a title, on the DVD. This is the default.
# vobcopy -l

# On rare occasions the default title will not be the movie. Try ripping 
# higher titles until you find the movie. You can specify which title to 
# rip when running vobcopy. For example you might want to rip the second 
# title on the DVD.
# vobcopy -l -n 2

if [ $# -eq 0 ]
then
	echo "Usage: $0 <input MPG File> [audio track]" 1>&2
	exit 1
fi

if [ ! -e "$VOBFILE" ]
then
	echo "Error: $VOBFILE does not exist" 1>&2
	exit 1
fi

AUDIO_TRACK=$2
if [ "$AUDIO_TRACK" == "" ]; then
	AUDIO_TRACK=0
fi

echo "Extracting MPEG2 (video) Data..."
if [ -e "$M2VFILE" ]; then
	echo "$M2VFILE exists, skipping tcextract of it again"
else
	tcextract -i "$VOBFILE" -x mpeg2 > "$M2VFILE"

	if [ $? -ne 0 ]; then
		echo "Failed to tcextract $VOBFILE to $M2VFILE" 1>&2
		rm $M2VFILE 2>/dev/null 1>&2
		exit 1
	fi
fi

echo "Extracting AC3 (audio) Data..."
if [ -e "$AC3FILE" ]; then
	echo "$AC3FILE exists, skipping tcextract of it again"
else
	tcextract -i "$VOBFILE" -x ac3 -a "$AUDIO_TRACK" > "$AC3FILE"

	if [ $? -ne 0 ]; then
		echo "Failed to tcextract $VOBFILE to $AC3FILE" 1>&2
		rm $AC3FILE 2>/dev/null 1>&2
		exit 1
	fi
fi

M2VSIZE=`ls -l "$M2VFILE" | awk '{print $5}'`
AC3SIZE=`ls -l "$AC3FILE" | awk '{print $5}'`
FACTOR=`echo "scale=2; ( $M2VSIZE / ( 4600000000 - $AC3SIZE ) ) * 1.04" | bc`
COMPAREFACTOR=`echo "$FACTOR * 100" | bc | awk -F. '{print $1}'`

echo "M2V Size (video): $M2VSIZE"
echo "AC3 Size (audio): $AC3SIZE"
echo "Compare Factor: $COMPAREFACTOR"
echo "Factor: $FACTOR"

# shrink the file using this command if required
if [ "$COMPAREFACTOR" -gt "100" ]; then

	# figure out the new factor by dividing by 100
	echo "Shrinking M2V (video) File..."
	tcrequant -i "$M2VFILE" -o "$M2VSHRINKFILE" -f "$FACTOR"

	if [ $? -ne 0 ]; then
		echo "Failed to tcrequant/shrink $M2VFILE to $M2VSHRINKFILE using factor $FACTOR" 1>&2
		rm $M2VSHRINKFILE 2>/dev/null 1>&2
		exit 1
	fi

	M2VNEWFILE=$M2VSHRINKFILE
else
	echo "Not Shrinking M2V (video) File"
	M2VNEWFILE=$M2VFILE
fi

# join up the sound with the movie
if [ -e "$FILENAME".*.mpg ]; then
	echo "$FILENAME.*.mpg already exists, skipping mplex"
else
	mplex -f 8 -o "$OUTPUTFILE" "$M2VNEWFILE" "$AC3FILE"

	if [ $? -ne 0 ]; then
		echo "Failed to Multiplex $M2VNEWFILE and $AC3FILE to $OUTPUTFILE, quitting..." 1>&2
		rm $FILENAME.*.mpg $XMLFILE 2>/dev/null 1>&1
		exit 1
	fi
fi

echo "dvdauthor -o dvd -t $OUTPUTFILE"
echo "dvdauthor -o dvd -T"
echo .
echo "gnome-mount -u -d /dev/sr1"
echo "growisofs -dvd-compat -Z /dev/sr1 -dvd-video ./dvd"
