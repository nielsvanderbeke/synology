#!/opt/bin/python2.6
# -*- coding: utf-8 -*-

import periscope
import sys
import logging
logging.basicConfig(level=logging.DEBUG)


subdl = periscope.Periscope()
filepath = sys.argv[1]
#subtitle = subdl.downloadSubtitle(filepath, ['fr','en']) # Dutch, and if not available try English
subtitle = subdl.downloadSubtitle(filepath, ['fr']) # Dutch, and if not available try English
if subtitle :
    print "--\nFound a sub from %s in language %s, downloaded to %s" % ( subtitle['plugin'], subtitle['lang'], subtitle['subtitlepath'])
else:
    print "--\nNo sub found"