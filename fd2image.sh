#!/bin/sh

if [ "$1" = "" ]; then
	echo "floppy2image [nome file]"
	exit 0
else
	echo "Starting $1 Creation..."
fi

count=0
while :
do
	count=$((count + 1))
	echo "Inserire Floppy e premere un tasto. [q] per terminare"
	read ConvType
	if [ "$ConvType" = "q" ]; then
		exit
	fi	
	str1="-";str2=".img"	
	strNomeFile="$1$str1$count$str2"
	echo $strNomeFile
	dd if=/dev/fd0 of=$strNomeFile count=1 bs=1440k
done


