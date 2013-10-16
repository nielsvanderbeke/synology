ipkg install vim bash bash-completion less rsync mtr \
  sudo tshark htop openssl mlocate perl ack hdparm sysstat dstat \
  bzip2 unrar unzip zlib p7zip wget clamav

wget -O- --no-check-certificate https://raw.github.com/timkay/solo/master/solo > /usr/bin/solo
chmod a+x /usr/bin/solo