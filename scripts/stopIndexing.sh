/usr/syno/etc/rc.d/S??synoindexd.sh stop
/usr/syno/etc/rc.d/S??synomkflvd.sh stop
/usr/syno/etc/rc.d/S??synomkthumbd.sh stop
killall -9 convert
killall -9 ffmpeg
# If you don't use Download Station (but e.g. SABnzbd instead):
# /usr/syno/etc/rc.d/S??pgsql.sh stop
