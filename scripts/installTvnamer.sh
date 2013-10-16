# info at https://github.com/dbr/tvnamer
ipkg install python25 py25-setuptools git
cd /volume1/@tmp
git clone https://github.com/dbr/tvnamer.git
cd tvnamer
python setup.py install
ln -s /opt/local/bin/tvnamer /usr/bin/tvnamer