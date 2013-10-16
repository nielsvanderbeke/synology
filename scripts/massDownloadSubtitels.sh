#!/bin/sh

find . -name "*.mkv" -o -name "*.avi" | while read file
do
  #echo "Fichier : $file"
  unext_file=${file%.*}
  srt_file=${unext_file}.srt
  if [ ! -f "$srt_file" ]
  then
echo "--- Searching subs for \"$file\" ---"
    downloadSub.py "$file"
    echo "-=-"
  fi
done