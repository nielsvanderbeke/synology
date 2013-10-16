#!/bin/sh

# Editable parameters
SUBS_TO_SEARCH="fre|eng"

# ---
MKVFILE=$*
SUBTITLE_ID=": subtitles ("


# ---

# Step1 : Get the good lines and build command line options

CL_OPTIONS=$(mkvmerge -I "$MKVFILE" | grep "$SUBTITLE_ID" | grep -E "$SUBS_TO_SEARCH" \
         | sed "s/^Track ID //g" \
         | sed "s/: subtitles[^\[]*\[language:/_/g" \
         | sed "s/ track_name:\(.*\)\\\s\(.*\) /_\1-\2/g" \
         | sed "s/ .*//g" \
         | sed "s/^\([^_]*\)_\(.*\)/ \1:\2_\1.srt/g" \
         | tr -d '\n' )

#echo "$CL_OPTIONS"

# Step2 : Extract Files
mkvextract tracks "$MKVFILE" $CL_OPTIONS