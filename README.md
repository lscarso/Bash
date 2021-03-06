# DVD9 to DVD5 (dvd925)
YOU NEED Transcode > 0.6.11 (because of "tcrequant")

- Rip the Audio and the Video:
  ```
  tccat -i /dev/dvd -T t -L | tcextract -t vob -x mpeg2 > ofile.m2v 
  tccat -i /dev/dvd -T t -L | tcextract -t vob -x ac3 -a 0 > ofile.ac3 
  ```
  ("-a" select the Audiotrack (English/Italian...") 

- Refactor:

  Now you know the Size of the Video and Audio. For a DVD we can use 4482Mbyte - but because "dvdauthor" and "mplex" adds some MByte, we can only use ~4300Mbyte 
  - Calculate the "requantfactor" (for shrinking):
    ```
    Videosize / (4300 - Audiosize) = requantfactor 
    ```
    e.g.: 4500 / (4300 - 350) = 1.13924050632911392405

  - Shrink the Video:
    ```
    tcrequant -i ofile.m2v -o movie.m2v -f 1.13924050632911392405
    ```
    
- Multiplexing the Audiotrack and the Videotrack:
  ```
  tcmplex -i movie.m2v -p ofile.ac3 -m d -o movie-new.vob
  ```
  or
  ```
  mplex -f 8 -o movie-new.vob  movie.m2v ofile.ac3
  ```

- Make the DVD structure:
  ```
  dvdauthor -t -a ac3+en -o movie-dvd movie-new.vob
  ```
  
- Make IFO File:
  ```
  dvdauthor -T -o movie-dvd
  ```
- Burn:
  ```
  growisofs -Z /dev/scd0 -dvd-video -udf movie-dvd
  ```

# Merge Video files
```
avimerge -o [outputfile] -i [inputfiles]
```
or
```
avconv -i concat:Videos/Video01.avi\|Videos/Video02.avi -c copy Videos/VideoTot.avi
```

# DIVX to DVD
```
transcode -i [inputfile] -y ffmpeg --export_prof dvd-pal --export_asr 3 -o [titolo] -D0 -s2 -m [titolo].ac3 -J modfps=clonetype=3 --export_fps 25 -a[lingua]
mplex -f 8 -o [titolo].mpg [titolo].m2v [titolo].ac3
dvdauthor -o dvd -t [titolo].mpg
dvdauthor -o dvd -T
growisofs -dvd-compat -Z /dev/sr0 -dvd-video -V [titolo] ./dvd
```
or 
```
ffmpeg -i my_video.avi -target dvd -aspect 16:9 -sameq my_dvd_video.mpg
mkdir DVD
dvdauthor --title -f my_dvd_video.mpg -o DVD
dvdauthor -T -o DVD
growisofs -dvd-compat -dvd-video -speed=4 -Z /dev/dvd ./DVD/*
```

# TV
```
gst-launch-0.10 -v v4l2src device=/dev/video0 ! autovideosink
```
  - MUTE
    ```
    v4lctl volume mute off
    ```
  - AUDIO
    ```
    v4lctl audio stereo
    ```
  - Change CHANNEL
    ```
    v4lctl setchannel 55
    ```
