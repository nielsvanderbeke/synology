#!/bin/bash -x


# Where is your music collection?  Where should all music be organized to?
music_collection="/volume1/media/sort_music" 


# SABNZBD usage
# 1) Edit music_collection setting above if your music isn't in the "normal" place
# 2) Set this up as an SABNZBD Post Processing script

# GENERAL usage
# 1) Edit music_collection setting above if your music isn't in the "normal" place
# 2) run in a terminal as: ./mp3organizer /path_to/where_the_new_music_files/are 
# Note that the path can't have any spaces.

# NOTES AND ADVANCED USAGE
# File with bad tags are stored to /[Your_music_collection]/unknown

# See the Advanced Options settings if you want to:
# a) Make backup copies
# b) Move instead of copy file from the new music location

# =============================================================================================
# ADVANCED / OPTIONAL SETTINGS
# Want all the files copied somewhere else too? 
#backup_dir="$HOME/mp3organizer_backups"

# Set to "copy" or "move" to make the script either copy files to your music collection and leave
# the originals where they were or move them to your music collection.
mode="copy"

# If you want the unknown files to be saved somewhere else, or to change where this script
# keeps temporary files, change these:
unknown_dir="$music_collection/unknown" 
working_dir="/volume1/media/tmp"


# =============================================================================================
# EVERYTHING BELOW HERE IS AS IT SHOULD BE. DONT MESS WITH IT

# Make sure that a folder has been passed to the script
if [ -z "$1" ];then
  echo "Doh!  You have to pass a directory where the music is you want to organize!"
  exit
else	
  echo "Working from supplied directory"
  echo "$1"
	new_music="$1"
fi

# Make sure if a folder has been passed that it actuall exists
if [ ! -d "$new_music" ];then    
  echo "Can't find the search directory $new_music"
  echo "For SABNZBD, in the admin go to Settings > Switches and set REPLACE SPACES WITH UNDERSCORSES"
  exit
fi

# Check other folders exist and make them if necessary
if [ ! -d "$working_dir" ];then    
  echo "Creating $working_dir"
  mkdir $working_dir
fi

if [ ! -d "$music_collection" ];then    
  echo "Creating $music_collection"
  mkdir $music_collection
fi

if [ ! -d "$unknown_dir" ];then    
  echo "Creating $unknown_dir"
  mkdir $unknown_dir
fi

if [ ! -d "$backup_dir" ];then    
  echo "Creating $backup_dir"
  mkdir $backup_dir
fi

# Copy or Move the new music files to our temporary working area to be processed
if [ "$mode" = 'move' ]; then
  find $new_music -iname "*.mp3" -exec mv {} $working_dir \;
else
  find $new_music -iname "*.mp3" -exec cp {} $working_dir \;
fi

cd $working_dir

# Work on each file one at a time
for F in ./*
do
	if [ -f "$F" ];then				
    # use mminfo to get the track info
    # LOTS of stuff going on here. Have to remove leading space, special chars and pad track to 0x etc.
    # Someone smart could do this a lot more elegantly than this!
		artist=`mminfo "$F"|grep artist|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/[^a-zA-Z0-9\ \-\_]//g'`
		title=`mminfo "$F"|grep title|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/[^a-zA-Z0-9\ \-\_]//g'`
		album=`mminfo "$F"|grep album|awk -F: '{print $2}'|sed 's/^ *//g'|sed 's/[^a-zA-Z0-9\ \-\_]//g'`
		trackno=`mminfo "$F"|grep trackno|awk -F: '{print $2}'|sed 's/^ *//g'| awk '{printf "%02d\n", $1;}'`

	  echo "============================"
		echo "artist:" $artist
		echo "title:" $title
		echo "album:" $album
		echo "trackno:" $trackno

      # If we have an artist, album and title then we know where to nicely put this file
			if [  -n "$artist"  ] && [ -n "$album" ] && [  -n "$title"  ];then
          # This is what we are going to call the file
  				filename="$trackno - $title.mp3"; 
			  	if [ -n  "$backup_dir" ];then
			          cp "$F" "$backup_dir/"
				  fi
  				# If the right directory structure exists - awesome. Move the file.
					if [ -d "$music_collection/$artist/$album" ];then    
						mv "$F" "$music_collection/$artist/$album/$filename"  
					else
					  # If not, build the whole file structure. Won't do any harm to try and create an artist directory that
					  # is already there - so not even checking for that.
						mkdir "$music_collection/$artist"
						mkdir "$music_collection/$artist/$album"
						mv "$F" "$music_collection/$artist/$album/$filename"
					fi
			else
        # Don't know who it's by, what album, or what track, so moving it to UNKNOWN
  			mv "$F" "$unknown_dir/"
				echo -e "UNKNOWN: $F \n"
			fi
	fi
done
