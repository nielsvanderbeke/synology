#!/bin/sh
# http://juliensimon.blogspot.fr/2012/05/audio-mass-encode-on-synology-nas-flac.html

# This is needed to handle spaces in file names
OLDIFS=$IFS
IFS=$(echo -en "\n\b")

# Base directory where MP3 files will be created
newbasedir=/volume1/music/MP3new
# MP3 bitrate in bits
bitrate=320000
# Overwrite existing MP3 files (-y for yes, blank for no)
overwrite=-y

# Iterate on albums
for j in *
do
cd $j
  echo $PWD
  newdir=$newbasedir/`basename $PWD`
  mkdir -p $newdir
  # Iterate on tracks
  for i in *.flac
  do
newname=`basename $i flac`mp3
    ffmpeg $overwrite -i $i -ab $bitrate -acodec mp2 $newdir/$newname >& /dev/null
    echo " "$newname
  done
cd ..
done

IFS=$OLDIFS