#!/bin/sh

if [ "$1" = "" ]; then
	echo "avi2dvd [file da convertire] [Titolo] [Lingua]"
	exit 0
else
	echo "Starting $1 Conversion..."
	echo "TITLE    : $2"
	echo "Language : $3"
fi

WORKDIR="./temp/"

transcode -i $1 -y ffmpeg --export_prof dvd-pal --export_asr 3 -o $WORKDIR/$2 -D0 -s2 -m $WORKDIR/$2.ac3 -J modfps=clonetype=3 --export_fps 25 -a$3 

if [ "$?" != "0" ]; then
	echo "Stopped with error:" $?
	exit $?
fi

M2VSIZE=`ls -l "$WORKDIR/$2.m2v" | awk '{print $5}'`
AC3SIZE=`ls -l "$WORKDIR/$2.ac3" | awk '{print $5}'`
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
	tcrequant -i "$WORKDIR/$2.m2v" -o "$WORKDIR/$2.shrink.m2v" -f "$FACTOR"

	if [ $? -ne 0 ]; then
		echo "Failed to tcrequant/shrink $WORKDIR/$2.m2v to $WORKDIR/$2.shrink.m2v using factor $FACTOR" 1>&2
		rm $WORKDIR/$2.shrink.m2v 2>/dev/null 1>&2
		exit 1
	fi

	M2VNEWFILE=$WORKDIR/$2.shrink.m2v
	rm $WORKDIR/$2.m2v
else
	echo "Not Shrinking M2V (video) File"
	M2VNEWFILE=$WORKDIR/$2.m2v
fi


mplex -f 8 -o $WORKDIR/$2.mpg $M2VNEWFILE $WORKDIR/$2.ac3 

if [ "$?" != 0 ]; then
	echo "Stopped with error:" $?
	exit $?
fi

rm $M2VNEWFILE && rm $WORKDIR/$2.ac3

dvdauthor -o dvd -t $WORKDIR/$2.mpg 

if [ "$?" != 0 ]; then
	echo "Stopped with error:" $?
	exit $?
fi

dvdauthor -o dvd -T

echo "The DVD image is ready."
echo "Are you ready to start writing DVD [Y/n]?"
read ready

if [ "$ready" = "n" ]; then
	echo "Cancelled, exiting.."
	exit 0
fi
if [ "$ready" = "N" ]; then
	echo "Cancelled, exiting.."
	exit 0
fi
gnome-mount -u -d /dev/sr1
growisofs -dvd-compat -Z /dev/sr1 -dvd-video -V $2 ./dvd
