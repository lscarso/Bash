#!/bin/sh

function SetProgram {
	if [ "$1" = "2" ]; then
		v4lctl setchannel 23
	fi
	if [ "$1" = "3" ]; then
		v4lctl setchannel 35
	fi
	if [ "$1" = "4" ]; then
		v4lctl setchannel 45
	fi
	if [ "$1" = "5" ]; then
		v4lctl setchannel 56
	fi
	if [ "$1" = "6" ]; then
		v4lctl setchannel 49
	fi
	if [ "$1" = "7" ]; then
		v4lctl setchannel 41
	fi
	echo "Programma : $1"
}

gst-launch-0.10 -v v4l2src device=/dev/video0 ! autovideosink &
v4lctl setchannel 56
v4lctl volume mute off

Prognum=5
while :
do
	read ConvType
	if [ "$ConvType" = "2" ]; then
		SetProgram 2
		Prognum=2
	fi
	if [ "$ConvType" = "3" ]; then
		SetProgram 3
		Prognum=3
	fi
	if [ "$ConvType" = "4" ]; then
		SetProgram 4
		Prognum=4
	fi
	if [ "$ConvType" = "5" ]; then
		SetProgram 5
		Prognum=5
	fi		
	if [ "$ConvType" = "6" ]; then
		SetProgram 6
		Prognum=6
	fi
	if [ "$ConvType" = "7" ]; then
		SetProgram 7
		Prognum=7
	fi
	if [ "$ConvType" = "q" ]; then
		v4lctl volume mute on	
		exit
	fi
	if [ "$ConvType" = "+" ]; then
		if [ "$Prognum" = "7" ]; then
			Prognum=2
		else
			Prognum=$((Prognum + 1))
		fi
		SetProgram $Prognum
	fi
	if [ "$ConvType" = "-" ]; then
		if [ "$Prognum" = "2" ]; then
			Prognum=7
		else
			Prognum=$((Prognum - 1))
		fi
		SetProgram $Prognum
	fi

done


