#!/bin/sh

VOLUMES_TO_SEARCH="/volume1 /volume2 /volumeUSB1/usbshare/ /volumeUSB2/usbshare/"



for volume in $VOLUMES_TO_SEARCH
do
        cd $volume
        find . -name "*recycle" -type d -exec
        



done


du -sh * | perl -e 'sub h{%h=(K=>10,M=>20,G=>30);($n,$u)=shift=~/([0-9.]+)(\D)/;return $n*2**$h{$u}}print sort{h($b)<=>h($a)}<>;'