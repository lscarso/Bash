#!/bin/sh

if [ "$1" = "" ]; then
	TITLE=1
else
	TITLE=$1
fi

MOVIE=`dvdbackup -i /dev/sr0 -I 2> /dev/null | grep "DVD-Video information" | sed -e 's/.* //g'`

if [ "$MOVIE" = "" ]; then
	MOVIE="UNTITLED"
fi

echo "######################## $MOVIE #########################"

WORKDIR="/home/luca/Videos/temp/$MOVIE"
mkdir -p $WORKDIR
cd $WORKDIR

if [ -f film_sub.mpg ]; then
	echo "Reusing DVD MPEG file (with subtitles) $WORKDIR/film_sub.mpg."
else
	if [ -f $WORKDIR/video.m2v ]; then
		echo "Reusing the copy of the Video/Audio channels fot Title $TITLE in $WORKDIR."
	else
		if [ -f $WORKDIR/film.vob ]; then
			echo "The copy of the Title $TITLE already exist in $WORKDIR. Reusing it."
		else
			echo "Copying the Title $TITLE to $WORKDIR."
			tccat -t dvd -i /dev/sr0 -P $TITLE -d 0 2>/dev/null 1> $WORKDIR/film.vob
		fi
		
		mkfifo vid.fifo > /dev/null
		mkfifo aud.fifo > /dev/null
		
		echo "Extracting audio and video channels"
		tcextract -i vid.fifo -t vob -x mpeg2 -a 0xe0 > $WORKDIR/video.m2v &
		tcextract -i aud.fifo -t vob -x ac3 -a 1 > $WORKDIR/audio.ac3 &
		cat $WORKDIR/film.vob | tee vid.fifo aud.fifo > /dev/null

		rm vid.fifo
		rm aud.fifo
	fi
	if [ -f "$WORKDIR/sub/sub.xml" ]; then
		echo "Reusing subtitles for Title $TITLE in $WORKDIR/sub."
	else
		echo "Extracting subtitles.."

		mkdir -p $WORKDIR/sub
		cd $WORKDOR/sub
		rm -rf $WORKDIR/sub/*
		ifo_dump_dvdread /dev/sr0 $TITLE | grep Color | sed 's/Color ..: 00//' > palette.txt
		vobsub2pgm -o sub -f -p palette.txt ../film.vob
	fi
	
	cd $WORKDIR
	rm film.vob > /dev/null
	SIZE=`du -sm | cut -f 1`
	echo "Size without requanting is $SIZE Mb."

	if [ $SIZE -gt 4370 ]; then
		echo "Requanting the video channel.."
		cat video.m2v | tcrequant -f 1.5 > video_small.m2v;
		mv video_small.m2v video.m2v;
	else
		echo "Requanting video isn't required."
	fi

	if [ -f film.mpg ]; then
		echo "Reusing DVD MPEG file (without subtitles) $WORKDIR/film.mpg."
	else
		echo "Multiplexing audio and video.."
		mplex -V -f 8 -S 4370 -o film.mpeg video.m2v audio.ac3
		rm $WORKDIR/video.m2v
		rm $WORKDIR/audio.ac3
	fi

	echo "Mixing in the subtitles"
	cd $WORKDIR/sub
	spumux $WORKDIR/sub/sub.xml < $WORKDIR/film.mpg > $WORKDIR/film_sub.mpg
fi

if [ -f $WORKDIR/chapters.tm ]; then
	echo "Reusing existing chapters timing $WORKDIR/chapters.tm."
else
	echo "Extracting the chapters times"
	for i in `tcprob -H 10 -i /dev/dvd 2>&1 | grep Chapter | cut -d " " -f 4 | sed s/\\\.\\.\\*/,/`;do echo -n $i; done | sed s/,$// > $WORKDIR/chapters.tm
	eject
	echo "Completed ripping DVD. Plese put the DVD+/-RW disk in."
fi

dvddirdel -o $WORKDIR/out

echo "Creating the DVD structure.."

dvdauthor -c `cat $WORKDIR/chapters.tm` -o $WORKDIR/out $WORKDIR/film_sub.mpg
dvdauthor -o $WORKDIR/out -T

cd ..

echo "Creating the DVD image.."

mkisofs -dvd-video -o $WORKDIR/image.raw $WORKDIR/out

echo "The DVD image is ready."
echo "Are ypu ready to start writing DVD [Y/n]?"
read ready

if [ "$ready" = "n" ]; then
	echo "Cancelled, existing.."
	exit 0
fi

if [ "$ready" = "N" ]; then
	echo "Cancelled, existing.."
	exit 0
fi

gnome-mount -u -d /dev/sr0
growisofs -dvd-compat -Z /dev/sr0=$WORKDIR/image.raw

echo "The DVD is copied."
echo "Do you want to erase the temporary files [Y/n]?"
read eraseTemp

if [ "$eraseTemp" = "" ]; then
	eraseTemp = "Y"
fi
if [ "$eraseTemp" = "n" ]; then
	echo "Exiting.."
	exit 0
fi

if [ "$eraseTemp" = "N" ]; then
	echo "Exiting.."
	exit 0
fi

echo "Cleaning up temporary files..."
rm -rf $WORKDIR
