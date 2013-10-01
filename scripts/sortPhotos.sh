#!/bin/bash -x

unsorted="/volume1/tmp2/unsort_foto"
foto_collection="/volume1/media/fotos"

cd $unsorted

# Work on each file one at a time
for F in ./*
do
	if [ -f "$F" ];then				
		datum=`date -r "$F" +%F`
	  	echo "============================"
		echo "$datum  - $F"
		if [ -d "$foto_collection/$datum" ];then    
			cp "$F" "$foto_collection/$datum/$F"
		else
			mkdir $foto_collection/$datum
			cp "$F" "$foto_collection/$datum/$F"
		fi
	fi
done
