# DVD9 to DVD5 (dvd925)
YOU NEED Transcode > 0.6.11 (because of "tcrequant")

## Rip the Audio and the Video:
tccat -i /dev/dvd -T t -L | tcextract -t vob -x mpeg2 > ofile.m2v 
tccat -i /dev/dvd -T t -L | tcextract -t vob -x ac3 -a 0 > ofile.ac3 

("-a" select the Audiotrack (English/Italian...") 

## Refactor
Now you know the Size of the Video and Audio. For a DVD we can use 4482Mbyte - but because "dvdauthor" and "mplex" adds some MByte, we can only use ~4300Mbyte 
### Calculate the "requantfactor" (for shrinking):
Videosize / (4300 - Audiosize) = requantfactor 
e.g.: 4500 / (4300 - 350) = 1.13924050632911392405

### Shrink the Video:
tcrequant -i ofile.m2v -o movie.m2v -f 1.13924050632911392405

## Multiplexing the Audiotrack and the Videotrack:
tcmplex -i movie.m2v -p ofile.ac3 -m d -o movie-new.vob

or

mplex -f 8 -o movie-new.vob  movie.m2v ofile.ac3

## Make the DVD structure
dvdauthor -t -a ac3+en -o movie-dvd movie-new.vob

## Make IFO File
dvdauthor -T -o movie-dvd

## Burn
growisofs -Z /dev/scd0 -dvd-video -udf movie-dvd
